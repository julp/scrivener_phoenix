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
  @callback wrap([Phoenix.HTML.safe]) :: Phoenix.HTML.safe

  @doc ~S"""
  Callback to generate an HTML link to a page.

  Example:

    # this is the current page
    def page(page = %Scrivener.Phoenix.Page{rel: :current}, _options, _left_symbol, _right_symbol) do
      content_tag(:li) do
        content_tag(:span, no, class: "current")
      end
    end

    def page(page, _, _options, _left_symbol, _right_symbol) do
      content_tag(:li) do
        link(page.no, to: page.href)
      end
    end
  """
  @callback page(page :: Scrivener.Phoenix.Page.t | Scrivener.Phoenix.Gap.t, options :: Scrivener.Phoenix.Options.t, left_symbol :: String.t | nil, right_symbol :: String.t | nil) :: Phoenix.HTML.safe

  defmacro __using__(_options) do
    quote do
      import Phoenix.HTML
      use PhoenixHTMLHelpers
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end
end
