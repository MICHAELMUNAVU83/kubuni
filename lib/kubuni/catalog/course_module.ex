defmodule Kubuni.Catalog.CourseModule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "modules" do
    field :position, :integer
    field :description, :string
    field :title, :string
    belongs_to :course, Kubuni.Catalog.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course_module, attrs) do
    course_module
    |> cast(attrs, [:title, :description, :position])
    |> validate_required([:title, :description, :position])
  end
end
