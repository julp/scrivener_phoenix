defmodule Scrivener.Phoenix.PageTest do
  use ExUnit.Case
  alias Scrivener.Phoenix.Page

  setup_all do
    first = %Scrivener.Page{entries: [], page_number: 1, page_size: 10, total_entries: 28, total_pages: 3}
    last = %{first | page_number: 3}
    [
      first: first,
      last: last,
      single: %Scrivener.Page{entries: [], page_number: 1, page_size: 10, total_entries: 8, total_pages: 1},
    ]
  end

  def create_page(no)
    when is_integer(no)
  do
    Page.create(no, "")
  end

  def create_page(%Scrivener.Page{page_number: no}) do
    create_page(no)
  end

  test "last_page?", state do
    assert Page.last_page?(Page.create(1, ""), state[:single])
    refute Page.last_page?(Page.create(1, ""), state[:first])
    assert Page.last_page?(Page.create(3, ""), state[:last])
  end

  test "current?", state do
    assert Page.current?(Page.create(1, ""), state[:single])
    refute Page.current?(Page.create(3, ""), state[:single])

    assert Page.current?(Page.create(1, ""), state[:first])
    refute Page.current?(Page.create(2, ""), state[:first])

    refute Page.current?(Page.create(1, ""), state[:last])
    assert Page.current?(Page.create(3, ""), state[:last])
  end

  test "left_outer?", _state do
    refute Page.left_outer?(Page.create(1, ""), %{left: 0})

    assert Page.left_outer?(Page.create(1, ""), %{left: 5})
    assert Page.left_outer?(Page.create(5, ""), %{left: 5})
    refute Page.left_outer?(Page.create(6, ""), %{left: 5})
  end

  test "right_outer?", state do
    refute Page.right_outer?(Page.create(3, ""), state[:first], %{right: 0})

    refute Page.right_outer?(Page.create(1, ""), state[:first], %{right: 1})
    assert Page.right_outer?(Page.create(3, ""), state[:first], %{right: 1})
  end

  test "inside_window?", state do
    assert Page.inside_window?(Page.create(1, ""), state[:first], %{window: 1})
    assert Page.inside_window?(Page.create(2, ""), state[:first], %{window: 1})
    refute Page.inside_window?(Page.create(3, ""), state[:first], %{window: 1})

    refute Page.inside_window?(Page.create(1, ""), state[:last], %{window: 1})
    assert Page.inside_window?(Page.create(2, ""), state[:last], %{window: 1})
    assert Page.inside_window?(Page.create(3, ""), state[:last], %{window: 1})
  end
end
