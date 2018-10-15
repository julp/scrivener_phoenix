defmodule Scrivener.Phoenix.Page do
  @moduledoc ~S"""
  A page (link) to render in HTML for the pagination.
  """

  defstruct ~W[no href]a

  @type t :: %__MODULE__{no: non_neg_integer(), href: String.t}

  def create(no, href) do
    %__MODULE__{no: no, href: href}
  end

  def handle_rel(page = %__MODULE__{}, spage = %Scrivener.Page{}, attributes) do
    cond do
      page.no == spage.page_number + 1 ->
        Keyword.put(attributes, :rel, "next")
      page.no == spage.page_number - 1 ->
        Keyword.put(attributes, :rel, "prev")
      true ->
        attributes
    end
  end

  @doc ~S"""
  Is the given page the last one?
  """
  def last_page?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
    page.no == spage.total_pages
  end

  @doc ~S"""
  Is the given page the current page?
  """
  def current?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
    page.no == spage.page_number
  end

if false do
  def out_of_range?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
    page.no > spage.total_pages
  end

  def next?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
    page.no == spage.page_number + 1
  end

  def prev?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
    page.no == spage.page_number - 1
  end
end

  @doc ~S"""
  Is the given page within the left outer window?
  """
  def left_outer?(page = %__MODULE__{}, options = %{}) do
    page.no <= options.left
  end

  @doc ~S"""
  Is the given page within the right outer window?
  """
  def right_outer?(page = %__MODULE__{}, spage = %Scrivener.Page{}, options = %{}) do
    spage.total_pages - page.no < options.right
  end

  @doc ~S"""
  Is the given page inside the inner window?
  """
  def inside_window?(page = %__MODULE__{}, spage = %Scrivener.Page{}, options = %{}) do
    spage.page_number
    |> Kernel.-(page.no)
    |> abs()
    |> Kernel.<=(options.window)
  end
end
