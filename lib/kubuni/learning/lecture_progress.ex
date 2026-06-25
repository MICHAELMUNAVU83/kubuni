defmodule Kubuni.Learning.LectureProgress do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lecture_progress" do
    field :status, Ecto.Enum, values: [:not_started, :in_progress, :completed]
    field :last_position_seconds, :integer
    field :completed_at, :utc_datetime
    belongs_to :user, Kubuni.Accounts.User
    belongs_to :lecture, Kubuni.Catalog.Lecture

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lecture_progress, attrs) do
    lecture_progress
    |> cast(attrs, [:status, :last_position_seconds, :completed_at])
    |> validate_required([:status, :last_position_seconds, :completed_at])
  end
end
