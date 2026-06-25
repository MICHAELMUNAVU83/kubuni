defmodule Kubuni.LearningTest do
  use Kubuni.DataCase

  alias Kubuni.Learning

  describe "lecture_progress" do
    alias Kubuni.Learning.LectureProgress

    import Kubuni.LearningFixtures

    @invalid_attrs %{status: nil, last_position_seconds: nil, completed_at: nil}

    test "list_lecture_progress/0 returns all lecture_progress" do
      lecture_progress = lecture_progress_fixture()
      assert Learning.list_lecture_progress() == [lecture_progress]
    end

    test "get_lecture_progress!/1 returns the lecture_progress with given id" do
      lecture_progress = lecture_progress_fixture()
      assert Learning.get_lecture_progress!(lecture_progress.id) == lecture_progress
    end

    test "create_lecture_progress/1 with valid data creates a lecture_progress" do
      valid_attrs = %{
        status: :not_started,
        last_position_seconds: 42,
        completed_at: ~U[2026-06-24 10:02:00Z]
      }

      assert {:ok, %LectureProgress{} = lecture_progress} =
               Learning.create_lecture_progress(valid_attrs)

      assert lecture_progress.status == :not_started
      assert lecture_progress.last_position_seconds == 42
      assert lecture_progress.completed_at == ~U[2026-06-24 10:02:00Z]
    end

    test "create_lecture_progress/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Learning.create_lecture_progress(@invalid_attrs)
    end

    test "update_lecture_progress/2 with valid data updates the lecture_progress" do
      lecture_progress = lecture_progress_fixture()

      update_attrs = %{
        status: :in_progress,
        last_position_seconds: 43,
        completed_at: ~U[2026-06-25 10:02:00Z]
      }

      assert {:ok, %LectureProgress{} = lecture_progress} =
               Learning.update_lecture_progress(lecture_progress, update_attrs)

      assert lecture_progress.status == :in_progress
      assert lecture_progress.last_position_seconds == 43
      assert lecture_progress.completed_at == ~U[2026-06-25 10:02:00Z]
    end

    test "update_lecture_progress/2 with invalid data returns error changeset" do
      lecture_progress = lecture_progress_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Learning.update_lecture_progress(lecture_progress, @invalid_attrs)

      assert lecture_progress == Learning.get_lecture_progress!(lecture_progress.id)
    end

    test "delete_lecture_progress/1 deletes the lecture_progress" do
      lecture_progress = lecture_progress_fixture()
      assert {:ok, %LectureProgress{}} = Learning.delete_lecture_progress(lecture_progress)

      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_lecture_progress!(lecture_progress.id)
      end
    end

    test "change_lecture_progress/1 returns a lecture_progress changeset" do
      lecture_progress = lecture_progress_fixture()
      assert %Ecto.Changeset{} = Learning.change_lecture_progress(lecture_progress)
    end
  end
end
