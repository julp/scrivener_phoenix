defmodule Scrivener.Phoenix.Paginator do
  alias Scrivener.Phoenix.Page

  @typep maybe_page :: Scrivener.Phoenix.Page.t | nil

  @spec first_previous_page(Scrivener.Page.t, options :: Scrivener.Phoenix.Options.t) :: {maybe_page, maybe_page}
  def first_previous_page(%Scrivener.Page{page_number: page_number}, _options) do
    # first = nil if options.show_first = false
    if page_number > 1 do
      {Page.create(1), Page.create(page_number - 1)}
    else
      {nil, nil}
    end
  end

  @spec next_last_page(Scrivener.Page.t, options :: Scrivener.Phoenix.Options.t) :: {maybe_page, maybe_page}
  def next_last_page(%Scrivener.Page{page_number: page_number, total_pages: total_pages}, _options) do
    # last = nil if options.show_last = false
    if page_number < total_pages do
      {Page.create(page_number + 1), Page.create(total_pages)}
    else
      {nil, nil}
    end
  end

  @spec window_pages(Scrivener.Page.t, options :: Scrivener.Phoenix.Options.t) :: [Scrivener.Phoenix.Page.t]
  def window_pages(page = %Scrivener.Page{}, options) do
    left_window_plus_one = range_as_list(1, options.left + 1)
    right_window_plus_one = range_as_list(page.total_pages - options.right, page.total_pages)
    inside_window_plus_each_sides = range_as_list(page.page_number - options.window - 1, page.page_number + options.window + 1)

    left_window_plus_one
    |> Kernel.++(right_window_plus_one)
    |> Kernel.++(inside_window_plus_each_sides)
    |> Enum.sort()
    |> Enum.uniq()
    |> Enum.reject(&(&1 < 1 or &1 > page.total_pages))
    |> Enum.map(
      fn page_number ->
        Page.create(page_number)#, fun.(page_number))
      end
    )
    |> insert_gap(page, options)
    |> Enum.reverse()
  end

  defp was_truncated([%Scrivener.Phoenix.Gap{} | _tail]), do: true
  defp was_truncated(_), do: false

  defp do_insert_gap([], acc, _page, _options) do
    acc
  end

  defp do_insert_gap([hd | tl], acc, page = %Scrivener.Page{page_number: page_number, total_pages: total_pages}, options) do
    %Scrivener.Phoenix.Options{left: left, right: right, window: window} = options

    left_outer? =
      fn page ->
        page.no <= left
      end

    right_outer? =
      fn page ->
        total_pages - page.no < right
      end

    inside_window? =
      fn page ->
        page_number
        |> Kernel.-(page.no)
        |> abs()
        |> Kernel.<=(window)
      end

    acc =
      cond do
        left_outer?.(hd) || right_outer?.(hd) || inside_window?.(hd) ->
          [hd | acc]
        !was_truncated(acc) ->
          [%Scrivener.Phoenix.Gap{} | acc]
        true ->
          acc
      end

    do_insert_gap(tl, acc, page, options)
  end

  defp insert_gap(pages, page = %Scrivener.Page{}, options) do
    do_insert_gap(pages, [], page, options)
  end

  @spec range_as_list(l :: integer, h :: integer) :: [integer]
  defp range_as_list(l, h) do
    l
    |> Range.new(h)
    |> Enum.to_list()
  end
end
