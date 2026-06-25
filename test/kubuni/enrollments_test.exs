defmodule Kubuni.EnrollmentsTest do
  use Kubuni.DataCase

  alias Kubuni.Enrollments

  describe "enrollments" do
    alias Kubuni.Enrollments.Enrollment

    import Kubuni.EnrollmentsFixtures

    @invalid_attrs %{status: nil, enrolled_at: nil, activated_at: nil}

    test "list_enrollments/0 returns all enrollments" do
      enrollment = enrollment_fixture()
      assert Enrollments.list_enrollments() == [enrollment]
    end

    test "get_enrollment!/1 returns the enrollment with given id" do
      enrollment = enrollment_fixture()
      assert Enrollments.get_enrollment!(enrollment.id) == enrollment
    end

    test "create_enrollment/1 with valid data creates a enrollment" do
      valid_attrs = %{
        status: :pending,
        enrolled_at: ~U[2026-06-24 10:02:00Z],
        activated_at: ~U[2026-06-24 10:02:00Z]
      }

      assert {:ok, %Enrollment{} = enrollment} = Enrollments.create_enrollment(valid_attrs)
      assert enrollment.status == :pending
      assert enrollment.enrolled_at == ~U[2026-06-24 10:02:00Z]
      assert enrollment.activated_at == ~U[2026-06-24 10:02:00Z]
    end

    test "create_enrollment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Enrollments.create_enrollment(@invalid_attrs)
    end

    test "update_enrollment/2 with valid data updates the enrollment" do
      enrollment = enrollment_fixture()

      update_attrs = %{
        status: :active,
        enrolled_at: ~U[2026-06-25 10:02:00Z],
        activated_at: ~U[2026-06-25 10:02:00Z]
      }

      assert {:ok, %Enrollment{} = enrollment} =
               Enrollments.update_enrollment(enrollment, update_attrs)

      assert enrollment.status == :active
      assert enrollment.enrolled_at == ~U[2026-06-25 10:02:00Z]
      assert enrollment.activated_at == ~U[2026-06-25 10:02:00Z]
    end

    test "update_enrollment/2 with invalid data returns error changeset" do
      enrollment = enrollment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Enrollments.update_enrollment(enrollment, @invalid_attrs)

      assert enrollment == Enrollments.get_enrollment!(enrollment.id)
    end

    test "delete_enrollment/1 deletes the enrollment" do
      enrollment = enrollment_fixture()
      assert {:ok, %Enrollment{}} = Enrollments.delete_enrollment(enrollment)
      assert_raise Ecto.NoResultsError, fn -> Enrollments.get_enrollment!(enrollment.id) end
    end

    test "change_enrollment/1 returns a enrollment changeset" do
      enrollment = enrollment_fixture()
      assert %Ecto.Changeset{} = Enrollments.change_enrollment(enrollment)
    end
  end
end
