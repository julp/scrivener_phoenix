defmodule Scrivener.Phoenix.Template do

  @callback wrap([Phoenix.HTML.safe()]) :: Phoenix.HTML.safe()

  @callback page(Scrivener.Phoenix.Page.t, Scrivener.Page.t) :: Phoenix.HTML.safe() | nil
  @callback first_page(Scrivener.Phoenix.Page.t, Scrivener.Page.t) :: Phoenix.HTML.safe() | nil
  @callback last_page(Scrivener.Phoenix.Page.t, Scrivener.Page.t) :: Phoenix.HTML.safe() | nil
  @callback prev_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe() | nil
  @callback next_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe() | nil

  defmacro __using__(_options) do
    quote do
      use Phoenix.HTML
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
    end
  end
end
