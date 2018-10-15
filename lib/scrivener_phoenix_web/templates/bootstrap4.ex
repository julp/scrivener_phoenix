defmodule Scrivener.Phoenix.Template.Bootstrap4 do
  @moduledoc ~S"""
  A ready to use template for a Bootstrap4 pagination.
  """

  use Scrivener.Phoenix.Template
  alias Scrivener.Phoenix.Gap
  alias Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Gettext

  def first_page(_page, %Scrivener.Page{page_number: 1}), do: nil
  def first_page(page = %Page{}, _spage) do
    content_tag(:li, class: "page-item") do
      link("«", to: page.href, class: "page-link", title: dgettext("scrivener_phoenix", "First page"))
    end
  end

if false do
  def last_page(page = %Page{}, spage = %Scrivener.Page{}) do
    if !Page.last_page?(page, spage) do
      content_tag(:li, class: "page-item") do
        link("»", to: page.href, class: "page-link", title: dgettext("scrivener_phoenix", "Last page"))
      end
    end
  end
else
  def last_page(%Page{no: no}, %Scrivener.Page{total_pages: no}), do: nil
  def last_page(page = %Page{}, _spage) do
    content_tag(:li, class: "page-item") do
      link("»", to: page.href, class: "page-link", title: dgettext("scrivener_phoenix", "Last page"))
    end
  end
end

  def prev_page(nil), do: nil
  def prev_page(page = %Page{}) do
    content_tag(:li, class: "page-item") do
      link("‹", to: page.href, class: "page-link", rel: "prev", title: dgettext("scrivener_phoenix", "Previous page"))
    end
  end

  def next_page(nil), do: nil
  def next_page(page = %Page{}) do
    content_tag(:li, class: "page-item") do
      link("›", to: page.href, class: "page-link", rel: "next", title: dgettext("scrivener_phoenix", "Next page"))
    end
  end

if false do
  def page(page = %Page{}, spage = %Scrivener.Page{}) do
    if Page.current?(page, spage) do
      content_tag(:li, class: "page-item active") do
        page.no
      end
    else
      content_tag(:li, class: "page-item") do
        link(page.no, handle_rel(page, spage, to: page.href, class: "page-link"))
      end
    end
  end
else
  def page(page = %Page{no: no}, %Scrivener.Page{page_number: no}) do
    content_tag(:li, class: "page-item active") do
      page.no
    end
  end

  def page(page = %Page{}, spage = %Scrivener.Page{}) do
    content_tag(:li, class: "page-item") do
      link(page.no, handle_rel(page, spage, to: page.href, class: "page-link"))
    end
  end
end

  def page(%Gap{}, %Scrivener.Page{}) do
    content_tag(:li, link("…", to: "#", class: "page-link"), class: "page-item disabled")
  end

  def wrap(links) do
    content_tag(:nav) do
      content_tag(:ul, class: "pagination") do
        links
      end
    end
  end
end
