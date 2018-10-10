defmodule Scrivener.PhoenixView do
  alias Scrivener.Phoenix.Gap
  alias Scrivener.Phoenix.Page

  @defaults [
    left: 0,
    right: 0,
    window: 4,
    outer_window: 0,
    inverted: false, # NOTE: would be great if it was an option handled by (and passed from - part of %Scriver.Page{}) Scrivener
    param_name: :page,
    template: Scrivener.Phoenix.Template.Bootstrap4,
  ]

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
  @spec paginate(conn :: Plug.Conn.t, page :: Scrivener.Page.t, fun :: function, arguments :: list, options :: Keyword.t) :: Phoenix.HTML.safe()
  def paginate(conn = %Plug.Conn{}, page = %Scrivener.Page{}, fun, arguments \\ [], options \\ [])
    when is_function(fun)
  do
    # if length(arguments) > arity(fun)
    #   the page (its number) is part of route parameters
    # else
    #   it has to be integrated to the query string
    # fi
    # WARNING: usage of the query string implies to use the route with an arity + 1 because Phoenix create routes as:
    # def blog_page_path(conn_or_endpoint, action, pageno, options \\ [])

    # (@)defaults < config (Applicaton) < options
    options = @defaults
    |> Keyword.merge(Application.get_all_env(:scrivener_phoenix))
    |> Keyword.merge(options)
    |> Enum.into(%{})

    left_window_plus_one = range_as_list(1, options.left + 1)
    right_window_plus_one = range_as_list(page.total_pages - options.right, page.total_pages)
    inside_window_plus_each_sides = range_as_list(page.page_number - options.window - 1, page.page_number + options.window + 1)

    %{
      first: Page.create(1, url(conn, fun, arguments, 1, options)),
      last: Page.create(page.total_pages, url(conn, fun, arguments, page.total_pages, options)),
      prev: if has_prev?(page) do
        Page.create(page.page_number - 1, url(conn, fun, arguments, page.page_number - 1, options))
      end,
      next: if has_next?(page) do
        Page.create(page.page_number + 1, url(conn, fun, arguments, page.page_number + 1, options))
      end,
      pages: (left_window_plus_one ++ right_window_plus_one ++ inside_window_plus_each_sides)
        |> Enum.sort()
        |> Enum.uniq()
        |> Enum.reject(&(&1 < 1 or &1 > page.total_pages))
        |> Enum.map(fn page_number ->
          Page.create(page_number, url(conn, fun, arguments, page_number, options))
        end)
        |> add_gap(page, options)
        |> Enum.reverse()
    }
    |> options.template.paginator(page, options)
  end

  def has_prev?(page = %Scrivener.Page{}) do
    page.page_number > 1
  end

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

  defp range_as_list(l, h) do
    Range.new(l, h)
    |> Enum.to_list()
  end

  defp map_to_keyword(map = %{}) do
    map
    |> Enum.into([])
  end

  defp url(conn = %Plug.Conn{}, fun, helper_arguments, page_number, options) do
    {:arity, arity} = :erlang.fun_info(fun, :arity)
    arguments = handle_arguments(conn, arity, helper_arguments, page_number, options)
    apply(fun, arguments)
  end

  # if length(helper_arguments) > arity(fun) then integrate page_number as helper's arguments
  defp handle_arguments(conn, arity, helper_arguments, page_number, _options)
    when arity == length(helper_arguments) + 3 # 3 for (not counted) conn + additionnal parameters (query string) + page (as part of URL's path)
  do
    # remove any potential page argument?
    # conn.query_params |> Map.delete(options.param_name) |> map_to_keyword()
    [conn | helper_arguments] ++ [page_number, map_to_keyword(conn.query_params)]
  end

  # else integrate page_number as query string
  defp handle_arguments(conn, arity, helper_arguments, page_number, options)
    when arity == length(helper_arguments) + 2 # 2 for (not counted) conn + additionnal parameters (query string)
  do
    query_params = conn.query_params
    |> Map.put(options.param_name, page_number)
    |> map_to_keyword()

    [conn | helper_arguments] ++ [query_params]
  end
end
