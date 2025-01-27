defmodule Scrivener.Phoenix.RoutesTestBis do
  use ScrivenerPhoenixWeb.ConnCase, async: true
  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  defp blog_post_path(conn) do
    [
      {conn, &Routes.blog_post_path/3, [:index]},
      {conn, &Routes.blog_post_path/3, [conn, :index]},
      {@endpoint, &Routes.blog_post_path/3, [:index]},
      {@endpoint, &Routes.blog_post_path/3, [@endpoint, :index]},
      {"/blog/posts", nil, []},
      {%URI{path: "/blog/posts"}, nil, []},
      {nil, fn params -> ~p"/blog/posts?#{params}" end, []},
    ]
  end

  describe "XXX" do
    test "blog_post_path", %{conn: conn} do
      for {conn, route, args} <- blog_post_path(conn) do
        options = Scrivener.Phoenix.Options.merge([])
        fun = Scrivener.Phoenix.URLBuilder.url(conn, route, args, options)

        assert fun.(2) == "/blog/posts?page=2"
      end
    end
  end
end
