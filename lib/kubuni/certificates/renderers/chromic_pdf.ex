defmodule Kubuni.Certificates.Renderers.ChromicPDF do
  @moduledoc """
  Production certificate renderer backed by ChromicPDF.
  """

  @behaviour Kubuni.Certificates.Renderer

  alias Kubuni.Certificates.Template

  @impl true
  def render(assigns) do
    html = Template.render_html(assigns)

    case ChromicPDF.print_to_pdf({:html, html},
           output: &File.read!/1,
           print_to_pdf: %{
             printBackground: true,
             landscape: true,
             paperWidth: 11.69,
             paperHeight: 8.27,
             marginTop: 0,
             marginBottom: 0,
             marginLeft: 0,
             marginRight: 0
           },
           info: %{
             title: "Kubuni Certificate · #{assigns.title}",
             author: "Kubuni Business Institute",
             subject: assigns.type_label
           }
         ) do
      {:ok, pdf} when is_binary(pdf) -> {:ok, pdf}
      {:error, reason} -> {:error, reason}
    end
  rescue
    error -> {:error, error}
  end
end
