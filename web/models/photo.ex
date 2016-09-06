defmodule Photolog2.Photo do
  use Photolog2.Web, :model

  schema "photos" do
    field :name, :string
    field :file_name, :string
    field :description, :string

    belongs_to :album, Photolog2.Album

    timestamps
  end

  @allowed_fields ~w(name, description)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @allowed_fields)
  end
end
