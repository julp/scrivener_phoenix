defmodule Scrivener.Phoenix.RoutesTest do
  use ScrivenerPhoenixWeb.ConnCase, async: true
  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  setup do
    [page1, _page2] = pages_fixture(18, 10)
    [
      entries: page1,
    ]
  end

  @url "https://www.scrivener-phoenix.test:2043"
  @endpoint ScrivenerPhoenixTestWeb.Endpoint
  # MIX_ENV=test mix phx.routes ScrivenerPhoenixTestWeb.Router
  describe "ensures path are properly generated from a %Plug.Conn{} or endpoint" do
    test "blog_post_(path|url)/3", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.blog_post_path/3, [:index], param_name: :seite)
        |> (& assert contains_link?(&1, "/blog/posts?seite=2")).()

        render(conn_or_endpoint, entries, &Routes.blog_post_url/3, [:index], param_name: :seite)
        |> (& assert contains_link?(&1, "#{@url}/blog/posts?seite=2")).()
      end
    end

    test "blog_seite_(path|url)/4", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.blog_seite_path/4, [:index])
        |> (& assert contains_link?(&1, "/blog/posts/seite/2")).()

        render(conn_or_endpoint, entries, &Routes.blog_seite_url/4, [:index])
        |> (& assert contains_link?(&1, "#{@url}/blog/posts/seite/2")).()
      end
    end

    test "forum_topic_(path|url)/4", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.forum_topic_path/4, [:show, 643])
        |> (& assert contains_link?(&1, "/forum/topics/643?page=2")).()

        render(conn_or_endpoint, entries, &Routes.forum_topic_url/4, [:show, 643])
        |> (& assert contains_link?(&1, "#{@url}/forum/topics/643?page=2")).()
      end
    end

    test "forum_topic_page_(path|url)/5", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.forum_topic_page_path/5, [:show, 564])
        |> (& assert contains_link?(&1, "/forum/topics/564/page/2")).()

        render(conn_or_endpoint, entries, &Routes.forum_topic_page_url/5, [:show, 564])
        |> (& assert contains_link?(&1, "#{@url}/forum/topics/564/page/2")).()
      end
    end
  end
end
