defmodule Scrivener.Phoenix.URLBuilder do
  @typep conn_or_socket_or_endpoint_or_uri :: Scrivener.PhoenixView.conn_or_socket_or_endpoint_or_uri
  @typep options :: Scrivener.PhoenixView.options
  @typep params :: %{optional(String.t) => any}

  @doc ~S"""
  TODO
  """
  @spec url(
    conn :: conn_or_socket_or_endpoint_or_uri,
    fun :: (... -> String.t) | nil,
    helper_arguments :: [any],
    page_number :: pos_integer,
    sanitized_params :: params,
    options :: options
  ) :: String.t # TODO: (pos_integer -> String.t)
  def url(uri = %URI{}, _fun = nil, _helper_arguments, page_number, sanitized_params, options) do
# IF
    new_query =
      sanitized_params
      |> Map.put(to_string(options.param_name), to_string(page_number))
      # NOTE: URI.encode_query/[12] doesn't handle parameters in list (id[]=3&id[]=5) or map (id[3]=false&id[5]=true) form
      |> Plug.Conn.Query.encode()

    %{uri | query: new_query}
    |> URI.to_string()
# ELSE
#     fn page ->
#       new_query =
#         sanitized_params
#         |> Map.put(to_string(options.param_name), page_number)
#         # NOTE: URI.encode_query/[12] doesn't handle parameters in list (id[]=3&id[]=5) or map (id[3]=false&id[5]=true) form
#         |> Plug.Conn.Query.encode()
#
#       %{uri | query: new_query}
#       |> URI.to_string()
#     end
# END
  end

  def url(conn, fun, helper_arguments, page_number, sanitized_params, options) do
    {:arity, arity} = :erlang.fun_info(fun, :arity)
    arguments = handle_arguments(conn, arity, helper_arguments, length(helper_arguments), page_number, sanitized_params, options)
    apply(fun, arguments)
  end


  @doc ~S"""
  TODO
  """
  @spec fetch_and_sanitize_params(conn :: conn_or_socket_or_endpoint_or_uri, options :: options) :: params
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
  defp filter_params(params, %{merge_params: true}) do
    params
  end

  defp filter_params(params, %{merge_params: which})
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
  @spec query_params(conn_or_socket_or_endpoint_or_uri :: conn_or_socket_or_endpoint_or_uri, options :: options) :: map
  defp query_params(_, %{merge_params: false}) do
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
  defp merge_user_params(new_query_params, _options = %{params: nil}) do
    new_query_params
  end

  defp merge_user_params(new_query_params, _options = %{params: user_params}) do
    Map.merge(new_query_params, Enum.into(user_params, %{}))
  end

  # if length(arguments) > arity(fun)
  #   the page (its number) is part of route parameters
  # else
  #   it has to be integrated to the query string
  # fi
  # WARNING: usage of the query string implies to use the route with an arity + 1 because Phoenix create routes as:
  # def blog_page_path(conn, action, pageno, options \\ [])

  defp page_as_query_string(helper_arguments, page_number, sanitized_params, options) do
# IF
    new_query_params =
      sanitized_params
      |> Map.put(to_string(options.param_name), page_number)
      |> map_to_keyword()

    helper_arguments ++ [new_query_params]
# ELSE
    # TODO: fun undefined
#     fn page ->
#       new_query_params =
#         sanitized_params
#         |> Map.put(to_string(options.param_name), page_number)
#         |> map_to_keyword()
#
#       apply(fun, helper_arguments ++ [new_query_params])
#     end
# END
  end

  defp page_as_path(helper_arguments, page_number, sanitized_params, options) do
    new_query_params =
      sanitized_params
      |> Map.delete(to_string(options.param_name))
      |> map_to_keyword()
# IF
    helper_arguments ++ [page_number, new_query_params]
# ELSE
    # TODO: fun undefined
#     fn page ->
#       apply(fun, helper_arguments ++ [page_number, new_query_params])
#     end
# END
  end

  # if length(helper_arguments) > arity(fun) then integrate page_number as helper's arguments
  defp handle_arguments(conn, arity, helper_arguments, helper_arguments_length, page_number, sanitized_params, options)
    when arity == helper_arguments_length + 3 # 3 for (not counted) conn + additionnal parameters (query string) + page (as part of URL's path)
  do
    page_as_path([conn | helper_arguments], page_number, sanitized_params, options)
  end

  # else integrate page_number as query string
  defp handle_arguments(conn, arity, helper_arguments, helper_arguments_length, page_number, sanitized_params, options)
    when arity == helper_arguments_length + 2 # 2 for (not counted) conn + additionnal parameters (query string)
  do
    page_as_query_string([conn | helper_arguments], page_number, sanitized_params, options)
  end

  # <user already provided conn/socket/endpoint in helper_arguments>
  defp handle_arguments(conn, arity, helper_arguments = [conn | _rest], helper_arguments_length, page_number, sanitized_params, options)
    when not is_nil(conn) and arity == helper_arguments_length + 1
  do
    page_as_query_string(helper_arguments, page_number, sanitized_params, options)
  end

  defp handle_arguments(conn, arity, helper_arguments = [conn | _rest], helper_arguments_length, page_number, sanitized_params, options)
    when not is_nil(conn) and arity == helper_arguments_length + 2
  do
    page_as_path(helper_arguments, page_number, sanitized_params, options)
  end
  # </user already provided conn/socket/endpoint in helper_arguments>

#   defp handle_arguments(_conn, arity, helper_arguments = [%module{} | _rest], helper_arguments_length, page_number, sanitized_params, options)
#     when module in [Plug.Conn, Phoenix.LiveView.Socket] and arity == helper_arguments_length + 1
#   do
#     page_as_query_string(helper_arguments, page_number, sanitized_params, options)
#   end

#   defp handle_arguments(_conn, arity, helper_arguments = [%module{} | _rest], helper_arguments_length, page_number, sanitized_params, options)
#     when module in [Plug.Conn, Phoenix.LiveView.Socket] and arity == helper_arguments_length + 2
#   do
#     page_as_path(helper_arguments, page_number, sanitized_params, options)
#   end

#   defp handle_arguments(_conn, arity, helper_arguments = [endpoint | _rest], helper_arguments_length, page_number, sanitized_params, options)
#     when is_atom(endpoint) and arity == helper_arguments_length + 1
#   do
#     page_as_query_string(helper_arguments, page_number, sanitized_params, options)
#   end

#   defp handle_arguments(_conn, arity, helper_arguments = [endpoint | _rest], helper_arguments_length, page_number, sanitized_params, options)
#     when is_atom(endpoint) and arity == helper_arguments_length + 2
#   do
#     page_as_path(helper_arguments, page_number, sanitized_params, options)
#   end
end
