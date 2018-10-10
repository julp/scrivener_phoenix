defmodule Scrivener.Phoenix.Template.Bootstrap4 do
  use Scrivener.Phoenix.Template
  alias Scrivener.Phoenix.Gap
  alias Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Page

  # TODO: temporary
  defp dgettext(_domain, msgid) do
    msgid
  end

  # if we are on the first page, skip the link to it
  defp add_first_page(links, %{}, %Scrivener.Page{page_number: 1}) do
    links
  end

  defp add_first_page(links, %{first: first_page}, %Scrivener.Page{}) do
    [first_page(first_page) | links]
  end

  defp first_page(page = %Page{}) do
    content = "«"
    content_tag(:li, class: "page-item") do
      #if Page.first_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", title: dgettext("scrivener_phoenix", "first"))
      #end
    end
  end

  # if we are on the last page, skip the link to it
  defp add_last_page(links, %{}, %Scrivener.Page{page_number: no, total_pages: no}) do
    links
  end

  defp add_last_page(links, %{last: last_page}, %Scrivener.Page{}) do
    [last_page(last_page) | links]
  end

  defp last_page(page = %Page{}) do
    content = "»"
    content_tag(:li, class: "page-item") do
      #if Page.last_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", title: dgettext("scrivener_phoenix", "last"))
      #end
    end
  end

  defp add_prev_page(links, %{prev: nil}, %Scrivener.Page{}) do
    links
  end

  defp add_prev_page(links, %{prev: prev}, %Scrivener.Page{}) do
    [prev_page(prev) | links]
  end

  defp prev_page(page = %Page{}) do
    content = "‹"
    content_tag(:li, class: "page-item") do
      #if Page.first_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", rel: "prev", title: dgettext("scrivener_phoenix", "previous"))
      #end
    end
  end

  defp add_next_page(links, %{next: nil}, %Scrivener.Page{}) do
    links
  end

  defp add_next_page(links, %{next: next}, %Scrivener.Page{}) do
    [next_page(next) | links]
  end

  defp next_page(page = %Page{}) do
    content = "›"
    content_tag(:li, class: "page-item") do
      #if Page.last_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", rel: "next", title: dgettext("scrivener_phoenix", "next"))
      #end
    end
  end

  defp page(page = %Page{no: no}, %Scrivener.Page{page_number: no}) do
    #if Page.current?(page, spage) do
      content_tag(:li, class: "page-item active") do
        page.no
      end
    #else
      #content_tag(:li, class: "page-item") do
        #link(page.no, to: page.href, class: "page-link")
      #end
    #end
  end

  defp page(page = %Page{}, spage = %Scrivener.Page{}) do
    content_tag(:li, class: "page-item") do
      link(page.no, handle_rel(page, spage, to: page.href, class: "page-link"))
    end
  end

  defp page(%Gap{}, %Scrivener.Page{}) do
    # TODO: gettext
    content_tag(:li, link("…", to: "#", class: "page-link"), class: "page-item disabled")
  end

  defp add_pages(links, pages, spage = %Scrivener.Page{}) do
    pages
    |> Enum.reverse()
    |> Enum.into(links, fn page ->
      page(page, spage)
    end)
  end

  def paginator(pages = %{}, spage = %Scrivener.Page{}, _options = %{}) do
    content_tag(:nav) do
      content_tag(:ul, class: "pagination") do
        []
        |> add_next_page(pages, spage)
        |> add_last_page(pages, spage)
        |> add_pages(pages.pages, spage)
        |> Enum.reverse()
        |> add_prev_page(pages, spage)
        |> add_first_page(pages, spage)
      end
    end
  end
end
