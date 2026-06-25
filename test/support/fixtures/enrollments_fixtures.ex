defmodule Kubuni.EnrollmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kubuni.Enrollments` context.
  """

  @doc """
  Generate a enrollment.
  """
  def enrollment_fixture(attrs \\ %{}) do
    {:ok, enrollment} =
      attrs
      |> Enum.into(%{
        activated_at: ~U[2026-06-24 10:02:00Z],
        enrolled_at: ~U[2026-06-24 10:02:00Z],
        status: :pending
      })
      |> Kubuni.Enrollments.create_enrollment()

    enrollment
  end
end
