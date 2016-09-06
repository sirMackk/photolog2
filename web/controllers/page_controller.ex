defmodule Photolog2.PageController do
  use Photolog2.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
