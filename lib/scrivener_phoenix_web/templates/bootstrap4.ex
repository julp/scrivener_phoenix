defmodule Scrivener.Phoenix.Template.Bootstrap4 do
  @moduledoc ~S"""
  A ready to use template for a Bootstrap4 pagination.
  """

  use Scrivener.Phoenix.Template
  use Gettext, backend: Scrivener.Phoenix.Gettext


  def link_callback(_live? = true) do
    &Phoenix.LiveView.Helpers.live_patch/2
  end

  def link_callback(_live?) do
    &PhoenixHTMLHelpers.Link.link/2
  end

  defp li_wrap(content, html_attrs) do
    {_old_value, html_attrs} =
      html_attrs
      |> Keyword.get_and_update(:class, fn current -> {current, Enum.join(["page-item", current], " ")} end)

    content_tag(:li, content, html_attrs)
  end

  defp build_element(text, href, live?, child_html_attrs, parent_html_attrs \\ []) do
    text
    |> link_callback(live?).(Keyword.merge(child_html_attrs, [to: href, class: "page-link"]))
    |> li_wrap(parent_html_attrs)
  end

  # href = page.href/"#"
  # label = page.no/"..."/options.labels.{first/prev/next/last}
  # left_symbol = "<"/"<<" (options.symbols)
  # right_symbol = ">"/">>" (options.symbols)
  # title = "{First/Last/Next/Previous} page"
  # rel = nil/"prev" if page.prev?/"next" if page.next?
  # class = "disabled" if page.current?

  defp rel_attribute_value(%Scrivener.Phoenix.Page{rel: :prev}), do: "prev"
  defp rel_attribute_value(%Scrivener.Phoenix.Page{rel: :next}), do: "next"
  defp rel_attribute_value(_), do: nil

  @impl Scrivener.Phoenix.Template
  def page(page = %Scrivener.Phoenix.Page{}, options, left_symbol, right_symbol) do
    full_label =
      [left_symbol, page.label, right_symbol]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\u00A0")

    build_element(full_label, page.rel == :current && "#" || page.href, options.live, [rel: rel_attribute_value(page)], [class: page.rel == :current && "disabled" || nil])
  end

  def page(%Scrivener.Phoenix.Gap{}, _options, _left_symbol, _right_symbol) do
    build_element("…", "#", false, [], class: "disabled")
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
