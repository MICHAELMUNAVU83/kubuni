defmodule Kubuni.Certificates.Certificate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "certificates" do
    field :type, Ecto.Enum, values: [:module, :course]
    field :serial_number, :string
    field :file_key, :string
    field :issued_at, :utc_datetime
    belongs_to :user, Kubuni.Accounts.User
    belongs_to :course, Kubuni.Catalog.Course
    belongs_to :module, Kubuni.Catalog.CourseModule

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(certificate, attrs) do
    certificate
    |> cast(attrs, [:type, :serial_number, :file_key, :issued_at])
    |> validate_required([:type, :serial_number, :file_key, :issued_at])
    |> unique_constraint(:serial_number)
  end
end
