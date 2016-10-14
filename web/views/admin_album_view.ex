defmodule Photolog2.AdminAlbumView do
  use Photolog2.Web, :view

  def album_status_map do
    Photolog2.Album.status_enum
  end

  @prefix "photos"
  def album_edit_photo_attrs(id, field) do
    photo_attr = @prefix <> "[#{id}][#{field}]"
    photo_attr_atom = String.to_atom(photo_attr)
    {photo_attr, photo_attr_atom}
  end
end
