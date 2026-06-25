defmodule Kubuni.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Kubuni.Repo

  alias Kubuni.Catalog.Course

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  alias Kubuni.Catalog.CourseModule

  @doc """
  Returns the list of modules.

  ## Examples

      iex> list_modules()
      [%CourseModule{}, ...]

  """
  def list_modules do
    Repo.all(CourseModule)
  end

  @doc """
  Gets a single course_module.

  Raises `Ecto.NoResultsError` if the Course module does not exist.

  ## Examples

      iex> get_course_module!(123)
      %CourseModule{}

      iex> get_course_module!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course_module!(id), do: Repo.get!(CourseModule, id)

  @doc """
  Creates a course_module.

  ## Examples

      iex> create_course_module(%{field: value})
      {:ok, %CourseModule{}}

      iex> create_course_module(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course_module(attrs \\ %{}) do
    %CourseModule{}
    |> CourseModule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course_module.

  ## Examples

      iex> update_course_module(course_module, %{field: new_value})
      {:ok, %CourseModule{}}

      iex> update_course_module(course_module, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course_module(%CourseModule{} = course_module, attrs) do
    course_module
    |> CourseModule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course_module.

  ## Examples

      iex> delete_course_module(course_module)
      {:ok, %CourseModule{}}

      iex> delete_course_module(course_module)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course_module(%CourseModule{} = course_module) do
    Repo.delete(course_module)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course_module changes.

  ## Examples

      iex> change_course_module(course_module)
      %Ecto.Changeset{data: %CourseModule{}}

  """
  def change_course_module(%CourseModule{} = course_module, attrs \\ %{}) do
    CourseModule.changeset(course_module, attrs)
  end

  alias Kubuni.Catalog.Lecture

  @doc """
  Returns the list of lectures.

  ## Examples

      iex> list_lectures()
      [%Lecture{}, ...]

  """
  def list_lectures do
    Repo.all(Lecture)
  end

  @doc """
  Gets a single lecture.

  Raises `Ecto.NoResultsError` if the Lecture does not exist.

  ## Examples

      iex> get_lecture!(123)
      %Lecture{}

      iex> get_lecture!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lecture!(id), do: Repo.get!(Lecture, id)

  @doc """
  Creates a lecture.

  ## Examples

      iex> create_lecture(%{field: value})
      {:ok, %Lecture{}}

      iex> create_lecture(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lecture(attrs \\ %{}) do
    %Lecture{}
    |> Lecture.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lecture.

  ## Examples

      iex> update_lecture(lecture, %{field: new_value})
      {:ok, %Lecture{}}

      iex> update_lecture(lecture, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lecture(%Lecture{} = lecture, attrs) do
    lecture
    |> Lecture.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lecture.

  ## Examples

      iex> delete_lecture(lecture)
      {:ok, %Lecture{}}

      iex> delete_lecture(lecture)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lecture(%Lecture{} = lecture) do
    Repo.delete(lecture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lecture changes.

  ## Examples

      iex> change_lecture(lecture)
      %Ecto.Changeset{data: %Lecture{}}

  """
  def change_lecture(%Lecture{} = lecture, attrs \\ %{}) do
    Lecture.changeset(lecture, attrs)
  end
end
