defmodule Kubuni.Learning do
  @moduledoc """
  The Learning context.
  """

  import Ecto.Query, warn: false
  alias Kubuni.Repo

  alias Kubuni.Learning.LectureProgress

  @doc """
  Returns the list of lecture_progress.

  ## Examples

      iex> list_lecture_progress()
      [%LectureProgress{}, ...]

  """
  def list_lecture_progress do
    Repo.all(LectureProgress)
  end

  @doc """
  Gets a single lecture_progress.

  Raises `Ecto.NoResultsError` if the Lecture progress does not exist.

  ## Examples

      iex> get_lecture_progress!(123)
      %LectureProgress{}

      iex> get_lecture_progress!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lecture_progress!(id), do: Repo.get!(LectureProgress, id)

  @doc """
  Creates a lecture_progress.

  ## Examples

      iex> create_lecture_progress(%{field: value})
      {:ok, %LectureProgress{}}

      iex> create_lecture_progress(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lecture_progress(attrs \\ %{}) do
    %LectureProgress{}
    |> LectureProgress.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lecture_progress.

  ## Examples

      iex> update_lecture_progress(lecture_progress, %{field: new_value})
      {:ok, %LectureProgress{}}

      iex> update_lecture_progress(lecture_progress, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lecture_progress(%LectureProgress{} = lecture_progress, attrs) do
    lecture_progress
    |> LectureProgress.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lecture_progress.

  ## Examples

      iex> delete_lecture_progress(lecture_progress)
      {:ok, %LectureProgress{}}

      iex> delete_lecture_progress(lecture_progress)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lecture_progress(%LectureProgress{} = lecture_progress) do
    Repo.delete(lecture_progress)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lecture_progress changes.

  ## Examples

      iex> change_lecture_progress(lecture_progress)
      %Ecto.Changeset{data: %LectureProgress{}}

  """
  def change_lecture_progress(%LectureProgress{} = lecture_progress, attrs \\ %{}) do
    LectureProgress.changeset(lecture_progress, attrs)
  end
end
