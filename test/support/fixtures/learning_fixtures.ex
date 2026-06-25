defmodule Kubuni.LearningFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kubuni.Learning` context.
  """

  @doc """
  Generate a lecture_progress.
  """
  def lecture_progress_fixture(attrs \\ %{}) do
    {:ok, lecture_progress} =
      attrs
      |> Enum.into(%{
        completed_at: ~U[2026-06-24 10:02:00Z],
        last_position_seconds: 42,
        status: :not_started
      })
      |> Kubuni.Learning.create_lecture_progress()

    lecture_progress
  end
end
