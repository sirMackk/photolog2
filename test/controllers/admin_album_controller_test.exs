defmodule Photolog2.AdminAlbumControllerTest do
  use Photolog2.ConnCase
  import Photolog2.TestHelpers
  import Mock
  alias Photolog2.Router.Helpers

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

      assert String.contains?(photo2.file_name, fname2)
    end
  end

  @tag :login_as_admin
  test "album new page contains empty form", %{conn: conn} do

    conn = conn
      |> get(Helpers.admin_album_path(conn, :new))

    assert html_response(conn, 200) =~ Helpers.admin_album_path(conn, :create)
  end

  @tag :login_as_admin
  test "album create creates a new album and redirects to its edit page", %{conn: conn, user: admin} do
    album = %{name: "Created Album"}

    conn = conn
      |> post(Helpers.admin_album_path(conn, :create), album: album)

    assert conn.status == 302

    albums = Repo.preload(admin, :albums).albums

    assert length(albums) == 1
    [albums] = albums

    assert albums.name == "Created Album"
  end

  @tag :login_as_admin
  test "album create creates a new album with multiple photos", %{conn: conn, user: admin} do
    album = %{name: "Created Album"}
    upload = %Plug.Upload{path: "test/fixtures/cat400.jpg", filename: "cat400.jpg"}

    with_mock System, [cmd: fn _, _ -> 1 end] do
      conn = conn
        |> post(
          Helpers.admin_album_path(conn, :create),
          album: Map.merge(album, %{"files": [upload]}))

      assert conn.status == 302

      [album] = Repo.preload(admin, :albums).albums
      [photo] = Repo.preload(album, :photos).photos

      assert album.name == "Created Album"
      assert String.contains?(photo.name, "cat400.jpg")
    end
  end

  @tag :login_as_admin
  test "update_photos updates existing photo objects and redirects", %{conn: conn, user: admin} do
    album = insert_album(admin, %{name: "Album 1"})
    photo1 = album
      |> Ecto.build_assoc(:photos, %{name: "p1", file_name: "fname.jpg"})
      |> Repo.insert!
    _photo2 = album
      |> Ecto.build_assoc(:photos, %{name: "p2", file_name: "fname2.jpg"})
      |> Repo.insert!

    conn = conn
      |> post(Helpers.admin_album_path(conn, :update_photos, album.id),
              photos: %{photo1.id => %{"delete" => "false", "name": "p1-updated"}})

    photo1 = Repo.get!(Photolog2.Photo, photo1.id)

    assert conn.status == 302
    assert photo1.name == "p1-updated"
  end

  @tag :login_as_admin
  test "update_photos deletes photo objects and redirects", %{conn: conn, user: admin} do
    album = insert_album(admin, %{name: "Album 1"})
    photo1 = album
      |> Ecto.build_assoc(:photos, %{name: "p1", file_name: "fname.jpg"})
      |> Repo.insert!
    photo2 = album
      |> Ecto.build_assoc(:photos, %{name: "p2", file_name: "fname2.jpg"})
      |> Repo.insert!

    _conn = conn
      |> post(Helpers.admin_album_path(conn, :update_photos, album.id),
              photos: %{photo1.id => %{"delete" => "true", "name": "p1-updated"},
                        photo2.id => %{"delete" => "false", "name": "p2-updated"}})

    photo2 = Repo.get!(Photolog2.Photo, photo2.id)

    assert photo2.name == "p2-updated"

    assert nil == Repo.get(Photolog2.Photo, photo1.id)
  end
end
