defmodule KubuniWeb.LectureLive.FormComponent do
  use KubuniWeb, :live_component

  alias Kubuni.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage lecture records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="lecture-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input
          field={@form[:video_provider]}
          type="select"
          label="Video provider"
          prompt="Choose a value"
          options={Ecto.Enum.values(Kubuni.Catalog.Lecture, :video_provider)}
        />
        <.input field={@form[:video_asset_id]} type="text" label="Video asset" />
        <.input field={@form[:duration_seconds]} type="number" label="Duration seconds" />
        <.input field={@form[:position]} type="number" label="Position" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Lecture</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{lecture: lecture} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Catalog.change_lecture(lecture))
     end)}
  end

  @impl true
  def handle_event("validate", %{"lecture" => lecture_params}, socket) do
    changeset = Catalog.change_lecture(socket.assigns.lecture, lecture_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"lecture" => lecture_params}, socket) do
    save_lecture(socket, socket.assigns.action, lecture_params)
  end

  defp save_lecture(socket, :edit, lecture_params) do
    case Catalog.update_lecture(socket.assigns.lecture, lecture_params) do
      {:ok, lecture} ->
        notify_parent({:saved, lecture})

        {:noreply,
         socket
         |> put_flash(:info, "Lecture updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_lecture(socket, :new, lecture_params) do
    case Catalog.create_lecture(lecture_params) do
      {:ok, lecture} ->
        notify_parent({:saved, lecture})

        {:noreply,
         socket
         |> put_flash(:info, "Lecture created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
