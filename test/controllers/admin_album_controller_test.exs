defmodule Photolog2.AdminAlbumControllerTest do
  use Photolog2.ConnCase
  import Photolog2.TestHelpers
  import Mock
  alias Photolog2.Router.Helpers
  alias Photolog2.AdminAlbumController

  setup(%{conn: conn} = config) do
    if config[:login_as_admin] do
      admin = insert_user(%{name: "admin"})
      conn = assign(conn, :current_user, admin)
      {:ok, conn: conn, user: admin}
    else
      :ok
    end
  end

  @tag :login_as_admin
  test "index page shows all created albums", %{conn: conn, user: admin} do
    album1 = insert_album(admin, %{name: "Album 1"})
    album2 = insert_album(admin, %{name: "Album 2"})

    conn = conn
     |> get(Helpers.admin_album_path(conn, :index))

    assert html_response(conn, 200) =~ album1.name
    assert html_response(conn, 200) =~ album2.name
  end

  @tag :login_as_admin
  test "index page contains links to albums", %{conn: conn, user: admin} do
    album1 = insert_album(admin, %{name: "Album 1"})

    conn = conn
      |> get(Helpers.admin_album_path(conn, :index))

    assert html_response(conn, 200) =~ Helpers.admin_album_path(conn, :edit, album1)
  end

  @tag :login_as_admin
  test "album edit page contains filled out form", %{conn: conn, user: admin} do
    album1 = insert_album(admin, %{name: "Album 1"})

    conn = conn
      |> get(Helpers.admin_album_path(conn, :edit, album1))

    assert html_response(conn, 200) =~ album1.name
    assert html_response(conn, 200) =~ Helpers.admin_album_path(conn, :update, album1)
  end

  @tag :login_as_admin
  test "album edit page contains all album statuses", %{conn: conn, user: admin} do
    album1 = insert_album(admin, %{name: "Album 1"})

    conn = conn
      |> get(Helpers.admin_album_path(conn, :edit, album1))

    for status <- Map.keys(Photolog2.Album.status_enum) do
      assert html_response(conn, 200) =~ Atom.to_string(status)
    end
  end

  @album_updates %{name: "Album 1 - updated!"}

  @tag :login_as_admin
  test "submitting a form updates the record", %{conn: conn, user: admin} do
    album1 = insert_album(admin, %{name: "Album 1"})

    conn = conn
      |> put(Helpers.admin_album_path(conn, :update, album1), album: @album_updates, id: album1.id)

    assert conn.status == 302

    album1_updated = Repo.get!(Photolog2.Album, album1.id)

    assert album1_updated.name == Map.get(@album_updates, :name)
  end

  @tag :login_as_admin
  test "submit a single file with the form", %{conn: conn, user: admin} do
    fname = "cat400.jpg"
    upload = %Plug.Upload{path: "test/fixtures/" <> fname, filename: fname}
    album1 = insert_album(admin, %{name: "Album 1"})

    with_mock System, [cmd: fn _, _ -> 1 end] do
      conn = conn
        |> put(
          Helpers.admin_album_path(conn, :update, album1),
          album: Map.merge(@album_updates, %{files: [upload]}), id: album1.id)

      assert conn.status == 302

      [photo] = Repo.preload(album1, :photos).photos

      assert String.contains?(photo.file_name, fname)
      assert String.contains?(photo.file_name, AdminAlbumController.media_path)
    end
  end

  @tag :login_as_admin
  test "submit multiple files with update form", %{conn: conn, user: admin} do
    fname = "cat400.jpg"
    fname2 = "2-" <> fname
    upload = %Plug.Upload{path: "test/fixtures/" <> fname, filename: fname}
    upload2 = %Plug.Upload{path: "test/fixtures/" <> fname2, filename: fname2}
    album1 = insert_album(admin, %{name: "Album 1"})

    with_mock System, [cmd: fn _, _ -> 1 end] do
      conn = conn
        |> put(
          Helpers.admin_album_path(conn, :update, album1),
          album: Map.merge(@album_updates, %{files: [upload, upload2]}), id: album1.id)

      assert conn.status == 302

      photos = Repo.preload(album1, :photos).photos

      assert length(photos) == 2

      [photo1] = Enum.filter(photos, &(&1.name == fname))
      [photo2] = Enum.filter(photos, &(&1.name == fname2))

      assert String.contains?(photo1.file_name, fname)
      assert String.contains?(photo1.file_name, AdminAlbumController.media_path)

      assert String.contains?(photo2.file_name, fname2)
      assert String.contains?(photo2.file_name, AdminAlbumController.media_path)
    end
  end

  test "process files inserts photos into album" do
    admin = insert_user(%{name: "admin"})
    album1 = insert_album(admin, %{name: "Album 1"})

    fname = "picture.jpg"
    file_struct = %{filename: fname, path: "media/" <> fname}

    with_mock System, [cmd: fn _, _ -> 1 end]do
      AdminAlbumController.process_files(album1, [file_struct])

      [photo] = Repo.preload(album1, :photos).photos

      assert photo.name == Map.get(file_struct, :filename)
    end
  end

  test "slugidize name" do
    slug = AdminAlbumController.slugidize("this is !@# a Ph0to.jpg")
    assert slug == "this-is-a-ph0to.jpg"
  end

  test "add_timestamp should add timestamp" do
    str = "some_kind_of_string"
    timestamped_str = AdminAlbumController.add_timestamp(str)
    assert Regex.match?(~r/\d{10}_some_kind_of_string/, timestamped_str)
  end

  test "add_local_filename adds a localized filename and path to struct" do
    file_struct = %{filename: "picture.jpg"}
    file_struct = AdminAlbumController.add_local_filename(file_struct)
    %{local_filename: fname, local_filepath: fpath} = file_struct

    assert Regex.match?(~r/^\d{10}-picture.jpg$/, fname)
    assert String.contains?(fpath, AdminAlbumController.media_path)
    assert Regex.match?(~r/\d{10}-picture.jpg$/, fpath)
  end

  test "resize_file calls imagemagick 'convert' command and returns file_struct" do
    file_struct = AdminAlbumController.add_local_filename(%{filename: "picture.jpg", path: "media/picture.jpg"})
    with_mock System, [cmd: fn _, _ -> 1 end] do
      rsp = AdminAlbumController.resize_file(file_struct)

      target_path = Path.join(AdminAlbumController.media_path, file_struct.local_filename)
      assert called System.cmd("convert", ["-resize", "1920x", file_struct.path, target_path])
      assert file_struct == rsp
    end
  end

  test "insert_photo_record actually inserts a record into the db" do
    admin = insert_user(%{name: "admin"})
    album1 = insert_album(admin, %{name: "Album 1"})
    file_struct = %{filename: "picture.jpg", local_filepath: "media/picture.jpg"}

    AdminAlbumController.insert_photo_record(album1, file_struct)

    photo = List.first(Repo.preload(album1, :photos).photos)

    assert photo.name == Map.get(file_struct, :filename)
    assert photo.file_name == Map.get(file_struct, :local_filepath)
  end
end
