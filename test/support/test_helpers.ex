defmodule ScrivenerPhoenix.TestHelpers do
  #alias Scrivener.Phoenix.Page

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
end
