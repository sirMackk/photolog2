defmodule Photolog2.Album do
  use Photolog2.Web, :model

  @status_enum %{unpublished: 0, published: 1}

  schema "albums" do
    field :name, :string
    field :description, :string
    field :status, :integer, default: 0

    has_many :photos, Photolog2.Photo
    belongs_to :user, Photolog2.User

    timestamps
  end

  @allowed_fields ~w(name description status)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @allowed_fields)
    |> validate_inclusion(:status, 0..Enum.max(Map.values(@status_enum)))
  end

  def is_published(model) do
    model.status == Map.get(@status_enum, :published)
  end

  def all_published(query) do
    from album in query, where: album.status == ^Map.get(@status_enum, :published)
  end

  def status_enum, do: @status_enum
end
