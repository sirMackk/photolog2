defmodule Photolog2.User do
  use Photolog2.Web, :model

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :albums, Photolog2.Album

    timestamps
  end

  @allowed_fields ~w(username)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @allowed_fields)
    |> validate_required(@allowed_fields)
    |> unique_constraint(:username)
  end

  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonein.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end

