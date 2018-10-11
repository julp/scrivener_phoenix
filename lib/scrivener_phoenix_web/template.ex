defmodule Scrivener.Phoenix.Template do

  @callback paginator([Phoenix.HTML.safe()]) :: Phoenix.HTML.safe()

  @callback page(Scrivener.Phoenix.Page.t, Scrivener.Page.t) :: Phoenix.HTML.safe()
  @callback first_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe()
  @callback last_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe()
  @callback prev_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe()
  @callback next_page(Scrivener.Phoenix.Page.t) :: Phoenix.HTML.safe()

  # TODO: return a boolean (to decide in PhoenixView if we call {first,last,next,prev}_page to generate the link or skip the page)
  @callback add_first_page([Phoenix.HTML.safe()], map, Scrivener.Page.t) :: [Phoenix.HTML.safe()]
  @callback add_last_page([Phoenix.HTML.safe()], map, Scrivener.Page.t) :: [Phoenix.HTML.safe()]
  @callback add_prev_page([Phoenix.HTML.safe()], map, Scrivener.Page.t) :: [Phoenix.HTML.safe()]
  @callback add_next_page([Phoenix.HTML.safe()], map, Scrivener.Page.t) :: [Phoenix.HTML.safe()]

  defmacro __using__(_options) do
    quote do
      use Phoenix.HTML
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)

      def add_first_page(links, %{}, %Scrivener.Page{page_number: 1}) do
        links
      end

      def add_first_page(links, %{first: first_page}, %Scrivener.Page{}) do
        [first_page(first_page) | links]
      end

      # if we are on the last page, skip the link to it
      def add_last_page(links, %{}, %Scrivener.Page{page_number: no, total_pages: no}) do
        links
      end

      def add_last_page(links, %{last: last_page}, %Scrivener.Page{}) do
        [last_page(last_page) | links]
      end

      def add_prev_page(links, %{prev: nil}, %Scrivener.Page{}) do
        links
      end

      def add_prev_page(links, %{prev: prev}, %Scrivener.Page{}) do
        [prev_page(prev) | links]
      end

      def add_next_page(links, %{next: nil}, %Scrivener.Page{}) do
        links
      end

      def add_next_page(links, %{next: next}, %Scrivener.Page{}) do
        [next_page(next) | links]
      end

      defoverridable [
        add_first_page: 3,
        add_last_page: 3,
        add_prev_page: 3,
        add_next_page: 3,
      ]
    end
  end
end
