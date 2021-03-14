defmodule Scrivener.Phoenix.RoutesTest do
  use ScrivenerPhoenixWeb.ConnCase, async: true

  import Phoenix.View
  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  setup do
    [page1, _page2] = pages_fixture(18, 10)
    [
      entries: page1,
    ]
  end

  defp render(conn, entries, function, params, options \\ []) do
    render_to_string(ScrivenerPhoenixTestWeb.DummyView, "index.html", binding())
  end

  @url "https://www.scrivener-phoenix.test:2043"
  @endpoint ScrivenerPhoenixTestWeb.Endpoint
  # MIX_ENV=test mix phx.routes ScrivenerPhoenixTestWeb.Router
  describe "ensures path are properly generated from a %Plug.Conn{} or endpoint" do
    test "blog_post_path/3", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.blog_post_path/3, [:index], param_name: :seite)
        |> (& assert &1 =~ ~S|href="/blog/posts?seite=2"|).()

        render(conn_or_endpoint, entries, &Routes.blog_post_url/3, [:index], param_name: :seite)
        |> (& assert &1 =~ ~s|href="#{@url}/blog/posts?seite=2"|).()
      end
    end

    test "blog_seite_path/4", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.blog_seite_path/4, [:index])
        |> (& assert &1 =~ ~S|href="/blog/posts/seite/2"|).()

        render(conn_or_endpoint, entries, &Routes.blog_seite_url/4, [:index])
        |> (& assert &1 =~ ~s|href="#{@url}/blog/posts/seite/2"|).()
      end
    end

    test "forum_topic_path/4", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.forum_topic_path/4, [:show, 643])
        |> (& assert &1 =~ ~S|href="/forum/topics/643?page=2"|).()

        render(conn_or_endpoint, entries, &Routes.forum_topic_url/4, [:show, 643])
        |> (& assert &1 =~ ~s|href="#{@url}/forum/topics/643?page=2"|).()

        #render(conn, entries, &Routes.forum_topic_path/4, [:show, 643, [:foo, "bar"]])
        #|> (& assert &1 =~ ~S|href="/forum/topics/643?page=2&foo=bar"|).()
      end
    end

    test "forum_topic_page_path/5", %{conn: conn, entries: entries} do
      for conn_or_endpoint <- [conn, @endpoint] do
        render(conn_or_endpoint, entries, &Routes.forum_topic_page_path/5, [:show, 564])
        |> (& assert &1 =~ ~S|href="/forum/topics/564/page/2"|).()

        render(conn_or_endpoint, entries, &Routes.forum_topic_page_url/5, [:show, 564])
        |> (& assert &1 =~ ~s|href="#{@url}/forum/topics/564/page/2"|).()

        #render(conn, entries, &Routes.forum_topic_page_path/5, [:show, 564, [search: "spaghetti"]])
        #|> (& assert &1 =~ ~S|href="/forum/topics/564/page/2?search=spaghetti"|).()
      end
    end
  end
end
