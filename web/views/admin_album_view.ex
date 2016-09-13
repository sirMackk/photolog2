defmodule Photolog2.AdminAlbumView do
  use Photolog2.Web, :view

  def album_status_map do
    Photolog2.Album.status_enum
  end
end
