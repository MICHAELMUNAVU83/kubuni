defmodule KubuniWeb.HomeLive do
  use KubuniWeb, :live_view

  import KubuniWeb.HomeComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Kubuni Business Institute")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-4 bg-slate-50 text-slate-900">
      <.home_header />
      <main>
        <.hero />
        <.top_courses_section />
        <.why_choose_us />
        <.popular_courses />
        <.digital_skills />
        <.mentors />
        <.testimonials />
        <.faqs />
        <.blog />
        <.cta />
      </main>
      <.footer />
    </div>
    """
  end
end
