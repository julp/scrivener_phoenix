defmodule Scrivener.Phoenix.RoutesTestBis do
  use ScrivenerPhoenixWeb.ConnCase, async: true
  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  defmodule Topic do
    @derive {Phoenix.Param, key: :uuid}
    defstruct ~W[uuid]a
  end

  defp blog_post_path(conn) do
    {
      true,
      [
        {conn, &Routes.blog_post_path/3, [:index]},
        {conn, &Routes.blog_post_path/3, [conn, :index]},
        {@endpoint, &Routes.blog_post_path/3, [:index]},
        {@endpoint, &Routes.blog_post_path/3, [@endpoint, :index]},
        {"/blog/posts", nil, []},
        {%URI{path: "/blog/posts"}, nil, []},
        {nil, fn params -> ~p"/blog/posts?#{params}" end, []},
        {conn, fn _conn, params -> ~p"/blog/posts?#{params}" end, []},
        {@endpoint, fn _endpoint, params -> ~p"/blog/posts?#{params}" end, []},
        {conn, fn _conn, params -> ~p"/blog/posts?#{params}" end, [conn]},
        {@endpoint, fn _endpoint, params -> ~p"/blog/posts?#{params}" end, [@endpoint]},
      ]
    }
  end

  defp blog_post_url(conn) do
    {
      true,
      [
        {conn, &Routes.blog_post_url/3, [:index]},
        {conn, &Routes.blog_post_url/3, [conn, :index]},
        {@endpoint, &Routes.blog_post_url/3, [:index]},
        {@endpoint, &Routes.blog_post_url/3, [@endpoint, :index]},
        {"#{@url}/blog/posts", nil, []},
        {URI.merge(URI.parse(@url), %URI{path: "/blog/posts"}), nil, []},
        {nil, fn params -> @url <> ~p"/blog/posts?#{params}" end, []},
        {conn, fn _conn, params -> @url <> ~p"/blog/posts?#{params}" end, []},
        {@endpoint, fn _endpoint, params -> @url <> ~p"/blog/posts?#{params}" end, []},
        {conn, fn _conn, params -> @url <> ~p"/blog/posts?#{params}" end, [conn]},
        {@endpoint, fn _endpoint, params -> @url <> ~p"/blog/posts?#{params}" end, [@endpoint]},
      ]
    }
  end

  defp blog_seite_path(conn) do
    {
      false,
      [
        {conn, &Routes.blog_seite_path/4, [:index]},
        {conn, &Routes.blog_seite_path/4, [conn, :index]},
        {@endpoint, &Routes.blog_seite_path/4, [:index]},
        {@endpoint, &Routes.blog_seite_path/4, [@endpoint, :index]},
        {nil, fn page, params -> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
        {conn, fn _conn, page, params -> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
        {@endpoint, fn _endpoint, page, params -> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
        {conn, fn _conn, page, params -> ~p"/blog/posts/seite/#{page}?#{params}" end, [conn]},
        {@endpoint, fn _endpoint, page, params -> ~p"/blog/posts/seite/#{page}?#{params}" end, [@endpoint]},
      ]
    }
  end

  defp blog_seite_url(conn) do
    {
      false,
      [
        {conn, &Routes.blog_seite_url/4, [:index]},
        {conn, &Routes.blog_seite_url/4, [conn, :index]},
        {@endpoint, &Routes.blog_seite_url/4, [:index]},
        {@endpoint, &Routes.blog_seite_url/4, [@endpoint, :index]},
        {nil, fn page, params -> @url <> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
        {conn, fn _conn, page, params -> @url <> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
        {@endpoint, fn _endpoint, page, params -> @url <> ~p"/blog/posts/seite/#{page}?#{params}" end, []},
        {conn, fn _conn, page, params -> @url <> ~p"/blog/posts/seite/#{page}?#{params}" end, [conn]},
        {@endpoint, fn _endpoint, page, params -> @url <> ~p"/blog/posts/seite/#{page}?#{params}" end, [@endpoint]},
      ]
    }
  end

  defp forum_topic_path(conn) do
    topic = %Topic{uuid: 643}

    {
    true,
      [
        {conn, &Routes.forum_topic_path/4, [:show, topic.uuid]},
        {conn, &Routes.forum_topic_path/4, [conn, :show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_path/4, [:show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_path/4, [@endpoint, :show, topic.uuid]},
        {"/forum/topics/#{topic.uuid}", nil, []},
        {%URI{path: "/forum/topics/#{topic.uuid}"}, nil, []},
        {nil, fn topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},
        {@endpoint, fn _endpoint, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [conn, topic.uuid]},
        {@endpoint, fn _endpoint, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [@endpoint, topic.uuid]},

        {conn, &Routes.forum_topic_path/4, [:show, topic]},
        {conn, &Routes.forum_topic_path/4, [conn, :show, topic]},
        {@endpoint, &Routes.forum_topic_path/4, [:show, topic]},
        {@endpoint, &Routes.forum_topic_path/4, [@endpoint, :show, topic]},
        {nil, fn topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
        {conn, fn _conn, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
        {@endpoint, fn _endpoint, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
        {conn, fn _conn, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [conn, topic]},
        {@endpoint, fn _endpoint, topic, params -> ~p"/forum/topics/#{topic}?#{params}" end, [@endpoint, topic]},
      ]
    }
  end

  defp forum_topic_url(conn) do
    topic = %Topic{uuid: 587}

    {
      true,
      [
        {conn, &Routes.forum_topic_url/4, [:show, topic.uuid]},
        {conn, &Routes.forum_topic_url/4, [conn, :show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_url/4, [:show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_url/4, [@endpoint, :show, topic.uuid]},
        {"#{@url}/forum/topics/#{topic.uuid}", nil, []},
        {URI.merge(URI.parse(@url), %URI{path: "/forum/topics/#{topic.uuid}"}), nil, []},
        {nil, fn topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},
        {@endpoint, fn _endpoint, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [conn, topic.uuid]},
        {@endpoint, fn _endpoint, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [@endpoint, topic.uuid]},

        {conn, &Routes.forum_topic_url/4, [:show, topic]},
        {conn, &Routes.forum_topic_url/4, [conn, :show, topic]},
        {@endpoint, &Routes.forum_topic_url/4, [:show, topic]},
        {@endpoint, &Routes.forum_topic_url/4, [@endpoint, :show, topic]},
        {nil, fn topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
        {conn, fn _conn, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
        {@endpoint, fn _endpoint, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [topic]},
        {conn, fn _conn, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [conn, topic]},
        {@endpoint, fn _endpoint, topic, params -> @url <> ~p"/forum/topics/#{topic}?#{params}" end, [@endpoint, topic]},
      ]
    }
  end

  defp forum_topic_page_path(conn) do
    topic = %Topic{uuid: 127}

    {
      false,
      [
        {conn, &Routes.forum_topic_page_path/5, [:show, topic.uuid]},
        {conn, &Routes.forum_topic_page_path/5, [conn, :show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_page_path/5, [:show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_page_path/5, [@endpoint, :show, topic.uuid]},
        {nil, fn topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},
        {@endpoint, fn _endpoint, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [conn, topic.uuid]},
        {@endpoint, fn _endpoint, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [@endpoint, topic.uuid]},

        {conn, &Routes.forum_topic_page_path/5, [:show, topic]},
        {conn, &Routes.forum_topic_page_path/5, [conn, :show, topic]},
        {@endpoint, &Routes.forum_topic_page_path/5, [:show, topic]},
        {@endpoint, &Routes.forum_topic_page_path/5, [@endpoint, :show, topic]},
        {nil, fn topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
        {conn, fn _conn, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
        {@endpoint, fn _endpoint, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
        {conn, fn _conn, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [conn, topic]},
        {@endpoint, fn _endpoint, topic, page, params -> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [@endpoint, topic]},
      ]
    }
  end

  defp forum_topic_page_url(conn) do
    topic = %Topic{uuid: 946}

    {
      false,
      [
        {conn, &Routes.forum_topic_page_url/5, [:show, topic.uuid]},
        {conn, &Routes.forum_topic_page_url/5, [conn, :show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_page_url/5, [:show, topic.uuid]},
        {@endpoint, &Routes.forum_topic_page_url/5, [@endpoint, :show, topic.uuid]},
        {nil, fn topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},
        {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic.uuid]},
        {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [conn, topic.uuid]},
        {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [@endpoint, topic.uuid]},

        {conn, &Routes.forum_topic_page_url/5, [:show, topic]},
        {conn, &Routes.forum_topic_page_url/5, [conn, :show, topic]},
        {@endpoint, &Routes.forum_topic_page_url/5, [:show, topic]},
        {@endpoint, &Routes.forum_topic_page_url/5, [@endpoint, :show, topic]},
        {nil, fn topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
        {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
        {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [topic]},
        {conn, fn _conn, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [conn, topic]},
        {@endpoint, fn _endpoint, topic, page, params -> @url <> ~p"/forum/topics/#{topic}/page/#{page}?#{params}" end, [@endpoint, topic]},
      ]
    }
  end

  defp do_test(conn, fun, expected_path, options)
    when is_function(fun, 1)
  do
    {page_in_qs?, set} = fun.(conn)
    for {conn, route, args} <- set do
      expected_query =
        if page_in_qs? do
          %{to_string(options.param_name) => 2}
        else
          %{}
        end

      fun = Scrivener.Phoenix.URLBuilder.url(conn, route, args, options)

#       assert fun.(2) == expected_path#.(2)
      compare_uri(fun.(2), expected_path, expected_query)
    end
  end

  defp support_initial_query?(%URI{}), do: true
  defp support_initial_query?("" <> _rest), do: true
  defp support_initial_query?(%Plug.Conn{}), do: true
  defp support_initial_query?(_), do: false

  defp do_test2(conn, fun, expected_path, initial_query, options)
    when is_function(fun, 1)
  do
    conn = conn |> set_query(initial_query)

    {page_in_qs?, set} = fun.(conn)
    for {conn, route, args} <- set, support_initial_query?(conn) do
      expected_query =
        if page_in_qs? do
          Map.put(initial_query, to_string(options.param_name), 2)
        else
          Map.delete(initial_query, to_string(options.param_name))
        end

      fun =
        conn
        |> set_query(initial_query)
        |> Scrivener.Phoenix.URLBuilder.url(route, args, options)

#       assert fun.(2) == expected_path#.(2)
      compare_uri(fun.(2), expected_path, expected_query)
    end
  end

  describe "XXX" do
    setup do
      [
        options: Scrivener.Phoenix.Options.merge([])
      ]
    end

    test "blog_post_path", %{conn: conn, options: options} do
      do_test(conn, &blog_post_path/1, "/blog/posts", options)
    end

    test "blog_post_url", %{conn: conn, options: options} do
      do_test(conn, &blog_post_url/1, "#{@url}/blog/posts", options)
    end

    test "blog_seite_path", %{conn: conn, options: options} do
      do_test(conn, &blog_seite_path/1, "/blog/posts/seite/2", options)
    end

    test "blog_seite_url", %{conn: conn, options: options} do
      do_test(conn, &blog_seite_url/1, "#{@url}/blog/posts/seite/2", options)
    end

    test "forum_topic_path", %{conn: conn, options: options} do
      do_test(conn, &forum_topic_path/1, "/forum/topics/643", options)
    end

    test "forum_topic_url", %{conn: conn, options: options} do
      do_test(conn, &forum_topic_url/1, "#{@url}/forum/topics/587", options) # fn page -> "#{@url}/forum/topics/587?page=#{page}" end
    end

    test "forum_topic_page_path", %{conn: conn, options: options} do
      do_test(conn, &forum_topic_page_path/1, "/forum/topics/127/page/2", options)
    end

    test "forum_topic_page_url", %{conn: conn, options: options} do
      do_test(conn, &forum_topic_page_url/1, "#{@url}/forum/topics/946/page/2", options)
    end
  end

  describe "YYY" do
    setup do
      [
        initial_query: %{"foo" => "bar"},
        options: Scrivener.Phoenix.Options.merge([merge_params: true]),
      ]
    end

    test "blog_post_path", assigns do
      do_test2(assigns.conn, &blog_post_path/1, "/blog/posts", assigns.initial_query, assigns.options)
    end

    test "blog_post_url", assigns do
      do_test2(assigns.conn, &blog_post_url/1, "#{@url}/blog/posts", assigns.initial_query, assigns.options)
    end

    test "blog_seite_path", assigns do
      do_test2(assigns.conn, &blog_seite_path/1, "/blog/posts/seite/2", assigns.initial_query, assigns.options)
    end

    test "blog_seite_url", assigns do
      do_test2(assigns.conn, &blog_seite_url/1, "#{@url}/blog/posts/seite/2", assigns.initial_query, assigns.options)
    end

    test "forum_topic_path", assigns do
      do_test2(assigns.conn, &forum_topic_path/1, "/forum/topics/643", assigns.initial_query, assigns.options)
    end

    test "forum_topic_url", assigns do
      do_test2(assigns.conn, &forum_topic_url/1, "#{@url}/forum/topics/587", assigns.initial_query, assigns.options)
    end

    test "forum_topic_page_path", assigns do
      do_test2(assigns.conn, &forum_topic_page_path/1, "/forum/topics/127/page/2", assigns.initial_query, assigns.options)
    end

    test "forum_topic_page_url", assigns do
      do_test2(assigns.conn, &forum_topic_page_url/1, "#{@url}/forum/topics/946/page/2", assigns.initial_query, assigns.options)
    end
  end
end
