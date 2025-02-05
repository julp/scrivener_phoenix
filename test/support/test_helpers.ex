defmodule ScrivenerPhoenix.TestHelpers do
  #alias Scrivener.Phoenix.Page

  def encode_query("" <> query) do
    query
  end

  def encode_query(query) do
    Plug.Conn.Query.encode(query)
  end

  def decode_query("" <> query) do
    Plug.Conn.Query.decode(query)
  end

  def decode_query(query) do
    query
  end

  def set_query("" <> string, query) do
    uri = URI.parse(string)
    %{uri | query: query |> decode_query() |> encode_query()}
  end

  def set_query(conn = %Plug.Conn{}, query) do
    %{conn | query_params: query |> decode_query()}
  end

  def set_query(uri = %URI{}, query) do
    %{uri | query: query |> decode_query() |> encode_query()}
  end

  defp do_compare_uri(result, expected = %URI{}, params) do
    import ExUnit.Assertions

    assert %{result | query: nil} == %{expected | query: nil}
    assert decode_query(result.query) == params
  end

  defp do_compare_uri(result, "" <> expected, params) do
    compare_uri(result, URI.parse(expected), params)
  end

  @doc ~S"""
  Compare *result* to *expected* but ignore *expected*'s  query in favor of *params*
  """
  def compare_uri("" <> result, expected, params) do
    result
    |> URI.parse()
    |> do_compare_uri(expected, params)
  end

  @spec page_count(total_entries :: non_neg_integer, page_size :: pos_integer) :: pos_integer
  defp page_count(total_entries, page_size) do
    div(total_entries - 1, page_size) + 1
  end

  @spec pages_fixture(total_entries :: non_neg_integer, page_size :: pos_integer) :: [Scrivener.Page.t]
  def pages_fixture(total_entries, page_size) do
    total_pages =
      total_entries
      |> page_count(page_size)

    total_pages
    |> Range.new(1)
    |> Enum.reverse()
    |> Enum.map(
      fn page_number ->
        %Scrivener.Page{
          entries: [],
          page_number: page_number,
          page_size: page_size,
          total_pages: total_pages,
          total_entries: total_entries,
        }
      end
    )
  end

  @spec contains_link?(response :: String.t, url :: String.t) :: boolean
  def contains_link?(response, url) do
    response =~ Enum.join(["href=\"", Plug.HTML.html_escape(url), "\""])
  end

  @spec render(conn :: Plug.Conn.t | module, entries :: Scrivener.Page.t, function :: function, params :: list, options :: Keyword.t) :: String.t
  def render(conn, entries = %Scrivener.Page{}, function, params, options \\ []) do
    Phoenix.Template.render_to_string(ScrivenerPhoenixTestWeb.DummyHTML, "index", "html", binding())
  end
end
