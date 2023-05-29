defmodule Scrivener.Phoenix.MergeParamsTest do
  use ScrivenerPhoenixWeb.ConnCase, async: true

  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  setup %{conn: conn} do
    [
      conn: %{conn | query_params: %{"page" => "1", "search" => "spaghetti", "per" => "50"}},
    ]
  end

  defp do_test(conn, fun, helper_arguments, options, expected) do
    uri =
      conn
      # NOTE: for Scrivener.PhoenixView.url, options were previously converted to a map
      # TODO: add a public intermediary function to build options
      |> Scrivener.PhoenixView.url(fun, helper_arguments, 2, Enum.into(options, %{params: nil, param_name: :page}))
      |> URI.parse()
    assert expected == URI.decode_query(uri.query)
  end

  describe "test merge_params behaviour" do
    test "query string is dropped when false", %{conn: conn} do
      do_test(conn, &Routes.blog_post_path/3, [:index], [param_name: :seite, merge_params: false], %{"seite" => "2"})
      do_test(conn, &Routes.blog_post_url/3, [:index], [param_name: :seite, merge_params: false], %{"seite" => "2"})
    end

    test "query string is reproduced when true", %{conn: conn} do
      do_test(conn, &Routes.blog_post_path/3, [:index], [param_name: :seite, merge_params: true], %{"seite" =>"2", "page" => "1", "search" => "spaghetti", "per" => "50"})
      do_test(conn, &Routes.blog_post_url/3, [:index], [param_name: :seite, merge_params: true], %{"seite" =>"2", "page" => "1", "search" => "spaghetti", "per" => "50"})
    end

    test "query string is reproduced but page parameter is overridden if already present when true", %{conn: conn} do
      do_test(conn, &Routes.blog_post_path/3, [:index], [merge_params: true], %{"page" => "2", "search" => "spaghetti", "per" => "50"})
      do_test(conn, &Routes.blog_post_url/3, [:index], [merge_params: true], %{"page" => "2", "search" => "spaghetti", "per" => "50"})
    end

    test "query string is selectively reproduced but page is overridden if already present when a list", %{conn: conn} do
      do_test(conn, &Routes.blog_post_path/3, [:index], [merge_params: ~W[search]a], %{"page" => "2", "search" => "spaghetti"})
      do_test(conn, &Routes.blog_post_path/3, [:index], [merge_params: ~W[search page]a], %{"page" => "2", "search" => "spaghetti"})
      do_test(conn, &Routes.blog_post_url/3, [:index], [merge_params: ~W[search]], %{"page" => "2", "search" => "spaghetti"})

      do_test(conn, &Routes.blog_post_path/3, [:index], [merge_params: ~W[per]], %{"page" => "2", "per" => "50"})
      do_test(conn, &Routes.blog_post_path/3, [:index], [merge_params: ~W[per page]], %{"page" =>"2", "per" => "50"})
      do_test(conn, &Routes.blog_post_url/3, [:index], [merge_params: ~W[per]a], %{"page" => "2", "per" => "50"})
    end
  end
end
