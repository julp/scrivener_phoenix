defmodule Scrivener.Phoenix.Template.Bootstrap4 do
  @moduledoc ~S"""
  A ready to use template for a Bootstrap4 pagination.
  """

  use Scrivener.Phoenix.Template
  alias Scrivener.Phoenix.Gap
  alias Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Gettext

  defp li_wrap(content, options) do
    {_old_value, options} =
      options
      |> Keyword.get_and_update(:class, fn current -> {current, Enum.join(["page-item", current], " ")} end)

    content_tag(:li, content, options)
  end

  defp build_element(text, href, options, parent_options \\ []) do
    text
    |> link(Keyword.merge(options, [to: href, class: "page-link"]))
    |> li_wrap(parent_options)
  end

  @impl Scrivener.Phoenix.Template
  def first_page(_page, %Scrivener.Page{page_number: 1}, %{}), do: nil

  def first_page(page = %Page{}, _spage, options = %{}) do
    build_element(options.labels.first, page.href, title: dgettext("scrivener_phoenix", "First page"))
  end

  @impl Scrivener.Phoenix.Template
  if false do
    def last_page(page = %Page{}, spage = %Scrivener.Page{}, options = %{}) do
      unless Page.last_page?(page, spage) do
        build_element(options.labels.last, page.href, title: dgettext("scrivener_phoenix", "Last page"))
      end
    end
  else
    def last_page(%Page{}, %Scrivener.Page{page_number: no, total_pages: no}, %{}), do: nil

    def last_page(page = %Page{}, _spage, options = %{}) do
      build_element(options.labels.last, page.href, title: dgettext("scrivener_phoenix", "Last page"))
    end
  end

  @impl Scrivener.Phoenix.Template
  def prev_page(nil, %{}), do: nil

  def prev_page(page = %Page{}, options = %{}) do
    build_element(options.labels.prev, page.href, title: dgettext("scrivener_phoenix", "Previous page"), rel: "prev")
  end

  @impl Scrivener.Phoenix.Template
  def next_page(nil, %{}), do: nil

  def next_page(page = %Page{}, options = %{}) do
    build_element(options.labels.next, page.href, title: dgettext("scrivener_phoenix", "Next page"), rel: "next")
  end

  @impl Scrivener.Phoenix.Template
  if false do
    def page(page = %Page{}, spage = %Scrivener.Page{}) do
      if Page.current?(page, spage) do
        build_element(page.no, "#", [], class: "active")
      else
        build_element(page.no, page.href, handle_rel(page, spage))
      end
    end
  else
    def page(page = %Page{no: no}, %Scrivener.Page{page_number: no}) do
      build_element(page.no, "#", [], class: "active")
    end

    def page(page = %Page{}, spage = %Scrivener.Page{}) do
      build_element(page.no, page.href, handle_rel(page, spage))
    end
  end

  def page(%Gap{}, %Scrivener.Page{}) do
    build_element("…", "#", [], class: "disabled")
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
