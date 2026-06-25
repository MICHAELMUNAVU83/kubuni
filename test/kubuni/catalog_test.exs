defmodule Kubuni.CatalogTest do
  use Kubuni.DataCase

  alias Kubuni.Catalog

  describe "courses" do
    alias Kubuni.Catalog.Course

    import Kubuni.CatalogFixtures

    @invalid_attrs %{
      position: nil,
      status: nil,
      description: nil,
      title: nil,
      currency: nil,
      slug: nil,
      subtitle: nil,
      thumbnail_key: nil,
      price_minor: nil
    }

    test "list_courses/0 returns all courses" do
      course = course_fixture()
      assert Catalog.list_courses() == [course]
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Catalog.get_course!(course.id) == course
    end

    test "create_course/1 with valid data creates a course" do
      valid_attrs = %{
        position: 42,
        status: :draft,
        description: "some description",
        title: "some title",
        currency: "some currency",
        slug: "some slug",
        subtitle: "some subtitle",
        thumbnail_key: "some thumbnail_key",
        price_minor: 42
      }

      assert {:ok, %Course{} = course} = Catalog.create_course(valid_attrs)
      assert course.position == 42
      assert course.status == :draft
      assert course.description == "some description"
      assert course.title == "some title"
      assert course.currency == "some currency"
      assert course.slug == "some slug"
      assert course.subtitle == "some subtitle"
      assert course.thumbnail_key == "some thumbnail_key"
      assert course.price_minor == 42
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_course(@invalid_attrs)
    end

    test "update_course/2 with valid data updates the course" do
      course = course_fixture()

      update_attrs = %{
        position: 43,
        status: :published,
        description: "some updated description",
        title: "some updated title",
        currency: "some updated currency",
        slug: "some updated slug",
        subtitle: "some updated subtitle",
        thumbnail_key: "some updated thumbnail_key",
        price_minor: 43
      }

      assert {:ok, %Course{} = course} = Catalog.update_course(course, update_attrs)
      assert course.position == 43
      assert course.status == :published
      assert course.description == "some updated description"
      assert course.title == "some updated title"
      assert course.currency == "some updated currency"
      assert course.slug == "some updated slug"
      assert course.subtitle == "some updated subtitle"
      assert course.thumbnail_key == "some updated thumbnail_key"
      assert course.price_minor == 43
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = course_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_course(course, @invalid_attrs)
      assert course == Catalog.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      assert {:ok, %Course{}} = Catalog.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_course!(course.id) end
    end

    test "change_course/1 returns a course changeset" do
      course = course_fixture()
      assert %Ecto.Changeset{} = Catalog.change_course(course)
    end
  end

  describe "modules" do
    alias Kubuni.Catalog.CourseModule

    import Kubuni.CatalogFixtures

    @invalid_attrs %{position: nil, description: nil, title: nil}

    test "list_modules/0 returns all modules" do
      course_module = course_module_fixture()
      assert Catalog.list_modules() == [course_module]
    end

    test "get_course_module!/1 returns the course_module with given id" do
      course_module = course_module_fixture()
      assert Catalog.get_course_module!(course_module.id) == course_module
    end

    test "create_course_module/1 with valid data creates a course_module" do
      valid_attrs = %{position: 42, description: "some description", title: "some title"}

      assert {:ok, %CourseModule{} = course_module} = Catalog.create_course_module(valid_attrs)
      assert course_module.position == 42
      assert course_module.description == "some description"
      assert course_module.title == "some title"
    end

    test "create_course_module/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_course_module(@invalid_attrs)
    end

    test "update_course_module/2 with valid data updates the course_module" do
      course_module = course_module_fixture()

      update_attrs = %{
        position: 43,
        description: "some updated description",
        title: "some updated title"
      }

      assert {:ok, %CourseModule{} = course_module} =
               Catalog.update_course_module(course_module, update_attrs)

      assert course_module.position == 43
      assert course_module.description == "some updated description"
      assert course_module.title == "some updated title"
    end

    test "update_course_module/2 with invalid data returns error changeset" do
      course_module = course_module_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Catalog.update_course_module(course_module, @invalid_attrs)

      assert course_module == Catalog.get_course_module!(course_module.id)
    end

    test "delete_course_module/1 deletes the course_module" do
      course_module = course_module_fixture()
      assert {:ok, %CourseModule{}} = Catalog.delete_course_module(course_module)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_course_module!(course_module.id) end
    end

    test "change_course_module/1 returns a course_module changeset" do
      course_module = course_module_fixture()
      assert %Ecto.Changeset{} = Catalog.change_course_module(course_module)
    end
  end

  describe "lectures" do
    alias Kubuni.Catalog.Lecture

    import Kubuni.CatalogFixtures

    @invalid_attrs %{
      position: nil,
      description: nil,
      title: nil,
      video_provider: nil,
      video_asset_id: nil,
      duration_seconds: nil
    }

    test "list_lectures/0 returns all lectures" do
      lecture = lecture_fixture()
      assert Catalog.list_lectures() == [lecture]
    end

    test "get_lecture!/1 returns the lecture with given id" do
      lecture = lecture_fixture()
      assert Catalog.get_lecture!(lecture.id) == lecture
    end

    test "create_lecture/1 with valid data creates a lecture" do
      valid_attrs = %{
        position: 42,
        description: "some description",
        title: "some title",
        video_provider: :mux,
        video_asset_id: "some video_asset_id",
        duration_seconds: 42
      }

      assert {:ok, %Lecture{} = lecture} = Catalog.create_lecture(valid_attrs)
      assert lecture.position == 42
      assert lecture.description == "some description"
      assert lecture.title == "some title"
      assert lecture.video_provider == :mux
      assert lecture.video_asset_id == "some video_asset_id"
      assert lecture.duration_seconds == 42
    end

    test "create_lecture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_lecture(@invalid_attrs)
    end

    test "update_lecture/2 with valid data updates the lecture" do
      lecture = lecture_fixture()

      update_attrs = %{
        position: 43,
        description: "some updated description",
        title: "some updated title",
        video_provider: :cloudflare,
        video_asset_id: "some updated video_asset_id",
        duration_seconds: 43
      }

      assert {:ok, %Lecture{} = lecture} = Catalog.update_lecture(lecture, update_attrs)
      assert lecture.position == 43
      assert lecture.description == "some updated description"
      assert lecture.title == "some updated title"
      assert lecture.video_provider == :cloudflare
      assert lecture.video_asset_id == "some updated video_asset_id"
      assert lecture.duration_seconds == 43
    end

    test "update_lecture/2 with invalid data returns error changeset" do
      lecture = lecture_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_lecture(lecture, @invalid_attrs)
      assert lecture == Catalog.get_lecture!(lecture.id)
    end

    test "delete_lecture/1 deletes the lecture" do
      lecture = lecture_fixture()
      assert {:ok, %Lecture{}} = Catalog.delete_lecture(lecture)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_lecture!(lecture.id) end
    end

    test "change_lecture/1 returns a lecture changeset" do
      lecture = lecture_fixture()
      assert %Ecto.Changeset{} = Catalog.change_lecture(lecture)
    end
  end
end
