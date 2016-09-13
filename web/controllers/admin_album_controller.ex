defmodule Photolog2.AdminAlbumController do
  use Photolog2.Web, :controller

  alias Photolog2.Album
  alias Photolog2.Router.Helpers

  def index(conn, _params) do
    albums = Repo.all(Album)
      |> Repo.preload(:user)
    render(conn, "index.html", albums: albums)
  end

  def edit(conn, %{"id" => id}) do
    album = Repo.get!(Album, id)
    changeset = Album.changeset(album)
    render(conn, "edit.html", album: album, changeset: changeset)
  end
end
