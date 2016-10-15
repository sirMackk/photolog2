defmodule Photolog2.ImageProcessorTest do
  use Photolog2.LibCase
  alias Photolog2.ImageProcessor


  test "process files inserts photos into album" do
    admin = insert_user(%{name: "admin"})
    album1 = insert_album(admin, %{name: "Album 1"})

    fname = "picture.jpg"
    file_struct = %{filename: fname, path: "media/" <> fname}

    with_mock System, [cmd: fn _, _ -> 1 end]do
      ImageProcessor.process_files(album1, [file_struct])

      [photo] = Repo.preload(album1, :photos).photos

      assert photo.name == Map.get(file_struct, :filename)
    end
  end

  test "slugidize name" do
    slug = ImageProcessor.slugidize("this is !@# a Ph0to.jpg")
    assert slug == "this-is-a-ph0to.jpg"
  end

  test "add_timestamp should add timestamp" do
    str = "some_kind_of_string"
    timestamped_str = ImageProcessor.add_timestamp(str)
    assert Regex.match?(~r/\d{10}_some_kind_of_string/, timestamped_str)
  end

  test "add_local_filename adds a localized filename to struct" do
    file_struct = %{filename: "picture.jpg"}
    file_struct = ImageProcessor.add_local_filename(file_struct)
    %{local_filename: fname} = file_struct

    assert Regex.match?(~r/^\d{10}-picture.jpg$/, fname)
  end

  test "resize_file calls imagemagick 'convert' command and returns file_struct" do
    file_struct = ImageProcessor.add_local_filename(%{filename: "picture.jpg", path: "media/picture.jpg"})
    with_mock System, [cmd: fn _, _ -> 1 end] do
      rsp = ImageProcessor.resize_file(file_struct, [prefix: "thumb-"])

      target_path = Path.join(ImageProcessor.media_path, "thumb-" <> file_struct.local_filename)
      assert called System.cmd("convert", ["-resize", "1920x", file_struct.path, target_path])
      assert file_struct == rsp
    end
  end

  test "insert_photo_record actually inserts a record into the db" do
    admin = insert_user(%{name: "admin"})
    album1 = insert_album(admin, %{name: "Album 1"})
    file_struct = %{filename: "picture.jpg", local_filename: "10-picture.jpg"}

    ImageProcessor.insert_photo_record(album1, file_struct)

    photo = List.first(Repo.preload(album1, :photos).photos)

    assert photo.name == Map.get(file_struct, :filename)
    assert photo.file_name == Map.get(file_struct, :local_filename)
  end
end
