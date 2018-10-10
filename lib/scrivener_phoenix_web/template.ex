defmodule Scrivener.Phoenix.Template do

  @callback paginator(map, Scrivener.Page.t, map) :: Phoenix.HTML.safe()

  defmacro __using__(_options) do
    quote do
      use Phoenix.HTML
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end
end
