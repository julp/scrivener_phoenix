if false do
defmodule Scrivener.Phoenix.Options do
  @default_left 0
  @default_right 0
  @default_window 4
  @default_outer_window 0
  @default_live nil
  @default_inverted false
  @default_param_name :page
  @default_merge_params false
  @default_display_if_single false

  @moduledoc """
  Options:

    * params (default: `nil`): an explicit list (or map) of parameters to add to the query string, this is mostly intended for LiveView with `push_patch` since *params* have to be handled by yourself
    * left (default: `#{inspect(@default_left)}`): display the *left* first pages
    * right (default: `#{inspect(@default_right)}`): display the *right* last pages
    * window (default: `#{inspect(@default_window)}`): display *window* pages before and after the current page (eg, if 7 is the current page and window is 2, you'd get: `5 6 7 8 9`)
    * outer_window (default: `#{inspect(@default_outer_window)}`), equivalent to left = right = outer_window: display the *outer_window* first and last pages (eg valued to 2:
      `« First ‹ Prev 1 2 ... 5 6 7 8 9 ... 19 20 Next › Last »` as opposed to left = 1 and right = 3: `« First ‹ Prev 1 ... 5 6 7 8 9 ... 18 19 20 Next › Last »`)
    * live (default: `#{inspect(@default_live)}`):
      + `true` to generate links with `Phoenix.LiveView.Helpers.live_patch/2` instead of `Phoenix.HTML.Link.link/2`
      + `nil` to set it automatically to `true` when `paginate/5` is called with a `%Phoenix.LiveView.Socket{}` as its first parameter else `false`
    * inverted (default: `#{inspect(@default_inverted)}`): `true` to first (left side) link last pages instead of first
    * display_if_single (default: `#{inspect(@default_display_if_single)}`): `true` to force a pagination to be displayed when there only is a single page of result(s)
    * param_name (default: `#{inspect(@default_param_name)}`): the name of the parameter generated in URL (query string) to propagate the page number
    * merge_params (default: `#{inspect(@default_merge_params)}`): `true` to copy the entire query string between requests, `false` to ignore it or a list of the parameter names to only reproduce
    * symbols (default: `%{first: "«", prev: "‹", next: "›", last: "»"}`): the symbols to add before or after the label for the first, previous, next and last page (`nil` or `""` for none)
    * labels (default: `%{first: dgettext("scrivener_phoenix", "First"), prev: dgettext("scrivener_phoenix", "Prev"), next: dgettext("scrivener_phoenix", "Next"), last: dgettext("scrivener_phoenix", "Last")}`):
      the texts used by links to describe the first, previous, next and last page
  """

  use Gettext, backend: Scrivener.Phoenix.Gettext

  defstruct ~W[params left right window outer_window live inverted display_if_single param_name merge_params labels symbols]a

  @type t :: %__MODULE__{
    params: Enumerable.t | nil,
    left: non_neg_integer,
    right: non_neg_integer,
    window: non_neg_integer,
    outer_window: non_neg_integer,
    live: boolean | nil,
    inverted: boolean,
    display_if_single: boolean,
    param_name: atom | String.t,
    merge_params: boolean | [atom | String.t],
    labels: %{
      first: String.t,
      prev: String.t,
      next: String.t,
      last: String.t,
    },
    symbols: %{
      first: String.t,
      prev: String.t,
      next: String.t,
      last: String.t,
#       gap: String.t,
    },
  }

  def new do
    %__MODULE__{
      params: nil,
      left: @default_left,
      right: @default_right,
      window: @default_window,
      outer_window: @default_outer_window,
      live: @default_live,
      inverted: @default_inverted, # NOTE: would be great if it was an option handled by (and passed from - part of %Scriver.Page{}) Scrivener
      display_if_single: @default_display_if_single,
      param_name: @default_param_name,
      merge_params: @default_merge_params,
      labels: %{
        first: dgettext("scrivener_phoenix", "First"),
        prev: dgettext("scrivener_phoenix", "Prev"),
        next: dgettext("scrivener_phoenix", "Next"),
        last: dgettext("scrivener_phoenix", "Last"),
      },
      symbols: %{
        first: "«",
        prev: "‹",
        next: "›",
        last: "»",
        #gap: "…",
      },
    }
  end
end

defmodule Scrivener.Phoenix.Pagination do
  @type t :: %__MODULE__{
    first: Scrivener.Phoenix.Page.t | nil,
    last: Scrivener.Phoenix.Page.t | nil,
    next: Scrivener.Phoenix.Page.t | nil,
    previous: Scrivener.Phoenix.Page.t | nil,
    pages: [Scrivener.Phoenix.Page.t | Scrivener.Phoenix.Gap.t],
  }
  defstruct ~W[first last next previous]a ++ [pages: []]

  def any?(%__MODULE__{pages: []}), do: false
  def any?(_), do: true

  def empty?(%__MODULE__{pages: []}), do: true
  def empty?(_), do: false
end

defmodule Scrivener.Phoenix.Components do
  @moduledoc ~S"""
  The module which provides the helper to generate links for a Scrivener pagination.
  """

  use Phoenix.Component
  use Gettext, backend: Scrivener.Phoenix.Gettext

  @typep conn_or_socket_or_endpoint :: Plug.Conn.t | Phoenix.LiveView.Socket.t | module

  @spec set_first_page(pagination :: Scrivener.Phoenix.Pagination.t, pages :: Scrivener.Phoenix.Page.t) :: Scrivener.Phoenix.Pagination.t
  defp set_first_page(pagination = %Scrivener.Phoenix.Pagination{}, page = %Scrivener.Phoenix.Page{}) do
    %{pagination | first: page}
  end

  @spec set_last_page(pagination :: Scrivener.Phoenix.Pagination.t, page :: Scrivener.Phoenix.Page.t) :: Scrivener.Phoenix.Pagination.t
  defp set_last_page(pagination = %Scrivener.Phoenix.Pagination{}, page = %Scrivener.Phoenix.Page{}) do
    %{pagination | last: page}
  end

  @spec set_window_pages(pagination :: Scrivener.Phoenix.Pagination.t, pages :: [Scrivener.Phoenix.Page.t | Scrivener.Phoenix.Gap.t]) :: Scrivener.Phoenix.Pagination.t
  defp set_window_pages(pagination = %Scrivener.Phoenix.Pagination{}, pages) do
    %{pagination | pages: pages}
  end

  @spec do_paginate(conn :: conn_or_socket_or_endpoint, page :: Scrivener.Page.t, fun :: function, arguments :: list, options :: Scrivener.Phoenix.Options.t) :: Scrivener.Phoenix.Pagination.t

  # skip pagination if:
  # - there is zero entry (total)
  # - there only is a single page and display_if_single = false
  defp do_paginate(_conn, %Scrivener.Page{total_entries: 0}, _fun, _arguments, _options), do: %Scrivener.Phoenix.Pagination{}
  defp do_paginate(_conn, %Scrivener.Page{total_pages: 1}, _fun, _arguments, %Scrivener.Phoenix.Options{display_if_single: false}), do: %Scrivener.Phoenix.Pagination{}

  defp do_paginate(conn, page = %Scrivener.Page{}, fun, arguments, options = %Scrivener.Phoenix.Options{})
    when is_function(fun)
  do
#     map = %{
#       first: options.inverted,
#       prev: options.inverted,
#       next: !options.inverted,
#       last: !options.inverted,
#     }
# 
#     options = %{options | labels: options.labels
#       |> Enum.reduce(options.labels, fn {k, v}, acc ->
#         label =
#           [v]
#           |> List.insert_at(bool_to_int(map[k]), options.symbols[k])
#           |> Enum.join(" ")
#           |> String.trim()
#         Map.put(acc, k, label)
#       end)
#     }

    left_window_plus_one = range_as_list(1, options.left + 1)
    right_window_plus_one = range_as_list(page.total_pages - options.right, page.total_pages)
    inside_window_plus_each_sides = range_as_list(page.page_number - options.window - 1, page.page_number + options.window + 1)

    prev_page = if has_prev?(page) do
      Scrivener.Phoenix.Page.create(page.page_number - 1, url(conn, fun, arguments, page.page_number - 1, options))
    end

    next_page = if has_next?(page) do
      Scrivener.Phoenix.Page.create(page.page_number + 1, url(conn, fun, arguments, page.page_number + 1, options))
    end

    window_pages =
      left_window_plus_one
      |> Kernel.++(right_window_plus_one)
      |> Kernel.++(inside_window_plus_each_sides)
      |> Enum.sort()
      |> Enum.uniq()
      |> Enum.reject(&(&1 < 1 or &1 > page.total_pages))
      |> Enum.map(
        fn page_number ->
          Scrivener.Phoenix.Page.create(page_number, url(conn, fun, arguments, page_number, options))
        end
      )
      |> add_gap(page, options)
      |> reverse_links_if_not_inversed(options)

    %Scrivener.Phoenix.Pagination{}
    |> set_first_page(Scrivener.Phoenix.Page.create(1, url(conn, fun, arguments, 1, options)))
    # TODO: next/prev
    |> set_last_page(Scrivener.Phoenix.Page.create(page.total_pages, url(conn, fun, arguments, page.total_pages, options)))
    |> set_window_pages(window_pages)
  end

  @spec auto_set_live_option(options :: Scrivener.Phoenix.Options.t, cse :: conn_or_socket_or_endpoint) :: Scrivener.Phoenix.Options.t
  defp auto_set_live_option(options = %Scrivener.Phoenix.Options{live: nil}, cse)
    when is_map(options)
  do
    Map.put(options, :live, is_struct(cse) and cse.__struct__ == Phoenix.LiveView.Socket)
  end

  defp auto_set_live_option(options, _cse), do: options

  @doc """
  Generates the whole HTML to navigate between pages.
  """
  @spec paginate(conn :: conn_or_socket_or_endpoint, spage :: Scrivener.Page.t, fun :: function, arguments :: list, options :: Keyword.t) :: Scrivener.Phoenix.Pagination.t
  def paginate(conn, page = %Scrivener.Page{}, fun, arguments, options)
    when is_function(fun)
  do
    # if length(arguments) > arity(fun)
    #   the page (its number) is part of route parameters
    # else
    #   it has to be integrated to the query string
    # fi
    # WARNING: usage of the query string implies to use the route with an arity + 1 because Phoenix create routes as:
    # def blog_page_path(conn, action, pageno, options \\ [])

    # defaults() < config (Application) < options
    options =
      options
#       |> build_options()
      |> adjust_symbols_if_needed()
      |> auto_set_live_option(conn)

    do_paginate(conn, page, fun, arguments, options)
  end

  defp adjust_symbols_if_needed(options = %{inverted: true}) do
    %{options | symbols: %{first: options.symbols.last, prev: options.symbols.next, next: options.symbols.prev, last: options.symbols.first}}
  end

  defp adjust_symbols_if_needed(options), do: options

  defp prepend_right_links(links, page, first, prev, _next, _last, options = %{inverted: true}) do
    links
    |> maybe_prepend(prev, options)
    |> maybe_prepend(first, page, options)
  end

  defp prepend_right_links(links, page, _first, _prev, next, last, options) do
    links
    |> maybe_prepend(next, options)
    |> maybe_prepend(last, page, options)
  end

  defp prepend_left_links(links, page, _first, _prev, next, last, options = %{inverted: true}) do
    links
    |> maybe_prepend(next, options)
    |> maybe_prepend(last, page, options)
  end

  defp prepend_left_links(links, page, first, prev, _next, _last, options) do
    links
    |> maybe_prepend(prev, options)
    |> maybe_prepend(first, page, options)
  end

  defp reverse_links_if_not_inversed(links, %{inverted: true}), do: links
  defp reverse_links_if_not_inversed(links, _options) do
    links
    |> Enum.reverse()
  end

  defp prepend_to_list_if_not_nil(nil, list), do: list
  defp prepend_to_list_if_not_nil(value, list) do
    [value | list]
  end

  defp maybe_prepend(links, page, options) do
    page
    |> prepend_to_list_if_not_nil(links)
  end

  defp maybe_prepend(links, page, spage, options) do
    page
    |> prepend_to_list_if_not_nil(links)
  end

  defp append_pages(links, pages, spage, options) do
    result =
      pages
      |> Enum.reverse()
    Enum.concat(links, result)
  end

  def first?(page) do
    true
  end

  @spec has_prev?(page :: Scrivener.Page.t) :: boolean
  def has_prev?(page = %Scrivener.Page{}) do
    page.page_number > 1
  end

  @spec has_next?(page :: Scrivener.Page.t) :: boolean
  def has_next?(page = %Scrivener.Page{}) do
    page.page_number < page.total_pages
  end

  defp was_truncated([%Scrivener.Phoenix.Gap{} | _ ]), do: true
  defp was_truncated(_), do: false

  defp do_add_gap([], acc, _page = %Scrivener.Page{}, _options = %{}) do
    acc
  end

  defp do_add_gap([hd | tl], acc, page = %Scrivener.Page{}, options = %{}) do
    import Scrivener.Phoenix.Page

    acc = cond do
      left_outer?(hd, options) || right_outer?(hd, page, options) || inside_window?(hd, page, options) ->
        [hd | acc]
      !was_truncated(acc) ->
        [%Scrivener.Phoenix.Gap{} | acc]
      true ->
        acc
    end
    do_add_gap(tl, acc, page, options)
  end

  def add_gap(pages, page = %Scrivener.Page{}, options = %{}) do
    do_add_gap(pages, [], page, options)
  end

  @spec range_as_list(l :: integer, h :: integer) :: [integer]
  defp range_as_list(l, h) do
    l
    |> Range.new(h)
    |> Enum.to_list()
  end

  @doc false # public for testing
  def url(conn, fun, helper_arguments, page_number, options) do
    {:arity, arity} = :erlang.fun_info(fun, :arity)
    arguments = handle_arguments(conn, arity, helper_arguments, page_number, options)
    apply(fun, arguments)
  end

  @spec rel_attribute(any) :: String.t | nil
  defp rel_attribute(_todo), do: "prev"
  defp rel_attribute(_todo), do: "next"
  defp rel_attribute(_todo), do: nil

  @spec href_attribute(conn :: conn_or_socket_or_endpoint, options :: Scrivener.Phoenix.Options.t) :: :patch | :href
#   defp href_attribute(conn, options) do
#     if options.live or (is_nil(options.live) and is_struct(conn) and conn.__struct__ == Phoenix.LiveView.Socket) do
#       :patch
#     else
#       :href
#     end
#   end

  defp href_attribute(_conn, _options = %{live: true}), do: :patch
  defp href_attribute(_conn = %{__struct__: Phoenix.LiveView.Socket}, _options = %{live: nil}), do: :patch
  defp href_attribute(_conn, _options), do: :href

  defp first_page(assigns) do
    ~H"""
    <%= if @first != [] do %>
      <%= render_slot(@first, @pagination.first) %>
    <% else %>
      <.link
        rel="TODO"
        class="TODO"
        title={dgettext("scrivener_phoenix", "First page")}
        {[{@href_attribute, @pagination.first.href}]}
      >
        <%= dgettext("scrivener_phoenix", "First") %>
      </.link>
    <% end %>
    """
  end

  # assigns = %{pages: %<struct ?>{pages: []}} avec une map ou stuct
  defp real_paginate(assigns = %{pages: []}) do
    ~H""
  end

  defp real_paginate(assigns = %{pages: [_], options: %{display_if_single: false}}) do
    ~H""
  end

  # TODO: jouer sur flex (reverse order) pour échanger les labels + pages ?
  # TODO: au lieu de renvoyer une liste de pages, renvoyer une map %<struct ?>{first: nil | Page.t, prev: nil | Page.t, next: nil | Page.t, last: nil | Page.t, pages: [Page.t | Gap.t]} ?
  # TODO: wrapper/conteneur HTML ?
  defp real_paginate(assigns) do
    ~H"""
    <%= if @options.inverted do %>
      <%# TODO: last %>

      <%# TODO: next %>
    <% else %>
      <%= if @first != [] do %>
        <%= render_slot(@first, @pagination.first) %>
      <% else %>
        <.link
          rel="TODO"
          class="TODO"
          title={dgettext("scrivener_phoenix", "First page")}
          {[{@href_attribute, @pagination.first.href}]}
        >
          <%= dgettext("scrivener_phoenix", "First") %>
        </.link>
      <% end %>

      <%# TODO: prev %>
      <%#= dgettext("scrivener_phoenix", "Prev") %>
    <% end %>

    <%= for page <- @pagination.pages do %>
      <%= case page do %>
        <% %Scrivener.Phoenix.Gap{} -> %>
          <%= if @gap != [] do %>
            <%= render_slot(@gap) %>
          <% else %>
            …
          <% end %>
        <% %Scrivener.Phoenix.Page{} -> %>
          <%= if @page != [] do %>
            <%= render_slot(@page, page) %>
          <% else %>
            <.link
              rel="TODO"
              class="TODO"
              title={page.no}
              {[{@href_attribute, page.href}]}
            >
              <%= page.no %>
            </.link>
          <% end %>
      <% end %>
    <% end %>

    <%= if @options.inverted do %>
      <%# TODO: last %>
      <%#= dgettext("scrivener_phoenix", "Last") %>
      <%# TODO: next %>
      <%#= dgettext("scrivener_phoenix", "Next") %>
    <% else %>
      <%# TODO: prev %>
      <%# TODO: first %>
    <% end %>
    """
  end

  # TODO: renommer (first|last|next|previous|page|gap) en \1_block ?
  defp do_paginate(assigns) do
    ~H"""
    <.real_paginate
      conn={@conn}
      route={@route}
      enum={@enum}
      args={@args}
      page={@page}
      gap={@gap}
      first={@first}
      previous={@previous}
      next={@next}
      last={@last}
      options={@options}
      pagination={paginate(@conn, @enum, @route, @args, @options)}
      href_attribute={href_attribute(@conn, @options)}
    />
    """
  end

  @spec merge_options(out :: Scrivener.Phoenix.Options.t, input :: Enumerable.t) :: Scrivener.Phoenix.Options.t
  defp merge_options(out = %Scrivener.Phoenix.Options{}, input) do
    Enum.reduce(
      input,
      out,
      fn {k, v}, acc ->
        Map.replace(acc, k, v)
      end
    )
  end

  @spec build_options(options :: Enumerable.t) :: Scrivener.Phoenix.Options.t
  defp build_options(options) do
    Scrivener.Phoenix.Options.new()
    |> merge_options(Application.get_all_env(:scrivener_phoenix))
    |> merge_options(options)
    |> adjust_symbols_if_needed()
#     |> auto_set_live_option(conn)
  end

  attr :conn, :any, required: true
  attr :route, :any, required: true
  attr :enum, Scrivener.Page, required: true
  attr :options, :any, default: []
  attr :args, :list, default: []

  slot :page
  slot :gap
  slot :first
  slot :previous
  slot :next
  slot :last

  def paginate(assigns) do
    ~H"""
    <.do_paginate
      conn={@conn}
      route={@route}
      enum={@enum}
      args={@args}
      page={@page}
      gap={@gap}
      first={@first}
      previous={@previous}
      next={@next}
      last={@last}
      options={@options |> build_options()}
    />
    """

#     assigns
#     |> assign(:options, assigns.options)
#     |> do_paginate()
  end
end
end
