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

  def update(conn, %{"id" => id, "album" => album_params}) do
    album = Repo.get!(Album, id)
    changeset = Album.changeset(album, album_params)

    case Repo.update(changeset) do
      {:ok, album} ->
        #Enum.map(Map.get(album_params, "files"), fn file -> process_files(album, file) end)

        conn
          |> put_flash(:info, "Album updated!")
          |> redirect(to: admin_album_path(conn, :edit, id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Album did not pass validation.")
          |> render(conn, "edit.html", album: album, changeset: changeset)
    end
  end

  def process_files(album, files) do
    # copy files to right place
    # resize
    # create db record with new names
    files
      |> Enum.map(&add_local_filename\1)
      |> Enum.map(&Task.async(resize_file(&1)))
      |> Enum.map(&Task.await\1)
      |> Enum.map(insert_photo_record\1)
  end

  def slugidize(string) do
    Regex.replace(~r/([^a-z0-9.-])+/, String.downcase(string), "-", global: true)
  end

  def add_timestamp(string) do
    Integer.to_string(:os.system_time(:seconds)) <> "_" <> string
  end

  def media_path do
    Application.get_env(:photolog2, :media_path)
  end
end
