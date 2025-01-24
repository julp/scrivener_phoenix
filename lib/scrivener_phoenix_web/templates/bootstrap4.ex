defmodule Scrivener.Phoenix.Template.Bootstrap4 do
  @moduledoc ~S"""
  A ready to use template for a Bootstrap4 pagination.
  """

  use Scrivener.Phoenix.Template
  alias Scrivener.Phoenix.Gap
  alias Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Page
  use Gettext, backend: Scrivener.Phoenix.Gettext

  defp li_wrap(content, options) do
    {_old_value, options} =
      options
      |> Keyword.get_and_update(:class, fn current -> {current, Enum.join(["page-item", current], " ")} end)

    content_tag(:li, content, options)
  end

  defp build_element(text, href, options, child_html_attrs, parent_html_attrs \\ []) do
    text
    |> link_callback(options).(Keyword.merge(child_html_attrs, [to: href, class: "page-link"]))
    |> li_wrap(parent_html_attrs)
  end

#   @impl Scrivener.Phoenix.Template
#   def first_page(_page, %Scrivener.Page{page_number: 1}, %{}), do: nil

#   def first_page(page = %Page{}, _spage, options = %{}) do
#     build_element(options.labels.first, page.href, options, title: dgettext("scrivener_phoenix", "First page"))
#   end

#   @impl Scrivener.Phoenix.Template
#   if false do
#     def last_page(page = %Page{}, spage = %Scrivener.Page{}, options = %{}) do
#       unless Page.last_page?(page, spage) do
#         build_element(options.labels.last, page.href, options, title: dgettext("scrivener_phoenix", "Last page"))
#       end
#     end
#   else
#     def last_page(%Page{}, %Scrivener.Page{page_number: no, total_pages: no}, %{}), do: nil

#     def last_page(page = %Page{}, _spage, options = %{}) do
#       build_element(options.labels.last, page.href, options, title: dgettext("scrivener_phoenix", "Last page"))
#     end
#   end

#   @impl Scrivener.Phoenix.Template
#   def prev_page(nil, %{}), do: nil

#   def prev_page(page = %Page{}, options = %{}) do
#     build_element(options.labels.prev, page.href, options, title: dgettext("scrivener_phoenix", "Previous page"), rel: "prev")
#   end

#   @impl Scrivener.Phoenix.Template
#   def next_page(nil, %{}), do: nil

#   def next_page(page = %Page{}, options = %{}) do
#     build_element(options.labels.next, page.href, options, title: dgettext("scrivener_phoenix", "Next page"), rel: "next")
#   end

  @impl Scrivener.Phoenix.Template

  # href = page.href/"#"
  # label = page.no/"..."/options.labels.{first/prev/next/last}
  # left_symbol = "<"/"<<" (options.symbols)
  # right_symbol = ">"/">>" (options.symbols)
  # title = "{Fist/Last/Next/Previous} page"
  # rel = nil/"prev" if page.prev?/"next" if page.next?
  # class = "disabled" if page.current?

  def page(page = %Page{}, label, left_symbol, right_symbol) do
#     ~H"""
#     <li>
#       <.link [href: @href] rel={rel(@page)} title={}><%= if @left_symbol do %><%= @left_symbol %>&nbsp;<% end %><%= @label %><%= if @right_symbol do %>&nbsp;<%= @right_symbol %><% end %></.link>
#     </li>
#     """

    full_label =
      [left_symbol, label, right_symbol]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\u00A0")

    build_element(full_label, page.href, %{options: "TODO"}, rel: "TODO")
  end

  def page(%Gap{}, label, _left_symbol, _right_symbol) do
    build_element("…", "#", %{options: "TODO"}, [], class: "disabled")
  end

  @impl Scrivener.Phoenix.Template
  def wrap(links) do
    content_tag(:nav) do
      content_tag(:ul, class: "pagination") do
        links
      end
    end
  end
end
