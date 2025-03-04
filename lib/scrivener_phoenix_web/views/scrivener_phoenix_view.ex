if Code.ensure_loaded?(PhoenixHTMLHelpers) do
  defmodule Scrivener.PhoenixView do
    @moduledoc ~S"""
    The module which provides the helper to generate links for a Scrivener pagination.
    """

    use Gettext, backend: Scrivener.Phoenix.Gettext

    @type conn_or_socket_or_endpoint_or_uri_or_binary_or_nil :: Plug.Conn.t | Phoenix.LiveView.Socket.t | module | URI.t | String.t | nil
    @spec do_paginate(conn :: conn_or_socket_or_endpoint_or_uri_or_binary_or_nil, page :: Scrivener.Page.t, fun :: (... -> String.t), arguments :: list, options :: Scrivener.Phoenix.Options.t) :: Phoenix.HTML.safe

    # skip pagination if:
    # - there is zero entry (total)
    # - there only is a single page and display_if_single = false
    defp do_paginate(_conn, %Scrivener.Page{total_entries: 0}, _fun, _arguments, _options), do: nil
    defp do_paginate(_conn, %Scrivener.Page{total_pages: 1}, _fun, _arguments, %{display_if_single: false}), do: nil

    defp do_paginate(conn, page = %Scrivener.Page{}, route, arguments, options)
      when is_function(route)
    do
      fun = Scrivener.Phoenix.URLBuilder.url(conn, route, arguments, options)
      {first, prev} = Scrivener.Phoenix.Paginator.first_previous_page(page, fun, options)
      {next, last} = Scrivener.Phoenix.Paginator.next_last_page(page, fun, options)
      window_pages =
        page
        |> Scrivener.Phoenix.Paginator.window_pages(fun, options)
        |> reverse_links_if_inverted(options)

      []
      |> prepend_right_links(first, prev, next, last, options)
      |> append_pages(window_pages, options)
      |> Enum.reverse()
      |> prepend_left_links(first, prev, next, last, options)
      |> options.template.wrap()
    end

    @doc ~S"""
    Generates the whole HTML to navigate between pages.
    """
    @spec paginate(conn :: conn_or_socket_or_endpoint_or_uri_or_binary_or_nil, spage :: Scrivener.Page.t, fun :: function, arguments :: list, options :: Keyword.t) :: Phoenix.HTML.safe
    def paginate(conn, page = %Scrivener.Page{}, fun, arguments \\ [], options \\ [])
      when is_function(fun)
    do
      # defaults < config (Application) < options
      options =
#         defaults()
#         |> Keyword.merge(options)
        options
        |> Keyword.merge(Application.get_all_env(:scrivener_phoenix))
        |> Scrivener.Phoenix.Options.merge()
#         |> Enum.into(%{})
        |> Scrivener.Phoenix.Options.auto_set_live_option(conn)

      do_paginate(conn, page, fun, arguments, options)
    end

    defp prepend_right_links(links, first, prev, _next, _last, options = %{inverted: true}) do
      links
      |> maybe_prepend(prev, options.labels.prev, nil, options.symbols.right, options)
      |> maybe_prepend(first, options.labels.first, nil, options.symbols.xright, options)
    end

    defp prepend_right_links(links, _first, _prev, next, last, options) do
      links
      |> maybe_prepend(next, options.labels.next, nil, options.symbols.right, options)
      |> maybe_prepend(last, options.labels.last, nil, options.symbols.xright, options)
    end

    defp prepend_left_links(links, _first, _prev, next, last, options = %{inverted: true}) do
      links
      |> maybe_prepend(next, options.labels.next, options.symbols.left, nil, options)
      |> maybe_prepend(last, options.labels.last, options.symbols.xleft, nil, options)
    end

    defp prepend_left_links(links, first, prev, _next, _last, options) do
      links
      |> maybe_prepend(prev, options.labels.prev, options.symbols.left, nil, options)
      |> maybe_prepend(first, options.labels.first, options.symbols.xleft, nil, options)
    end

    defp reverse_links_if_inverted(links, %{inverted: true}) do
      links
      |> Enum.reverse()
    end

    defp reverse_links_if_inverted(links, _options) do
      links
    end

    defp prepend_to_list_if_not_nil(nil, list), do: list
    defp prepend_to_list_if_not_nil(value, list) do
      [value | list]
    end

    defp maybe_prepend(links, _page = nil, _label, _left_symbol, _right_symbol, _options) do
      links
    end

    defp maybe_prepend(links, p, label, left_symbol, right_symbol, options) do
      p
      |> options.template.page(label, left_symbol, right_symbol)
      |> prepend_to_list_if_not_nil(links)
    end

    defp label(page = %Scrivener.Phoenix.Page{}), do: page.label # page.no
    defp label(%Scrivener.Phoenix.Gap{}), do: "…" # TODO: options.labels.gap ?

    defp append_pages(links, pages, options) do
      result =
        pages
        |> Enum.reverse()
        |> Enum.map(
          fn p ->
            options.template.page(p, label(p), nil, nil)
          end
        )

      Enum.concat(links, result)
    end
  end
end
