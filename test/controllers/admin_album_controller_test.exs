defmodule Photolog2.AdminAlbumControllerTest do
  use Photolog2.ConnCase
  import Photolog2.TestHelpers
  import Mock
  alias Photolog2.Router.Helpers

  # test index, new, create, delete, edit

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
    upload = %Plug.Upload{path: "test/fixtures/cat400.jpg", filename: "cat400.jpg"}
    album1 = insert_album(admin, %{name: "Album 1"})

    conn = conn
      |> put(
        Helpers.admin_album_path(conn, :update, album1),
        album: Map.merge(@album_updates, %{files: [upload]}), id: album1.id)

    assert conn.status == 302

    photo = List.first(Repo.preload(album1, :photos).photos)

    assert photo.filename == "cat400.jpg"
  end

  #test "process files inserts photos into album" do
    #admin = insert_user(%{name: "admin"})
    #album1 = insert_album(admin, %{name: "Album 1"})

  #end

  test "slugidize name" do
    slug = Photolog2.AdminAlbumController.slugidize("this is !@# a Ph0to.jpg")
    assert slug == "this-is-a-ph0to.jpg"
  end

  test "add_timestamp should add timestamp" do
    str = "some_kind_of_string"
    timestamped_str = Photolog2.AdminAlbumController.add_timestamp(str)
    assert Regex.match?(~r/\d{10}_some_kind_of_string/, timestamped_str)
  end

  # Test multiple file upload in update and create functions
end
