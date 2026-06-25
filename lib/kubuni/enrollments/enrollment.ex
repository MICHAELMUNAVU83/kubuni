defmodule Kubuni.Enrollments.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "enrollments" do
    field :status, Ecto.Enum, values: [:pending, :active]
    field :enrolled_at, :utc_datetime
    field :activated_at, :utc_datetime
    belongs_to :user, Kubuni.Accounts.User
    belongs_to :course, Kubuni.Catalog.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:status, :enrolled_at, :activated_at])
    |> validate_required([:status, :enrolled_at, :activated_at])
  end
end
