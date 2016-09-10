defmodule Photolog2.AdminAlbumController do
  use Photolog2.Web, :controller

  alias Photolog2.Router.Helpers

  def index(conn, _params) do
    albums = Repo.all(Photolog2.Album)
      |> Repo.preload(:user)
    render(conn, "index.html", albums: albums)
  end
end
