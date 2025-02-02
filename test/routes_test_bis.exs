defmodule Scrivener.Phoenix.RoutesTestBis do
  use ScrivenerPhoenixWeb.ConnCase, async: true
  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  defmodule Topic do
    @derive {Phoenix.Param, key: :uuid}
    defstruct ~W[uuid]a
  end

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

  defp blog_post_url(conn) do
    [
      {conn, &Routes.blog_post_url/3, [:index]},
      {conn, &Routes.blog_post_url/3, [conn, :index]},
      {@endpoint, &Routes.blog_post_url/3, [:index]},
      {@endpoint, &Routes.blog_post_url/3, [@endpoint, :index]},
      {"#{@url}/blog/posts", nil, []},
      {URI.merge(URI.parse(@url), %URI{path: "/blog/posts"}), nil, []},
      {nil, fn params -> @url <> ~p"/blog/posts?#{params}" end, []},
    ]
  end

  defp blog_seite_path(conn) do
    [
      {conn, &Routes.blog_seite_path/4, [:index]},
      {conn, &Routes.blog_seite_path/4, [conn, :index]},
      {@endpoint, &Routes.blog_seite_path/4, [:index]},
      {@endpoint, &Routes.blog_seite_path/4, [@endpoint, :index]},
      {nil, fn page, params -> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
    ]
  end

  defp blog_seite_url(conn) do
    [
      {conn, &Routes.blog_seite_url/4, [:index]},
      {conn, &Routes.blog_seite_url/4, [conn, :index]},
      {@endpoint, &Routes.blog_seite_url/4, [:index]},
      {@endpoint, &Routes.blog_seite_url/4, [@endpoint, :index]},
      {nil, fn page, params -> @url <> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
    ]
  end

  def forum_topic_path(conn) do
    topic = %Topic{uuid: 643}

    [
      {conn, &Routes.forum_topic_path/4, [:show, topic.uuid]},
      {conn, &Routes.forum_topic_path/4, [conn, :show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_path/4, [:show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_path/4, [@endpoint, :show, topic.uuid]},
      {"/forum/topics/#{topic.uuid}", nil, []},
      {%URI{path: "/forum/topics/#{topic.uuid}"}, nil, []},
      {nil, fn topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},

      {conn, &Routes.forum_topic_path/4, [:show, topic]},
      {conn, &Routes.forum_topic_path/4, [conn, :show, topic]},
      {@endpoint, &Routes.forum_topic_path/4, [:show, topic]},
      {@endpoint, &Routes.forum_topic_path/4, [@endpoint, :show, topic]},
      {nil, fn topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
    ]
  end

  def forum_topic_url(conn) do
    topic = %Topic{uuid: 587}

    [
      {conn, &Routes.forum_topic_url/4, [:show, topic.uuid]},
      {conn, &Routes.forum_topic_url/4, [conn, :show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_url/4, [:show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_url/4, [@endpoint, :show, topic.uuid]},
      {"#{@url}/forum/topics/#{topic.uuid}", nil, []},
      {URI.merge(URI.parse(@url), %URI{path: "/forum/topics/#{topic.uuid}"}), nil, []},
      {nil, fn topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},

      {conn, &Routes.forum_topic_url/4, [:show, topic]},
      {conn, &Routes.forum_topic_url/4, [conn, :show, topic]},
      {@endpoint, &Routes.forum_topic_url/4, [:show, topic]},
      {@endpoint, &Routes.forum_topic_url/4, [@endpoint, :show, topic]},
      {nil, fn topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
    ]
  end

  def forum_topic_page_path(conn) do
    topic = %Topic{uuid: 127}

    [
      {conn, &Routes.forum_topic_page_path/5, [:show, topic.uuid]},
      {conn, &Routes.forum_topic_page_path/5, [conn, :show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_page_path/5, [:show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_page_path/5, [@endpoint, :show, topic.uuid]},
      {nil, fn topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},

      {conn, &Routes.forum_topic_page_path/5, [:show, topic]},
      {conn, &Routes.forum_topic_page_path/5, [conn, :show, topic]},
      {@endpoint, &Routes.forum_topic_page_path/5, [:show, topic]},
      {@endpoint, &Routes.forum_topic_page_path/5, [@endpoint, :show, topic]},
      {nil, fn topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
    ]
  end

  def forum_topic_page_url(conn) do
    topic = %Topic{uuid: 946}

    [
      {conn, &Routes.forum_topic_page_url/5, [:show, topic.uuid]},
      {conn, &Routes.forum_topic_page_url/5, [conn, :show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_page_url/5, [:show, topic.uuid]},
      {@endpoint, &Routes.forum_topic_page_url/5, [@endpoint, :show, topic.uuid]},
      {nil, fn topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},
      {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]}, # +
      {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]}, # +
      {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [conn, topic.uuid]}, # +
      {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [@endpoint, topic.uuid]}, # +

      {conn, &Routes.forum_topic_page_url/5, [:show, topic]},
      {conn, &Routes.forum_topic_page_url/5, [conn, :show, topic]},
      {@endpoint, &Routes.forum_topic_page_url/5, [:show, topic]},
      {@endpoint, &Routes.forum_topic_page_url/5, [@endpoint, :show, topic]},
      {nil, fn topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
      {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]}, # +
      {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]}, # +
      {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [conn, topic]}, # +
      {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [@endpoint, topic]}, # +
    ]
  end

  defp do_test(conn, fun, expected)
    when is_function(fun, 1)
  do
    options = Scrivener.Phoenix.Options.merge([])
    for {conn, route, args} <- fun.(conn) do
      fun = Scrivener.Phoenix.URLBuilder.url(conn, route, args, options)

      assert fun.(2) == expected#.(2)
    end
  end

  defp do_test2(conn, fun, expected)
    when is_function(fun, 1)
  do
    options = Scrivener.Phoenix.Options.merge([merge_params: true])
    for {conn, route, args} <- fun.(conn), is_struct(conn, Plug.Conn) do
      fun = Scrivener.Phoenix.URLBuilder.url(conn, route, args, options)

      assert fun.(2) == expected#.(2)
    end
  end

  describe "XXX" do
    test "blog_post_path", %{conn: conn} do
      do_test(conn, &blog_post_path/1, "/blog/posts?page=2")
    end

    test "blog_post_url", %{conn: conn} do
      do_test(conn, &blog_post_url/1, "#{@url}/blog/posts?page=2")
    end

    test "blog_seite_path", %{conn: conn} do
      do_test(conn, &blog_seite_path/1, "/blog/posts/seite/2")
    end

    test "blog_seite_url", %{conn: conn} do
      do_test(conn, &blog_seite_url/1, "#{@url}/blog/posts/seite/2")
    end

    test "forum_topic_path", %{conn: conn} do
      do_test(conn, &forum_topic_path/1, "/forum/topics/643?page=2")
    end

    test "forum_topic_url", %{conn: conn} do
      do_test(conn, &forum_topic_url/1, "#{@url}/forum/topics/587?page=2") # fn page -> "#{@url}/forum/topics/587?page=#{page}" end
    end

    test "forum_topic_page_path", %{conn: conn} do
      do_test(conn, &forum_topic_page_path/1, "/forum/topics/127/page/2")
    end

    test "forum_topic_page_url", %{conn: conn} do
      do_test(conn, &forum_topic_page_url/1, "#{@url}/forum/topics/946/page/2")
    end
  end

  describe "YYY" do
    test "blog_post_path", %{conn: conn} do
      do_test2(conn, &blog_post_path/1, "/blog/posts?page=2")
    end

    test "blog_post_url", %{conn: conn} do
      do_test2(conn, &blog_post_url/1, "#{@url}/blog/posts?page=2")
    end

    test "blog_seite_path", %{conn: conn} do
      do_test2(conn, &blog_seite_path/1, "/blog/posts/seite/2")
    end

    test "blog_seite_url", %{conn: conn} do
      conn
      |> set_query(%{"foo" => "bar"})
      |> do_test2(&blog_seite_url/1, "#{@url}/blog/posts/seite/2?foo=bar")
    end

    test "forum_topic_path", %{conn: conn} do
      do_test2(conn, &forum_topic_path/1, "/forum/topics/643?page=2")
    end

    test "forum_topic_url", %{conn: conn} do
      do_test2(conn, &forum_topic_url/1, "#{@url}/forum/topics/587?page=2")
    end

    test "forum_topic_page_path", %{conn: conn} do
      do_test2(conn, &forum_topic_page_path/1, "/forum/topics/127/page/2")
    end

    test "forum_topic_page_url", %{conn: conn} do
      do_test2(conn, &forum_topic_page_url/1, "#{@url}/forum/topics/946/page/2")
    end
  end
end
