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
end
