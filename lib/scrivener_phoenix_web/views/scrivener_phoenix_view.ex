defmodule Scrivener.PhoenixView do
  @moduledoc ~S"""
  The module which provides the helper to generate links for a Scrivener pagination.
  """

  alias Scrivener.Phoenix.Gap
  alias Scrivener.Phoenix.Page
  import Scrivener.Phoenix.Gettext

  defp defaults do
    [
      left: 0,
      right: 0,
      window: 4,
      outer_window: 0,
      inverted: false, # NOTE: would be great if it was an option handled by (and passed from - part of %Scriver.Page{}) Scrivener
      param_name: :page,
      template: Scrivener.Phoenix.Template.Bootstrap4,
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
    ]
  end

  @typep conn_or_endpoint :: Plug.Conn.t | module

  @doc ~S"""
  options:
  - template
  - left
  - right
  - window
  - outer_window
  - inverted
  - template
  - param_name
  """
  @spec paginate(conn :: conn_or_endpoint, page :: Scrivener.Page.t, fun :: function, arguments :: list, options :: Keyword.t) :: Phoenix.HTML.safe
  def paginate(conn, page, fun, arguments \\ [], options \\ [])

  # skip pagination if there is a single page
  def paginate(_conn, %Scrivener.Page{total_pages: 1}, _fun, _arguments, _options), do: nil

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

    # defaults() < config (Applicaton) < options
    options =
      defaults()
      |> Keyword.merge(Application.get_all_env(:scrivener_phoenix))
      |> Keyword.merge(options)
      |> Enum.into(%{})
      |> adjust_symbols_if_needed()

    map = %{
      first: options.inverted,
      prev: options.inverted,
      next: !options.inverted,
      last: !options.inverted,
    }

    options = %{options | labels: options.labels
      |> Enum.reduce(options.labels, fn {k, v}, acc ->
        label =
          [v]
          |> List.insert_at(bool_to_int(map[k]), options.symbols[k])
          |> Enum.join(" ")
          |> String.trim()
        Map.put(acc, k, label)
      end)
    }

    left_window_plus_one = range_as_list(1, options.left + 1)
    right_window_plus_one = range_as_list(page.total_pages - options.right, page.total_pages)
    inside_window_plus_each_sides = range_as_list(page.page_number - options.window - 1, page.page_number + options.window + 1)

    first_page = Page.create(1, url(conn, fun, arguments, 1, options))
    last_page = Page.create(page.total_pages, url(conn, fun, arguments, page.total_pages, options))
    prev_page = if has_prev?(page) do
      Page.create(page.page_number - 1, url(conn, fun, arguments, page.page_number - 1, options))
    end
    next_page = if has_next?(page) do
      Page.create(page.page_number + 1, url(conn, fun, arguments, page.page_number + 1, options))
    end
    window_pages =
      (left_window_plus_one ++ right_window_plus_one ++ inside_window_plus_each_sides)
      |> Enum.sort()
      |> Enum.uniq()
      |> Enum.reject(&(&1 < 1 or &1 > page.total_pages))
      |> Enum.map(
        fn page_number ->
          Page.create(page_number, url(conn, fun, arguments, page_number, options))
        end
      )
      |> add_gap(page, options)
      |> reverse_links_if_not_inversed(options)

    []
    |> prepend_right_links(page, first_page, prev_page, next_page, last_page, options)
    |> append_pages(window_pages, page, options)
    |> Enum.reverse()
    |> prepend_left_links(page, first_page, prev_page, next_page, last_page, options)
    |> options.template.wrap()
  end

  defp adjust_symbols_if_needed(options = %{inverted: true}) do
    %{options | symbols: %{first: options.symbols.last, prev: options.symbols.next, next: options.symbols.prev, last: options.symbols.first}}
  end

  defp adjust_symbols_if_needed(options), do: options

  defp prepend_right_links(links, page, first, prev, _next, _last, options = %{inverted: true}) do
    links
    |> maybe_prepend(&options.template.prev_page/2, prev, options)
    |> maybe_prepend(&options.template.first_page/3, first, page, options)
  end

  defp prepend_right_links(links, page, _first, _prev, next, last, options) do
    links
    |> maybe_prepend(&options.template.next_page/2, next, options)
    |> maybe_prepend(&options.template.last_page/3, last, page, options)
  end

  defp prepend_left_links(links, page, _first, _prev, next, last, options = %{inverted: true}) do
    links
    |> maybe_prepend(&options.template.next_page/2, next, options)
    |> maybe_prepend(&options.template.last_page/3, last, page, options)
  end

  defp prepend_left_links(links, page, first, prev, _next, _last, options) do
    links
    |> maybe_prepend(&options.template.prev_page/2, prev, options)
    |> maybe_prepend(&options.template.first_page/3, first, page, options)
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

  defp maybe_prepend(links, fun, page, options) do
    page
    |> fun.(options)
    |> prepend_to_list_if_not_nil(links)
  end

  defp maybe_prepend(links, fun, page, spage, options) do
    page
    |> fun.(spage, options)
    |> prepend_to_list_if_not_nil(links)
  end

  defp append_pages(links, pages, spage, options) do
    pages
    |> Enum.reverse()
    |> Enum.into(links, fn page ->
      options.template.page(page, spage)
    end)
  end

  @spec has_prev?(page :: Scrivener.Page.t) :: boolean
  def has_prev?(page = %Scrivener.Page{}) do
    page.page_number > 1
  end

  @spec has_next?(page :: Scrivener.Page.t) :: boolean
  def has_next?(page = %Scrivener.Page{}) do
    page.page_number < page.total_pages
  end

  defp was_truncated([%Gap{} | _ ]), do: true
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
        [%Gap{} | acc]
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

  @spec map_to_keyword(map :: map) :: Keyword.t
  defp map_to_keyword(map = %{}) do
    map
    |> Enum.into([])
  end

  defp bool_to_int(true), do: 1
  defp bool_to_int(false), do: 0

  defp url(conn, fun, helper_arguments, page_number, options) do
    {:arity, arity} = :erlang.fun_info(fun, :arity)
    arguments = handle_arguments(conn, arity, helper_arguments, page_number, options)
    apply(fun, arguments)
  end

  @spec query_params(conn_or_endpoint :: conn_or_endpoint) :: map
  defp query_params(conn = %Plug.Conn{}) do
    conn = Plug.Conn.fetch_query_params(conn)
    conn.query_params
    # TODO: white list parameters to keep? (Map.take/2)
  end

  defp query_params(endpoint)
    when is_atom(endpoint)
  do
    %{}
  end

  # if length(helper_arguments) > arity(fun) then integrate page_number as helper's arguments
  defp handle_arguments(conn, arity, helper_arguments, page_number, options)
    when arity == length(helper_arguments) + 3 # 3 for (not counted) conn + additionnal parameters (query string) + page (as part of URL's path)
  do
    new_query_params =
      conn
      |> query_params()
      |> Map.delete(options.param_name)
      |> map_to_keyword()

    [conn | helper_arguments] ++ [page_number, new_query_params]
  end

  # else integrate page_number as query string
  defp handle_arguments(conn, arity, helper_arguments, page_number, options)
    when arity == length(helper_arguments) + 2 # 2 for (not counted) conn + additionnal parameters (query string)
  do
    new_query_params =
      conn
      |> query_params()
      |> Map.put(options.param_name, page_number)
      |> map_to_keyword()

    [conn | helper_arguments] ++ [new_query_params]
  end
end
