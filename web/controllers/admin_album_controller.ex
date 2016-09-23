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
        process_files(album, Map.get(album_params, "files", []))

        conn
          |> put_flash(:info, "Album '#{album.name}' created!")
          |> redirect(to: admin_album_path(conn, :edit, album))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Fix thy errors!")
          |> render(conn, "new.html", changeset: changeset)
    end
  end


  ### TODO: Extract into utils?

  def process_files(album, files \\ []) do
    files
      |> Enum.map(&add_local_filename/1)
      |> Enum.map(&Task.async(__MODULE__, :resize_file, [&1]))
      |> Enum.map(&Task.await/1)
      |> Enum.map(&Task.async(__MODULE__, :resize_file, [&1, [size: "300x", prefix: "thumb-"]]))
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
    Map.merge(file_struct, %{local_filename: local_filename})
  end

  def resize_file(file_struct, opts \\ []) do
    defaults = [size: "1920x", prefix: "large-"]
    opts = Keyword.merge(defaults, opts)

    target_path = Path.join(media_path, opts[:prefix] <> file_struct.local_filename)
    System.cmd("convert", ["-resize", opts[:size], file_struct.path, target_path])
    file_struct
  end

  def insert_photo_record(album, file_struct) do
    %{filename: name, local_filename: file_name} = file_struct

    album
      |> Ecto.build_assoc(:photos, %{name: name, file_name: file_name})
      |> Repo.insert!
  end

  def media_path do
    Application.get_env(:photolog2, :media_path)
  end
end
