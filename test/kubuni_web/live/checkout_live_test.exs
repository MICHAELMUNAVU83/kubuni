defmodule KubuniWeb.CheckoutLiveTest do
  use KubuniWeb.ConnCase

  import Phoenix.LiveViewTest
  import Mox
  import Kubuni.CatalogFixtures

  alias Kubuni.Enrollments

  setup :verify_on_exit!
  setup :register_and_log_in_user

  test "renders the hosted checkout handoff", %{conn: conn} do
    course = course_fixture(status: :published, price_minor: 80_000)

    assert {:ok, view, html} = live(conn, ~p"/courses/#{course.slug}/checkout")
    assert html =~ "Enroll &amp; Pay"
    assert has_element?(view, "#pay-with-paystack")
  end

  test "starts Paystack and redirects to its hosted checkout", %{conn: conn} do
    course = course_fixture(status: :published, price_minor: 80_000)

    expect(Kubuni.Payments.ProviderMock, :initiate, fn payment ->
      {:ok,
       %{
         "authorization_url" => "https://checkout.paystack.test/hosted",
         "access_code" => "access",
         "reference" => payment.provider_reference
       }}
    end)

    {:ok, view, _html} = live(conn, ~p"/courses/#{course.slug}/checkout")
    view |> element("#pay-with-paystack") |> render_click()

    assert_redirect(view, "https://checkout.paystack.test/hosted")
  end

  test "redirects when PubSub confirms this course enrollment", %{conn: conn, user: user} do
    course = course_fixture(status: :published, price_minor: 80_000)
    {:ok, view, _html} = live(conn, ~p"/courses/#{course.slug}/checkout")
    {:ok, pending} = Enrollments.create_pending_enrollment(user, course)
    {:ok, active} = Enrollments.activate_enrollment(pending)

    send(view.pid, {:payment_confirmed, active})

    assert_redirect(view, ~p"/learn/courses/#{course.slug}")
  end
end
