defmodule Photolog2.Album do
  use Photolog2.Web, :model

  @status_enum %{unpublished: 0, published: 1}

  schema "albums" do
    field :name, :string
    field :description, :string
    field :status, :integer, default: 0

    has_many :photos, Photolog2.Photo, on_delete: :delete_all
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
    from(album in query, where: album.status == ^Map.get(@status_enum, :published))
  end

  def newest_first(query) do
    from(album in query, order_by: [desc: album.inserted_at])
  end

  def pageinated(query, per_page \\ 5, page \\ 1)
  def pageinated(query, per_page, page) when page < 1 do
    pageinated(query, per_page, 1)
  end

  def pageinated(query, per_page, page) do
    from(album in query, limit: ^per_page, offset: ^(per_page * (page - 1)))
  end

  def total_albums(query), do: from(p in query, select: count("id"))

  def status_enum, do: @status_enum
end
