defmodule Photolog2.PageController do
  use Photolog2.Web, :controller

  alias Photolog2.Album

  @pagination 5
  def index(conn, params) do
    page = Map.get(params, "page", 1)

    albums = Album
      |> Album.all_published
      |> Album.pageinated(@pagination, page)
      |> Album.newest_first
      |> Repo.all
      |> Repo.preload(:photos)
    render(conn, "index.html", albums: albums)
  end

  def about(conn, _params) do
  end
end
