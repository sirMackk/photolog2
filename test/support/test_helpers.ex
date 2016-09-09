defmodule Photolog2.TestHelpers do
  alias Photolog2.Repo

  def insert_user(attrs \\ %{}) do
    username = "user-#{Base.encode16(:crypto.rand_bytes(8))}"
    changes = Dict.merge(%{
      username: username,
      password: "password"}, attrs)

  %Photolog2.User{}
  |> Photolog2.User.registration_changeset(changes)
  |> Repo.insert!()
  end

  def insert_album(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:albums, attrs)
    |> Repo.insert!
  end

  def insert_photo(album, attrs \\ %{}) do
    album
    |> Ecto.build_assoc(:photos, attrs)
    |> Repo.insert!
  end
end
