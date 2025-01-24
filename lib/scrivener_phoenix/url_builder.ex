defmodule Scrivener.Phoenix.URLBuilder do
  @moduledoc ~S"""
  TODO
  """

  @typep conn_or_socket_or_endpoint_or_uri_or_binary_or_nil :: Scrivener.PhoenixView.conn_or_socket_or_endpoint_or_uri_or_binary_or_nil
  @typep options :: Scrivener.Phoenix.Options.t
  @typep params :: %{optional(String.t) => any}

  @doc """
  Returns a function to generates page path or URL.

  *conn* can be:

    * `nil`
    * an `%URI{}` with *fun* set to `nil` but the page can only be part of the query string (not the path)
    * a string (binary) with *fun* set to `nil` but the page can only be part of the query string (not the path)
    * a `%Plug.Conn{}`
    * a `%Phoenix.LiveView.Socket{}`
    * a module (atom) to an endpoint (a module implementing `Phoenix.Endpoint`)

  *fun* should be `nil` for `%URI{}` and strings (binaries) else a callback (function, your route for example) returning a string (binary), the path or URL.

  *helper_arguments* are your known arguments to dynamically call *fun*.

  When *conn* is an endpoint, a `%Plug.Conn{}` or a `%Phoenix.LiveView.Socket{}`, *conn* will be automaticaly prepended to it if omitted.

  If the arity of *fun* == length(*helper_arguments*) + 1 (after prepending *conn* to *helper_arguments* if needed), the page is injected in the query string, these URL parameters will be appended to *helper_arguments* before calling *fun*.

  If the arity of *fun* == length(*helper_arguments*) + 2 (after prepending *conn* to *helper_arguments* if needed), the page is injected in the path so both the page and the query string are appended to *helper_arguments* prior calling *fun* (ie `helper_arguments ++ [page, params]`).

  Notes:

    * keep in mind that this function returns a function, you then have to call it with a page number
    * original parameters (also implies `options.merge_params` != `false`) can only be reproduced when *conn* is an `%URI{}`, a string (binary) or `%Plug.Conn{}`

  Examples:

    ```elixir
    # a blog pagination with Phoenix <= 1.7 way (with a path helper)
    # arity = 3 for [conn/endpoint/socket, :index, [page: 2]]
    fun = #{__MODULE__}.url(conn, &Routes.blog_path/3, [:index])

    # a blog pagination with Phoenix >= 1.7 way (with a verified route)
    fun = #{__MODULE__}.url(nil, fn params -> ~p"/blog?\#{params}" end, [])

    fun.(2)
    # => "/blog?page=2"
    ```

    ```elixir
    # a topic pagination with Phoenix <= 1.7 way (with a path helper)
    # arity = 5 for [conn/endpoint/socket, :show, @topic, page, []] - the last [] is an - explicit - empty query string
    fun = #{__MODULE__}.url(conn, &Routes.forum_topic_page_path/5, [:show])

    # a topic pagination with Phoenix >= 1.7 way (with a verified route)
    fun = #{__MODULE__}.url(nil, fn topic, page, _params -> ~p"/forum/topic/\#{topic}/page/\#{page}" end, [@topic])

    fun.(7)
    # => "/forum/topic/58/page/7"
    ```
  """
  @spec url(
    conn :: conn_or_socket_or_endpoint_or_uri_or_binary_or_nil,
    fun :: (... -> String.t) | nil,
    helper_arguments :: [any],
    options :: options
  ) :: (pos_integer -> String.t) | no_return
  def url(conn, fun, helper_arguments, options = %Scrivener.Phoenix.Options{}) do
    do_url(conn, fun, helper_arguments, fetch_and_sanitize_params(conn, options), options)
  end

  defp do_url(string, fun = nil, helper_arguments = [], sanitized_params, options)
    when is_binary(string)
  do
    string
    |> URI.new!() # => no_return
    |> do_url(fun, helper_arguments, sanitized_params, options)
  end

  defp do_url(uri = %URI{}, _fun = nil, _helper_arguments = [], sanitized_params, options) do
    param_name = to_string(options.param_name)

    fn page ->
      new_query =
        sanitized_params
        |> Map.put(param_name, page)
        # NOTE: URI.encode_query/[12] doesn't handle parameters in list (id[]=3&id[]=5) or map (id[3]=false&id[5]=true) form
        |> Plug.Conn.Query.encode()

      %{uri | query: new_query}
      |> URI.to_string()
    end
  end

  defp do_url(conn, fun, helper_arguments, sanitized_params, options) do
    {:arity, arity} = :erlang.fun_info(fun, :arity)
    handle_arguments(conn, fun, arity, helper_arguments, length(helper_arguments), sanitized_params, options)
  end

  @doc ~S"""
  TODO
  """
  @spec fetch_and_sanitize_params(conn :: conn_or_socket_or_endpoint_or_uri_or_binary_or_nil, options :: options) :: params
  def fetch_and_sanitize_params(conn, options) do
    conn
    |> query_params(options)
    |> Map.delete(to_string(options.param_name))
    |> merge_user_params(options)
#     |> map_to_keyword()
  end

  @spec map_to_keyword(map :: map) :: Keyword.t
  defp map_to_keyword(map = %{}) do
    map
    |> Enum.into([])
  end

if false do
  @doc ~S"""
  Filter query string parameters from the current URL to avoid stupidly copy useless user's one.

  If `options.merge_params` is `true` request's original parameters are taken back (highly discouraged)
  If `options.merge_params` is a list of parameter names (as atoms or strings - binaries), only these will be kept

  Eg for the query string `?redirect=https://www.somesite.tld&keyword=foo`:

    * with `options.merge_params` = `true`: `?redirect=https://www.somesite.tld&keyword=foo`
    * with `options.merge_params` = `[:keyword]`: `?keyword=foo`

  Note: `options.merge_params` = `false` is handled before, not by filter_params/2
  """
end
  @spec filter_params(params :: map, options :: options) :: map
  defp filter_params(params, %Scrivener.Phoenix.Options{merge_params: true}) do
    params
  end

  defp filter_params(params, %Scrivener.Phoenix.Options{merge_params: which})
    when is_list(which)
  do
    Map.take(params, which |> Enum.map(&to_string/1))
  end

if false do
  @doc ~S"""
  Retrieve the current query string parameters from `%Plug.Conn{}` or `%URI{}` if options.merge_params is not `false`

  Returns an empty map `%{}` as default/in other cases.
  """
end
  @spec query_params(conn_or_socket_or_endpoint_or_uri_or_binary_or_nil :: conn_or_socket_or_endpoint_or_uri_or_binary_or_nil, options :: options) :: map
  defp query_params(_, %Scrivener.Phoenix.Options{merge_params: false}) do
    %{}
  end

  defp query_params(conn = %Plug.Conn{}, options) do
    conn = Plug.Conn.fetch_query_params(conn)

    conn.query_params
    |> filter_params(options)
  end

  defp query_params(%URI{query: nil}, _options) do
    %{}
  end

  defp query_params(%URI{query: query}, options)
    when is_binary(query)
  do
    query
    # NOTE: URI.decode_query/[12] doesn't handle parameters in list (id[]=3&id[]=5) or map (id[3]=false&id[5]=true) form
    |> Plug.Conn.Query.decode()
    |> filter_params(options)
  end

  defp query_params(%Phoenix.LiveView.Socket{}, _options) do
    %{}
  end

  # NOTE: also accepts/handles nil
  defp query_params(endpoint, _options)
    when is_atom(endpoint)
  do
    %{}
  end

if false do
  @doc ~S"""
  TODO
  """
end
  defp merge_user_params(new_query_params, _options = %Scrivener.Phoenix.Options{params: nil}) do
    new_query_params
  end

  defp merge_user_params(new_query_params, _options = %Scrivener.Phoenix.Options{params: user_params}) do
    Map.merge(new_query_params, Enum.into(user_params, %{}))
  end

  # if length(arguments) > arity(fun)
  #   the page (its number) is part of route parameters
  # else
  #   it has to be integrated to the query string
  # fi
  # WARNING: usage of the query string implies to use the route with an arity + 1 because Phoenix create routes as:
  # def blog_page_path(conn, action, pageno, options \\ [])

  defp page_as_query_string(route, helper_arguments, sanitized_params, options) do
    param_name = to_string(options.param_name)

    fn page ->
      new_query_params =
        sanitized_params
        |> Map.put(param_name, page)
        |> map_to_keyword()

      apply(route, helper_arguments ++ [new_query_params])
    end
  end

  defp page_as_path(route, helper_arguments, sanitized_params, options) do
    new_query_params =
      sanitized_params
      |> Map.delete(to_string(options.param_name))
      |> map_to_keyword()

    fn page ->
      apply(route, helper_arguments ++ [page, new_query_params])
    end
  end

  # <to handle sigil_p>
  defp handle_arguments(_conn = nil, route, arity, helper_arguments, helper_arguments_length, sanitized_params, options)
    when arity == helper_arguments_length + 2
  do
    page_as_path(route, helper_arguments, sanitized_params, options)
#     fn page, sanitized_params ->
#       new_query_params =
#         sanitized_params
#         |> Map.put(param_name, page)
#         |> map_to_keyword()
#
#       apply(route, helper_arguments ++ [page, new_query_params])
#     end
  end

  defp handle_arguments(_conn = nil, route, arity, helper_arguments, helper_arguments_length, sanitized_params, options)
    when arity == helper_arguments_length + 1
  do
    page_as_query_string(route, helper_arguments, sanitized_params, options)
#     param_name = to_string(options.param_name)
#
#     fn page ->
#       new_query_params =
#         sanitized_params
#         |> Map.put(param_name, page)
#         |> map_to_keyword()
#
#       apply(route, helper_arguments ++ [new_query_params])
#     end
  end
  # </to handle sigil_p>

  # if length(helper_arguments) > arity(fun) then integrate page_number as helper's arguments
  defp handle_arguments(conn, route, arity, helper_arguments, helper_arguments_length, sanitized_params, options)
    when arity == helper_arguments_length + 3 # 3 for (not counted) conn + additionnal parameters (query string) + page (as part of URL's path)
  do
    page_as_path(route, [conn | helper_arguments], sanitized_params, options)
  end

  # else integrate page_number as query string
  defp handle_arguments(conn, route, arity, helper_arguments, helper_arguments_length, sanitized_params, options)
    when arity == helper_arguments_length + 2 # 2 for (not counted) conn + additionnal parameters (query string)
  do
    page_as_query_string(route, [conn | helper_arguments], sanitized_params, options)
  end

  # <user already provided conn/socket/endpoint in helper_arguments>
  defp handle_arguments(conn, route, arity, helper_arguments = [conn | _rest], helper_arguments_length, sanitized_params, options)
    when not is_nil(conn) and arity == helper_arguments_length + 1
  do
    page_as_query_string(route, helper_arguments, sanitized_params, options)
  end

  defp handle_arguments(conn, route, arity, helper_arguments = [conn | _rest], helper_arguments_length, sanitized_params, options)
    when not is_nil(conn) and arity == helper_arguments_length + 2
  do
    page_as_path(route, helper_arguments, sanitized_params, options)
  end
  # </user already provided conn/socket/endpoint in helper_arguments>

#   defp handle_arguments(_conn, route, arity, helper_arguments = [%module{} | _rest], helper_arguments_length, sanitized_params, options)
#     when module in [Plug.Conn, Phoenix.LiveView.Socket] and arity == helper_arguments_length + 1
#   do
#     page_as_query_string(route, helper_arguments, sanitized_params, options)
#   end

#   defp handle_arguments(_conn, route, arity, helper_arguments = [%module{} | _rest], helper_arguments_length, sanitized_params, options)
#     when module in [Plug.Conn, Phoenix.LiveView.Socket] and arity == helper_arguments_length + 2
#   do
#     page_as_path(route, helper_arguments, sanitized_params, options)
#   end

#   defp handle_arguments(_conn, route, arity, helper_arguments = [endpoint | _rest], helper_arguments_length, sanitized_params, options)
#     when is_atom(endpoint) and arity == helper_arguments_length + 1
#   do
#     page_as_query_string(route, helper_arguments, sanitized_params, options)
#   end

#   defp handle_arguments(_conn, route, arity, helper_arguments = [endpoint | _rest], helper_arguments_length, sanitized_params, options)
#     when is_atom(endpoint) and arity == helper_arguments_length + 2
#   do
#     page_as_path(route, helper_arguments, sanitized_params, options)
#   end
end
