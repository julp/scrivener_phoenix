defmodule Scrivener.Phoenix.Page do
  @moduledoc ~S"""
  A page (link) to render in HTML for the pagination.
  """

  @derive {Phoenix.Param, key: :no}
  defstruct ~W[no href label rel]a

  @type t :: %__MODULE__{
    no: non_neg_integer,
    href: String.t,
    label: String.t,
    rel: nil | :current | :prev | :next,
  }

  @spec create(no :: pos_integer, fun :: Scrivener.Phoenix.URLBuilder.generator) :: t
  def create(no, fun) do
    %__MODULE__{
      no: no,
      href: fun.(no),
#       next?: no == page_number + 1,
#       prev?: no == page_number - 1,
#       current?: no == page_number,
#       last?: no == total_pages,
    }
  end

  @spec create(spage :: Scrivener.Page.t) :: (no :: non_neg_integer, fun :: Scrivener.Phoenix.URLBuilder.generator, label :: String.t -> t)
  def create(_spage = %Scrivener.Page{page_number: page_number}) do
    fn no, fun, label ->
      %__MODULE__{
        no: no,
        label: label,
        href: fun.(no),
        rel:
          cond do
            no == page_number ->
              :current
            no == page_number + 1 ->
              :next
            no == page_number - 1 ->
              :prev
            true ->
              nil
          end,
      }
    end
  end

#   def handle_rel(page = %__MODULE__{}, spage = %Scrivener.Page{}, attributes \\ []) do
#     cond do
#       page.no == spage.page_number + 1 ->
#         Keyword.put(attributes, :rel, "next")
#       page.no == spage.page_number - 1 ->
#         Keyword.put(attributes, :rel, "prev")
#       true ->
#         attributes
#     end
#   end

#   @doc ~S"""
#   Is the given page the last one?
#   """
#   def last_page?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
#     page.no == spage.total_pages
#   end

#   @doc ~S"""
#   Is the given page the current page?
#   """
#   def current?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
#     page.no == spage.page_number
#   end

#   def out_of_range?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
#     page.no > spage.total_pages
#   end

#   def next?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
#     page.no == spage.page_number + 1
#   end

#   def prev?(page = %__MODULE__{}, spage = %Scrivener.Page{}) do
#     page.no == spage.page_number - 1
#   end

#   @doc ~S"""
#   Is the given page within the left outer window?
#   """
#   def left_outer?(page = %__MODULE__{}, options = %{}) do
#     page.no <= options.left
#   end

#   @doc ~S"""
#   Is the given page within the right outer window?
#   """
#   def right_outer?(page = %__MODULE__{}, spage = %Scrivener.Page{}, options = %{}) do
#     spage.total_pages - page.no < options.right
#   end

#   @doc ~S"""
#   Is the given page inside the inner window?
#   """
#   def inside_window?(page = %__MODULE__{}, spage = %Scrivener.Page{}, options = %{}) do
#     spage.page_number
#     |> Kernel.-(page.no)
#     |> abs()
#     |> Kernel.<=(options.window)
#   end
end
