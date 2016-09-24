defmodule Photolog2.PageControllerTest do
  use Photolog2.ConnCase

  import Photolog2.TestHelpers

  alias Photolog2.Album

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Photoblog"
  end

  test "GET home should show albums", %{conn: conn} do
    user = insert_user(%{name: "Admin"})
    %{published: status} = Album.status_enum
    album1 = insert_album(user, %{name: "Album 1", status: status})
    album2 = insert_album(user, %{name: "Album 2", status: status})

    conn = conn
      |> get("/")

    assert html_response(conn, 200) =~ "Album 1"
    assert html_response(conn, 200) =~ "Album 2"
  end
end
