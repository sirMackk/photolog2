defmodule Photolog2.SessionControllerTest do
  import Photolog2.TestHelpers
  use Photolog2.ConnCase
  alias Photolog2.Router.Helpers

  test "GET login page", %{conn: conn} do
    conn = get(conn, Helpers.session_path(conn, :new))
    assert html_response(conn, 200) =~ "username"
  end

  @valid_creds %{username: "test", password: "123123123"}
  test "POST to login with right creds", %{conn: conn} do
    _ = insert_user(@valid_creds)
    conn = post(conn, Helpers.session_path(conn, :create), session: @valid_creds)

    assert conn.status == 302
    assert get_resp_header(conn, "location") == [Helpers.admin_album_path(conn, :index)]
    assert get_flash(conn, :info)
  end

  test "POST to login with bad pass - error", %{conn: conn} do
    _ = insert_user(@valid_creds)
    conn =
      post(conn,
           Helpers.session_path(conn, :create),
           session: Dict.merge(@valid_creds, %{password: "123"}))
    assert conn.status == 302
    assert get_resp_header(conn, "location") == [Helpers.session_path(conn, :new)]
    assert get_flash(conn, :error)
  end

  test "POST to login with bad user - error", %{conn: conn} do
    _ = insert_user(@valid_creds)
    conn =
      post(conn,
           Helpers.session_path(conn, :create),
           session: Dict.merge(@valid_creds, %{username: "wat"}))
    assert conn.status == 302
    assert get_resp_header(conn, "location") == [Helpers.session_path(conn, :new)]
    assert get_flash(conn, :error)
  end

  test "POST to logout will remove session", %{conn: conn} do
    conn =
      conn
      |> bypass_through(Photolog2.Router, [:browser])
      |> get("/")
      |> put_session(:user_id, 123)
      |> post(Helpers.session_path(conn, :delete))

    refute get_session(conn, :user_id)
    assert get_resp_header(conn, "location") == [Helpers.session_path(conn, :new)]
    assert get_flash(conn, :info)
  end
end
