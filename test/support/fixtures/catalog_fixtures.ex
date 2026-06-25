defmodule Kubuni.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kubuni.Catalog` context.
  """

  @doc """
  Generate a unique course slug.
  """
  def unique_course_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        currency: "some currency",
        description: "some description",
        position: 42,
        price_minor: 42,
        slug: unique_course_slug(),
        status: :draft,
        subtitle: "some subtitle",
        thumbnail_key: "some thumbnail_key",
        title: "some title"
      })
      |> Kubuni.Catalog.create_course()

    course
  end

  @doc """
  Generate a course_module.
  """
  def course_module_fixture(attrs \\ %{}) do
    {:ok, course_module} =
      attrs
      |> Enum.into(%{
        description: "some description",
        position: 42,
        title: "some title"
      })
      |> Kubuni.Catalog.create_course_module()

    course_module
  end

  @doc """
  Generate a lecture.
  """
  def lecture_fixture(attrs \\ %{}) do
    {:ok, lecture} =
      attrs
      |> Enum.into(%{
        description: "some description",
        duration_seconds: 42,
        position: 42,
        title: "some title",
        video_asset_id: "some video_asset_id",
        video_provider: :mux
      })
      |> Kubuni.Catalog.create_lecture()

    lecture
  end
end
