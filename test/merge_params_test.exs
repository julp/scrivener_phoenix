defmodule Scrivener.Phoenix.MergeParamsTest do
  use ScrivenerPhoenixWeb.ConnCase, async: true
  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  setup %{conn: conn} do
    [
      conn: %{conn | query_params: %{"page" => "1", "search" => "spaghetti", "per" => "50"}},
    ]
  end

  defp do_query_test(conn, query, options, expected) do
    options = Enum.into(options, %{params: nil, param_name: :page}) # TODO: DRY

    conn
    |> set_query(query)
    |> Scrivener.Phoenix.URLBuilder.fetch_and_sanitize_params(options)
    |> (& assert &1 == expected).()
  end

  defp do_test(conn, fun, helper_arguments, options, expected) do
    options = Enum.into(options, %{params: nil, param_name: :page}) # TODO: DRY
    sanitized_params = Scrivener.Phoenix.URLBuilder.fetch_and_sanitize_params(conn, options)

    uri =
      conn
      # NOTE: for Scrivener.PhoenixView.URLBuilder.url, options were previously converted to a map
      # TODO: add a public intermediary function to build options
      |> Scrivener.Phoenix.URLBuilder.url(fun, helper_arguments, 2, sanitized_params, options)
      |> URI.parse()

    assert expected == URI.decode_query(uri.query)

#     assert Map.delete(expected, to_string(options.param_name)) == Scrivener.Phoenix.URLBuilder.fetch_and_sanitize_params(conn, options)
  end

  describe "test merge_params behaviour" do
    test "query string is dropped when false", %{conn: conn} do
      for route <- [&Routes.blog_post_path/3, &Routes.blog_post_url/3] do
        do_test(conn, route, [:index], [param_name: :seite, merge_params: false], %{"seite" => "2"})
      end
    end

    test "query string is reproduced when true", %{conn: conn} do
      for route <- [&Routes.blog_post_path/3, &Routes.blog_post_url/3] do
        do_test(conn, route, [:index], [param_name: :seite, merge_params: true], %{"seite" =>"2", "page" => "1", "search" => "spaghetti", "per" => "50"})
      end
    end

    test "query string is reproduced but page parameter is overridden if already present when true", %{conn: conn} do
      for route <- [&Routes.blog_post_path/3, &Routes.blog_post_url/3] do
        do_test(conn, route, [:index], [merge_params: true], %{"page" => "2", "search" => "spaghetti", "per" => "50"})
      end
    end

    test "query string is selectively reproduced but page is overridden if already present when a list", %{conn: conn} do
      args = [:index]
      expected = %{"page" => "2", "search" => "spaghetti"}

      do_test(conn, &Routes.blog_post_path/3, args, [merge_params: ~W[search]a], expected)
      do_test(conn, &Routes.blog_post_path/3, args, [merge_params: ~W[search page]a], expected)
      do_test(conn, &Routes.blog_post_url/3, args, [merge_params: ~W[search]], expected)

      expected = %{"page" => "2", "per" => "50"}
      do_test(conn, &Routes.blog_post_path/3, args, [merge_params: ~W[per]], expected)
      do_test(conn, &Routes.blog_post_path/3, args, [merge_params: ~W[per page]], expected)
      do_test(conn, &Routes.blog_post_url/3, args, [merge_params: ~W[per]a], expected)
    end

    test "query string with a list in parameters", %{conn: conn} do
      for source <- [conn, %URI{}] do
        do_query_test(source, "page=1&id[]=5&id[]=3", [merge_params: ~W[id]], %{"id" => ["5", "3"]})
      end
    end

    test "query string with a map in parameters", %{conn: conn} do
      for source <- [conn, %URI{}] do
        do_query_test(source, "page=1&id[5]=false&id[3]=true", [merge_params: ~W[id]], %{"id" => %{"5" => "false", "3" => "true"}})
      end
    end

    # TODO: check QS as output avec user_params: [id: [5, 3]] et user_params: %{id: %{5 => false, 3 => true}
  end
end
