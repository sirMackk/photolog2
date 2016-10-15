defmodule Photolog2.PageController do
  use Photolog2.Web, :controller

  alias Photolog2.Album

  @per_page 5
  def index(conn, params) do
    page = Map.get(params, "page", "1")
      |> String.to_integer
      |> positivize

    IO.puts page

    total_albums = Album
      |> Album.total_albums
      |> Repo.one!

    albums = Album
      |> Album.all_published
      |> Album.pageinated(@per_page, page)
      |> Album.newest_first
      |> Repo.all
      |> Repo.preload(:photos)
    render(conn,
           "index.html",
           albums: albums,
           current_page: page,
           per_page: @per_page,
           total_albums: total_albums)
  end

  def about(conn, _params) do
  end

  defp positivize(num) do
    if num > 0, do: num, else: 1
  end
end
