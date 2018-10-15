defmodule Scrivener.Phoenix.Template do
  @moduledoc ~S"""
  This module defines the callbacks to guide the HTML creation for a pagination.
  """

  @doc ~S"""
  Callback to wraps the links with some HTML tags.

  Example:

    def wrap(links) do
      content_tag(:nav, class: "pagination") do
        content_tag(:ul) do
          links
        end
      end
    end
  """
  @callback wrap([Phoenix.HTML.safe()]) :: Phoenix.HTML.safe()

  @doc ~S"""
  Callback to generate an HTML link to a page.

  Example:

    # this is the current page
    def page(page = %Scrivener.Phoenix.Page{no: no}, %Scrivener.Page{page_number: no}) do
      content_tag(:li) do
        content_tag(:span, no, class: "current")
      end
    end

    def page(page = %Scrivener.Phoenix.Page{}, _) do
      content_tag(:li) do
        link(page.no, to: page.href)
      end
    end
  """
  @callback page(Scrivener.Phoenix.Page.t | Scrivener.Phoenix.Gap.t, Scrivener.Page.t) :: Phoenix.HTML.safe()

  @doc ~S"""
  Callback to generate HTML of the first page or to skip it by returning `nil`.

  Example:

    # no output if the first page is the current one
    def first_page(_page, %Scrivener.Page{page_number: 1}), do: nil

    def first_page(page = %%Scrivener.Phoenix.Page{}, _spage) do
    content_tag(:li) do
      link("First page", to: page.href)
    end
  end
  """
  @callback first_page(Scrivener.Phoenix.Page.t, Scrivener.Page.t) :: Phoenix.HTML.safe() | nil

  @doc ~S"""
  Callback to generate HTML of the last page or to skip it by returning `nil`.

  Example:

    def last_page(page = %Scrivener.Phoenix.Page{}, spage = %Scrivener.Page{}) do
      if page.no == spage.page_number) do
        content_tag(:span, "Last page", class: "current disabled")
      else
        link("Last page", to: page.href)
      end
    end
  """
  @callback last_page(Scrivener.Phoenix.Page.t, Scrivener.Page.t) :: Phoenix.HTML.safe() | nil

  @doc ~S"""
  Callback to generate HTML of the previous page or to skip it by returning `nil`.
  """
  @callback prev_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe() | nil

  @doc ~S"""
  Callback to generate HTML of the next page or to skip it by returning `nil`.
  """
  @callback next_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe() | nil

  defmacro __using__(_options) do
    quote do
      use Phoenix.HTML
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end
end
