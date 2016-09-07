defmodule Photolog2.User do
  use Photolog2.Web, :model

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :albums, Photolog2.Album

    timestamps
  end

  @allowed_fields ~w(username)a
  @passwd_field ~w(password)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @allowed_fields)
    |> validate_required(@allowed_fields)
    |> unique_constraint(:username)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, @passwd_field)
    |> validate_required(@passwd_field)
    |> validate_length(List.first(@passwd_field), min: 8, max: 100)
    |> put_pass_hash()
  end


  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end

