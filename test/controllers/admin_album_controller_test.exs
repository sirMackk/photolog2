defmodule Photolog2.AdminAlbumControllerTest do
  use Photolog2.ConnCase
  import Photolog2.TestHelpers
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
end
