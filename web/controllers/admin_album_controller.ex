defmodule Photolog2.AdminAlbumController do
  use Photolog2.Web, :controller

  alias Photolog2.Album
  alias Photolog2.Photo
  alias Photolog2.ImageProcessor

  def index(conn, _params) do
    albums = Repo.all(Album)
      |> Repo.preload(:user)
    render(conn, "index.html", albums: albums)
  end

  def edit(conn, %{"id" => id}) do
    album = Repo.get!(Album, id)
      |> Repo.preload(:photos)
    changeset = Album.changeset(album)
    render(conn, "edit.html", album: album, changeset: changeset)
  end

  def update(conn, %{"id" => id, "album" => album_params}) do
    album = Repo.get!(Album, id)
    changeset = Album.changeset(album, album_params)

    case Repo.update(changeset) do
      {:ok, album} ->
        ImageProcessor.process_files(album, Map.get(album_params, "files", []))

        conn
          |> put_flash(:info, "Album updated!")
          |> redirect(to: admin_album_path(conn, :edit, id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Album did not pass validation.")
          |> render(conn, "edit.html", album: album, changeset: changeset)
    end
  end

  def new(conn, _params) do
    user = conn.assigns[:current_user]
    changeset = user
                |> build_assoc(:albums)
                |> Album.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"album" => album_params}) do
    user = conn.assigns[:current_user]
    changeset = user
                |> build_assoc(:albums)
                |> Album.changeset(album_params)

    case Repo.insert(changeset) do
      {:ok, album} ->
        ImageProcessor.process_files(album, Map.get(album_params, "files", []))

        conn
          |> put_flash(:info, "Album '#{album.name}' created!")
          |> redirect(to: admin_album_path(conn, :edit, album))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Fix thy errors!")
          |> render(conn, "new.html", changeset: changeset)
    end
  end

  def update_photos(conn, %{"id" => id, "photos" => photos}) do
    for {id, photo_params} <- photos do
      photo = Repo.get!(Photo, String.to_integer(id))
      if Map.get(photo_params, "delete") == "true" do
        Repo.delete(photo)
      else
        changeset = Photo.changeset(photo, Map.drop(photo_params, ["delete"]))
        Repo.update!(changeset)
      end
    end

    conn
      |> put_flash(:info, "Updated album photos!")
      |> redirect(to: admin_album_path(conn, :edit, id))
  end
end
