defmodule Photolog2.AuthTest do
  import Photolog2.TestHelpers
  use Photolog2.ConnCase

  alias Photolog2.Auth
  alias Photolog2.User

  setup(%{conn: conn}) do
    conn = conn
      |> bypass_through(Photolog2.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authentication halts when no current_user on conn", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authentication continues when current_user on conn", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %User{id: 123})
      |> Auth.authenticate_user([])
    refute conn.halted
  end

  test "logging in assigns current user and adds user_id to session", %{conn: conn} do
    user = insert_user(%{password: "password"})
    {:ok, conn} =
      Auth.login_by_username_and_pass(conn, user.username, "password", repo: Repo)

    assert conn.assigns[:current_user].id == user.id
    assert get_session(conn, :user_id) == user.id
  end

  test "logging in with right user but wrong password gives unauthorized", %{conn: conn} do
    user = insert_user()
    {:error, :unauthorized, _} =
      Auth.login_by_username_and_pass(conn, user.username, "", repo: Repo)
  end

  test "logging in with wrong user - not found error", %{conn: conn} do
    {:error, :not_found, _} =
      Auth.login_by_username_and_pass(conn, "", "", repo: Repo)
  end

  test "login adds user_id to session", %{conn: conn} do
    conn =
      conn
      |> Auth.login(%User{id: 123})
      |> send_resp(:ok, "")

    assert conn.assigns.current_user.id == 123

    next_conn = get(conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout removes user_id from session", %{conn: conn} do
    conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(conn, "/")
    refute get_session(next_conn, :user_id)
  end
end
