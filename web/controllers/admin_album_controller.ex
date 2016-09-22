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
        process_files(album, Map.get(album_params, "files", []))

        conn
          |> put_flash(:info, "Album updated!")
          |> redirect(to: admin_album_path(conn, :edit, id))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Album did not pass validation.")
          |> render(conn, "edit.html", album: album, changeset: changeset)
    end
  end

  def process_files(album, files \\ []) do
    files
      |> Enum.map(&add_local_filename/1)
      |> Enum.map(&Task.async(__MODULE__, :resize_file, [&1]))
      |> Enum.map(&Task.await/1)
      |> Enum.map(&insert_photo_record(album, &1))
  end

  def slugidize(string) do
    Regex.replace(~r/([^a-z0-9.-])+/, String.downcase(string), "-", global: true)
  end

  def add_timestamp(string) do
    Integer.to_string(:os.system_time(:seconds)) <> "_" <> string
  end

  def add_local_filename(file_struct) do
    local_filename = Map.get(file_struct, :filename)
      |> add_timestamp
      |> slugidize
    target_path = Path.join(media_path, local_filename)
    Map.merge(file_struct, %{local_filename: local_filename, local_filepath: target_path})
  end

  def resize_file(file_struct) do
    System.cmd("convert", ["-resize", "1920x", file_struct.path, file_struct.local_filepath])
    file_struct
  end

  def insert_photo_record(album, file_struct) do
    %{filename: name, local_filepath: file_name} = file_struct

    album
      |> Ecto.build_assoc(:photos, %{name: name, file_name: file_name})
      |> Repo.insert!
  end

  def media_path do
    Application.get_env(:photolog2, :media_path)
  end
end
