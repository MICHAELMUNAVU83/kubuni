defmodule Kubuni.Catalog.Lecture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lectures" do
    field :position, :integer
    field :description, :string
    field :title, :string
    field :video_provider, Ecto.Enum, values: [:mux, :cloudflare, :bunny]
    field :video_asset_id, :string
    field :duration_seconds, :integer
    belongs_to :module, Kubuni.Catalog.CourseModule

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lecture, attrs) do
    lecture
    |> cast(attrs, [
      :title,
      :description,
      :video_provider,
      :video_asset_id,
      :duration_seconds,
      :position
    ])
    |> validate_required([
      :title,
      :description,
      :video_provider,
      :video_asset_id,
      :duration_seconds,
      :position
    ])
  end
end
