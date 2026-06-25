defmodule Kubuni.Catalog.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :position, :integer
    field :status, Ecto.Enum, values: [:draft, :published]
    field :description, :string
    field :title, :string
    field :currency, :string
    field :slug, :string
    field :subtitle, :string
    field :thumbnail_key, :string
    field :price_minor, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [
      :slug,
      :title,
      :subtitle,
      :description,
      :thumbnail_key,
      :price_minor,
      :currency,
      :status,
      :position
    ])
    |> validate_required([
      :slug,
      :title,
      :subtitle,
      :description,
      :thumbnail_key,
      :price_minor,
      :currency,
      :status,
      :position
    ])
    |> unique_constraint(:slug)
  end
end
