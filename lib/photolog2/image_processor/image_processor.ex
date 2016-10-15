defmodule Photolog2.ImageProcessor do
  alias Photolog2.Repo

  # TODO: This module is leaky, there are items here that dont deal with processing images.

  def process_files(album, files \\ []) do
    files
      |> Enum.map(&add_local_filename/1)
      |> Enum.map(&Task.async(__MODULE__, :resize_file, [&1]))
      |> Enum.map(&Task.await/1)
      |> Enum.map(&Task.async(__MODULE__, :resize_file, [&1, [size: "300x", prefix: "thumb_"]]))
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
    defaults = [size: "1920x", prefix: "large_"]
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
