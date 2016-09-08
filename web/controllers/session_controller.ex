defmodule Photolog2.SessionController do
  use Photolog2.Web, :controller

  def new(conn, _params) do
    render(conn, "login.html")
  end

  def create(conn, %{"session" => %{"username" => username, "password" => pass}}) do
    case Photolog2.Auth.login_by_username_and_pass(conn, username, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back, you have been missed.")
        |> redirect(to: Photolog2.Router.Helpers.admin_album_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Authentication error.")
        |> redirect(to: Photolog2.Router.Helpers.session_path(conn, :new))
    end
  end
end
