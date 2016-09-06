defmodule Photolog2.Album do
  use Photolog2.Web, :model

  schema "albums" do
    field :name, :string
    field :description, :string
    field :status, :integer, default: 0

    has_many :photos, Photolog2.Photo
    belongs_to :user, Photolog2.User

    timestamps
  end

  @allowed_fields ~w(name description status)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @allowed_fields)
  end
end

