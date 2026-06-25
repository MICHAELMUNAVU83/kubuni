defmodule KubuniWeb.DashboardLive do
  use KubuniWeb, :live_view

  alias Kubuni.{Certificates, Enrollments, Learning, Payments}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Learning.subscribe(socket.assigns.current_user)
      Payments.subscribe(socket.assigns.current_user)
    end

    {:ok,
     socket
     |> assign(:page_title, "My learning")
     |> refresh_dashboard()}
  end

  @impl true
  def handle_info({event, _subject}, socket)
      when event in [
             :lecture_completed,
             :module_completed,
             :course_completed,
             :certificate_ready,
             :payment_confirmed
           ] do
    {:noreply, refresh_dashboard(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="learner-dashboard" class="min-h-screen bg-soft text-dark">
      <header class="border-b border-black/5 bg-white">
        <div class="mx-auto flex max-w-container flex-wrap items-center justify-between gap-4 px-5 py-5 lg:px-8">
          <.link navigate={~p"/"} class="flex items-center gap-3 font-bold text-dark">
            <span class="grid h-10 w-10 place-items-center rounded-[10px] bg-primary text-white">
              K
            </span>
            <span>Kubuni</span>
          </.link>
          <nav class="flex items-center gap-5 text-sm font-medium">
            <.link navigate={~p"/courses"} class="text-dark transition hover:text-primary">
              Browse courses
            </.link>
            <.link navigate={~p"/users/settings"} class="text-dark transition hover:text-primary">
              Account
            </.link>
          </nav>
        </div>
      </header>

      <main>
        <section class="bg-gradient-to-b from-mint via-white to-soft py-14 lg:py-20">
          <div class="mx-auto max-w-container px-5 lg:px-8">
            <span class="rounded-full bg-mint px-3 py-1 text-sm font-medium text-primary">
              Learner dashboard
            </span>
            <h1 class="mt-5 text-4xl font-semibold leading-[1.1] text-dark sm:text-5xl">
              Welcome back, {first_name(@current_user.name)}.
            </h1>
            <p class="mt-4 max-w-2xl text-lg text-body">
              Continue learning, track your progress, and keep your achievements in one place.
            </p>
          </div>
        </section>

        <section class="pb-20 lg:pb-28">
          <div class="mx-auto max-w-container space-y-12 px-5 lg:px-8">
            <div>
              <div class="flex flex-wrap items-end justify-between gap-4">
                <div>
                  <p class="text-sm font-semibold uppercase tracking-wider text-primary">
                    My courses
                  </p>
                  <h2 class="mt-2 text-3xl font-semibold text-dark">Pick up where you left off.</h2>
                </div>
                <span :if={@course_cards != []} class="text-sm text-muted">
                  {length(@course_cards)} {pluralize(length(@course_cards), "course")}
                </span>
              </div>

              <div
                :if={@course_cards != []}
                id="dashboard-courses"
                class="mt-7 grid gap-7 lg:grid-cols-2"
              >
                <article
                  :for={card <- @course_cards}
                  id={"dashboard-course-#{card.course.id}"}
                  class="overflow-hidden rounded-3xl border border-black/5 bg-white transition hover:shadow-xl"
                >
                  <div class="grid sm:grid-cols-[190px_minmax(0,1fr)]">
                    <img
                      src={card.course.thumbnail_key}
                      alt=""
                      class="h-48 w-full object-cover sm:h-full"
                    />
                    <div class="p-6">
                      <div class="flex items-center justify-between gap-4">
                        <span class="rounded-full bg-mint px-3 py-1 text-sm font-medium text-primary">
                          {progress_label(card)}
                        </span>
                        <span
                          id={"course-progress-#{card.course.id}"}
                          class="text-sm font-semibold text-primary"
                        >
                          {card.progress.percent}%
                        </span>
                      </div>

                      <h3 class="mt-5 text-xl font-semibold text-dark">{card.course.title}</h3>
                      <p :if={card.resume_lecture} class="mt-2 text-sm text-body">
                        Next: {card.resume_lecture.title}
                      </p>
                      <p :if={!card.resume_lecture} class="mt-2 text-sm text-body">
                        Course materials will appear here when lectures are added.
                      </p>

                      <div class="mt-5 h-2 overflow-hidden rounded-full bg-mint">
                        <div
                          class="h-full rounded-full bg-primary transition-all duration-500"
                          style={"width: #{card.progress.percent}%"}
                        >
                        </div>
                      </div>
                      <p class="mt-2 text-xs text-muted">
                        {card.progress.completed} of {card.progress.total} lectures completed
                      </p>

                      <.link
                        navigate={course_destination(card)}
                        class="group mt-6 inline-flex items-center gap-2 rounded-full bg-dark py-1.5 pl-6 pr-1.5 font-medium text-white transition hover:bg-primary"
                      >
                        {course_action(card)}
                        <span class="grid h-9 w-9 place-items-center rounded-full bg-primary text-white transition group-hover:bg-dark">
                          <.icon name="hero-arrow-right-mini" class="h-4 w-4" />
                        </span>
                      </.link>
                    </div>
                  </div>
                </article>
              </div>

              <div
                :if={@course_cards == []}
                id="dashboard-empty-courses"
                class="mt-7 rounded-3xl border border-black/5 bg-white p-8 text-center sm:p-12"
              >
                <span class="mx-auto grid h-14 w-14 place-items-center rounded-full bg-mint text-primary">
                  <.icon name="hero-academic-cap" class="h-7 w-7" />
                </span>
                <h3 class="mt-5 text-xl font-semibold text-dark">Your learning shelf is ready.</h3>
                <p class="mx-auto mt-2 max-w-lg text-body">
                  Enroll in a course and it will appear here as soon as payment is confirmed.
                </p>
                <.link
                  navigate={~p"/courses"}
                  class="mt-6 inline-flex rounded-full bg-dark px-6 py-3 font-medium text-white transition hover:bg-primary"
                >
                  Browse courses
                </.link>
              </div>
            </div>

            <div class="grid gap-7 lg:grid-cols-2">
              <section
                id="dashboard-certificates"
                class="rounded-3xl border border-black/5 bg-white p-6 sm:p-8"
              >
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <p class="text-sm font-semibold uppercase tracking-wider text-primary">
                      Achievements
                    </p>
                    <h2 class="mt-2 text-2xl font-semibold text-dark">Certificates</h2>
                  </div>
                  <span class="grid h-11 w-11 place-items-center rounded-full bg-mint text-primary">
                    <.icon name="hero-trophy" class="h-6 w-6" />
                  </span>
                </div>

                <div :if={@certificates != []} class="mt-6 divide-y divide-black/5">
                  <article
                    :for={certificate <- @certificates}
                    id={"dashboard-certificate-#{certificate.id}"}
                    class="flex flex-wrap items-center justify-between gap-4 py-4 first:pt-0 last:pb-0"
                  >
                    <div class="min-w-0">
                      <p class="text-xs font-medium uppercase tracking-wide text-muted">
                        {certificate_type(certificate)}
                      </p>
                      <h3 class="mt-1 truncate font-medium text-dark">
                        {certificate_title(certificate)}
                      </h3>
                      <p class="mt-1 text-xs text-muted">{certificate.serial_number}</p>
                    </div>
                    <.link
                      href={~p"/certificates/#{certificate.id}/download"}
                      class="inline-flex items-center gap-2 rounded-full border border-black/10 px-4 py-2 text-sm font-medium text-dark transition hover:border-primary hover:text-primary"
                    >
                      <.icon name="hero-arrow-down-tray" class="h-4 w-4" /> Download
                    </.link>
                  </article>
                </div>

                <p :if={@certificates == []} class="mt-6 rounded-2xl bg-soft p-5 text-body">
                  Certificates will appear here as you complete modules and courses.
                </p>
              </section>

              <section
                id="dashboard-receipts"
                class="rounded-3xl border border-black/5 bg-white p-6 sm:p-8"
              >
                <div class="flex items-start justify-between gap-4">
                  <div>
                    <p class="text-sm font-semibold uppercase tracking-wider text-primary">
                      Billing
                    </p>
                    <h2 class="mt-2 text-2xl font-semibold text-dark">Payment receipts</h2>
                  </div>
                  <span class="grid h-11 w-11 place-items-center rounded-full bg-mint text-primary">
                    <.icon name="hero-receipt-percent" class="h-6 w-6" />
                  </span>
                </div>

                <div :if={@receipts != []} class="mt-6 divide-y divide-black/5">
                  <article
                    :for={receipt <- @receipts}
                    id={"payment-receipt-#{receipt.id}"}
                    class="py-4 first:pt-0 last:pb-0"
                  >
                    <div class="flex items-start justify-between gap-4">
                      <div class="min-w-0">
                        <h3 class="truncate font-medium text-dark">{receipt.course.title}</h3>
                        <p class="mt-1 text-sm text-muted">
                          Paid {format_date(receipt.paid_at)} via {provider_name(receipt.provider)}
                        </p>
                      </div>
                      <p class="shrink-0 font-semibold text-dark">
                        {Payments.format_amount(receipt)}
                      </p>
                    </div>
                    <div class="mt-3 flex items-center justify-between gap-4 rounded-2xl bg-soft px-4 py-3 text-xs">
                      <span class="text-muted">Receipt reference</span>
                      <span class="break-all text-right font-medium text-dark">
                        {receipt.provider_reference}
                      </span>
                    </div>
                  </article>
                </div>

                <p :if={@receipts == []} class="mt-6 rounded-2xl bg-soft p-5 text-body">
                  Successful course payments will appear here.
                </p>
              </section>
            </div>
          </div>
        </section>
      </main>
    </div>
    """
  end

  defp refresh_dashboard(socket) do
    user = socket.assigns.current_user

    course_cards =
      user
      |> Enrollments.list_active_for_user()
      |> Enum.map(fn enrollment ->
        course = enrollment.course
        progress = Learning.course_progress(user, course)

        %{
          enrollment: enrollment,
          course: course,
          progress: progress,
          resume_lecture: resume_lecture(course, progress.progress),
          started?: map_size(progress.progress) > 0
        }
      end)

    socket
    |> assign(:course_cards, course_cards)
    |> assign(:certificates, Certificates.list_for_user(user))
    |> assign(:receipts, Payments.list_receipts_for_user(user))
  end

  defp first_name(name) when is_binary(name) do
    name
    |> String.trim()
    |> String.split()
    |> List.first()
    |> case do
      nil -> "learner"
      first_name -> first_name
    end
  end

  defp first_name(_name), do: "learner"

  defp progress_label(%{progress: %{complete?: true}}), do: "Completed"
  defp progress_label(%{started?: true}), do: "In progress"
  defp progress_label(_card), do: "Ready to start"

  defp course_action(%{progress: %{complete?: true}}), do: "Review course"
  defp course_action(%{started?: true}), do: "Continue learning"
  defp course_action(_card), do: "Start course"

  defp course_destination(%{resume_lecture: nil, course: course}), do: ~p"/courses/#{course.slug}"
  defp course_destination(%{course: course}), do: ~p"/learn/courses/#{course.slug}"

  defp resume_lecture(course, progress) do
    lectures = Enum.flat_map(course.modules, & &1.lectures)

    Enum.find(lectures, fn lecture ->
      case progress[lecture.id] do
        %{status: :completed} -> false
        _progress -> true
      end
    end) || List.last(lectures)
  end

  defp pluralize(1, word), do: word
  defp pluralize(_count, word), do: word <> "s"

  defp certificate_type(%{type: :module}), do: "Module certificate"
  defp certificate_type(%{type: :course}), do: "Course certificate"
  defp certificate_title(%{type: :module, module: module}), do: module.title
  defp certificate_title(%{type: :course, course: course}), do: course.title

  defp format_date(%DateTime{} = datetime), do: Calendar.strftime(datetime, "%B %-d, %Y")
  defp format_date(_datetime), do: "date unavailable"

  defp provider_name(:paystack), do: "Paystack"
  defp provider_name(:mpesa), do: "M-Pesa"
  defp provider_name(provider), do: provider |> to_string() |> String.capitalize()
end
