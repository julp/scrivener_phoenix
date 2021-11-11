defmodule Scrivener.Phoenix.DisplayIfSingleTest do
  use ScrivenerPhoenixWeb.ConnCase, async: true
  alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

  defp active_page_presence?(output, no \\ 1) do
    output =~ "<li class=\"page-item active\"><a class=\"page-link\" href=\"#\">#{no}</a></li>"
  end

  @parameters [:show, 643]
  test "pagination displays a (non-empty) single page only when display_if_single = true", %{conn: conn} do
    [page] = pages_fixture(3, 10)

    render(conn, page, &Routes.forum_topic_path/4, @parameters, display_if_single: true)
    |> (& assert active_page_presence?(&1)).()

    render(conn, page, &Routes.forum_topic_path/4, @parameters, display_if_single: false)
    |> (& refute active_page_presence?(&1)).()
  end

  test "pagination is not displayed for a total of 0 result (independently of display_if_single)", %{conn: conn} do
    [page] = pages_fixture(0, 10)

    render(conn, page, &Routes.forum_topic_path/4, @parameters, display_if_single: true)
    |> (& refute active_page_presence?(&1)).()

    render(conn, page, &Routes.forum_topic_path/4, @parameters, display_if_single: false)
    |> (& refute active_page_presence?(&1)).()
  end

  test "display_if_single doen't play any role with more than one page", %{conn: conn} do
    [page1, page2] = pages_fixture(11, 10)

    for value <- [true, false] do
      output = render(conn, page1, &Routes.forum_topic_path/4, @parameters, display_if_single: value)
      assert active_page_presence?(output)
      assert contains_link?(output, "/forum/topics/643?page=2")

      output = render(%{conn | params: Map.put(conn.params, :page, 2)}, page2, &Routes.forum_topic_path/4, @parameters, display_if_single: value)
      assert active_page_presence?(output, 2)
      assert contains_link?(output, "/forum/topics/643?page=1")
    end
  end
end
