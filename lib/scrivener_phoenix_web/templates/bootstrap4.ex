defmodule Scrivener.Phoenix.Template.Bootstrap4 do
  use Scrivener.Phoenix.Template
  alias Scrivener.Phoenix.Gap
  alias Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Page

  # TODO: temporary
  def dgettext(_domain, msgid) do
    msgid
  end

  def first_page(page = %Page{}) do
    content = "«"
    content_tag(:li, class: "page-item") do
      #if Page.first_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", title: dgettext("scrivener_phoenix", "first"))
      #end
    end
  end

  def last_page(page = %Page{}) do
    content = "»"
    content_tag(:li, class: "page-item") do
      #if Page.last_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", title: dgettext("scrivener_phoenix", "last"))
      #end
    end
  end

  def prev_page(page = %Page{}) do
    content = "‹"
    content_tag(:li, class: "page-item") do
      #if Page.first_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", rel: "prev", title: dgettext("scrivener_phoenix", "previous"))
      #end
    end
  end

  def next_page(page = %Page{}) do
    content = "›"
    content_tag(:li, class: "page-item") do
      #if Page.last_page?(page) do
        #content
      #else
        link(content, to: page.href, class: "page-link", rel: "next", title: dgettext("scrivener_phoenix", "next"))
      #end
    end
  end

  def page(page = %Page{no: no}, %Scrivener.Page{page_number: no}) do
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

  def page(page = %Page{}, spage = %Scrivener.Page{}) do
    content_tag(:li, class: "page-item") do
      link(page.no, handle_rel(page, spage, to: page.href, class: "page-link"))
    end
  end

  def page(%Gap{}, %Scrivener.Page{}) do
    # TODO: gettext
    content_tag(:li, link("…", to: "#", class: "page-link"), class: "page-item disabled")
  end

  def paginator(links) do
    content_tag(:nav) do
      content_tag(:ul, class: "pagination") do
        links
      end
    end
  end
end
