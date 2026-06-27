defmodule KubuniWeb.CheckoutLive do
  use KubuniWeb, :live_view

  alias Kubuni.{Catalog, Enrollments, Payments}

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    course = Catalog.get_published_course_by_slug!(slug)
    user = socket.assigns.current_user

    if connected?(socket), do: Payments.subscribe(user)

    if Enrollments.can_access_course?(user, course) do
      {:ok, redirect(socket, to: ~p"/learn/courses/#{course.slug}")}
    else
      {:ok,
       socket
       |> assign(:page_title, "Checkout · #{course.title}")
       |> assign(:course, course)
       |> assign(:submitting, false)
       |> assign(:waiting, false)}
    end
  end

  @impl true
  def handle_event("pay", _params, socket) do
    socket = assign(socket, :submitting, true)

    case Payments.initialize_checkout(socket.assigns.current_user, socket.assigns.course) do
      {:ok, %{authorization_url: url}} ->
        {:noreply, redirect(socket, external: url)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(:submitting, false)
         |> put_flash(:error, "Paystack checkout could not be started. Please try again.")}
    end
  end

  @impl true
  def handle_info({:payment_confirmed, enrollment}, socket) do
    if enrollment.course_id == socket.assigns.course.id do
      {:noreply, redirect(socket, to: ~p"/learn/courses/#{socket.assigns.course.slug}")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_params(%{"status" => "waiting"}, _uri, socket),
    do: {:noreply, assign(socket, :waiting, true)}

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <.student_layout active={:courses} current_user={@current_user}>
      <div class="bg-gradient-to-b from-mint via-white to-soft py-16">
        <div class="mx-auto max-w-2xl px-5">
        <.link navigate={~p"/courses/#{@course.slug}"} class="text-sm font-medium text-primary">
          ← Back to course
        </.link>

        <section class="mt-6 rounded-[32px] border border-black/5 bg-white p-7 shadow-xl sm:p-10">
          <span class="rounded-full bg-mint px-3 py-1 text-sm font-medium text-primary">
            Secure checkout
          </span>
          <h1 class="mt-5 text-3xl font-semibold text-dark sm:text-4xl">Enroll in {@course.title}</h1>
          <p class="mt-3 text-body">
            You will pay on Paystack's hosted checkout. Kubuni never receives or stores your card details.
          </p>

          <div class="mt-8 flex items-center justify-between rounded-2xl bg-soft p-5">
            <span class="font-medium text-dark">One-time course fee</span>
            <span class="text-2xl font-semibold text-dark">{Catalog.format_price(@course)}</span>
          </div>

          <div :if={@waiting} id="payment-waiting" class="mt-6 rounded-2xl bg-mint p-5 text-body">
            Payment confirmation is still processing. You can leave this page; access will unlock
            automatically as soon as Paystack confirms it.
          </div>

          <button
            id="pay-with-paystack"
            phx-click="pay"
            disabled={@submitting}
            class="mt-7 w-full rounded-full bg-dark px-6 py-4 font-medium text-white transition hover:bg-primary disabled:cursor-wait disabled:opacity-60"
          >
            {if @submitting, do: "Opening Paystack…", else: "Enroll & Pay"}
          </button>
        </section>
        </div>
      </div>
    </.student_layout>
    """
  end
end
