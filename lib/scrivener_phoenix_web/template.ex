defmodule Scrivener.Phoenix.Template do

  #@callback first_page(Scrivener.Page.t, String.t) :: Phoenix.HTML.safe()
  #@callback prev_page(Scrivener.Page.t, String.t) :: Phoenix.HTML.safe()
  #@callback page(Scrivener.Page.t, String.t) :: Phoenix.HTML.safe()
  #@callback next_page(Scrivener.Page.t, String.t) :: Phoenix.HTML.safe()
  #@callback last_page(Scrivener.Page.t, String.t) :: Phoenix.HTML.safe()

  @callback paginator(map, Scrivener.Page.t, map) :: Phoenix.HTML.safe()

  defmacro __using__(_options) do
    quote do
      use Phoenix.HTML
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end
end
