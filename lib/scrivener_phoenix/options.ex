defmodule Scrivener.Phoenix.Options do
  @default_left 0
  @default_right 0
  @default_window 4
  @default_params nil
  @default_outer_window 0
  @default_live nil
  @default_inverted false
  @default_param_name :page
  @default_merge_params false
  @default_display_if_single false
  @default_template Scrivener.Phoenix.Template.Bootstrap4

  @moduledoc """
  Options:

    * params (default: `nil`): an explicit list (or map) of parameters to add to the query string, this is mostly intended for LiveView with `push_patch` since *params* have to be handled by yourself
    * left (default: `#{inspect(@default_left)}`): display the *left* first pages
    * right (default: `#{inspect(@default_right)}`): display the *right* last pages
    * window (default: `#{inspect(@default_window)}`): display *window* pages before and after the current page (eg, if 7 is the current page and window is 2, you'd get: `5 6 7 8 9`)
    * outer_window (default: `#{inspect(@default_outer_window)}`), equivalent to left = right = outer_window: display the *outer_window* first and last pages (eg valued to 2:
      `« First ‹ Prev 1 2 ... 5 6 7 8 9 ... 19 20 Next › Last »` as opposed to left = 1 and right = 3: `« First ‹ Prev 1 ... 5 6 7 8 9 ... 18 19 20 Next › Last »`)
    * live (default: `#{inspect(@default_live)}`):
      + `true` to generate links with `Phoenix.LiveView.Helpers.live_patch/2` instead of `Phoenix.HTML.Link.link/2`
      + `nil` to set it automatically to `true` when `paginate/5` is called with a `%Phoenix.LiveView.Socket{}` as its first parameter else `false`
    * inverted (default: `#{inspect(@default_inverted)}`): `true` to first (left side) link last pages instead of first
    * display_if_single (default: `#{inspect(@default_display_if_single)}`): `true` to force a pagination to be displayed when there only is a single page of result(s)
    * param_name (default: `#{inspect(@default_param_name)}`): the name of the parameter generated in URL (query string) to propagate the page number
    * merge_params (default: `#{inspect(@default_merge_params)}`): `true` to copy the entire query string between requests, `false` to ignore it or a list of the parameter names to only reproduce
    * template (default: `#{inspect(@default_template)}`): the module which implements `Scrivener.Phoenix.Template` to use to render links to pages
    * symbols (default: `%{first: "«", prev: "‹", next: "›", last: "»"}`): the symbols to add before or after the label for the first, previous, next and last page (`nil` or `""` for none)
    * labels (default: `%{first: dgettext("scrivener_phoenix", "First"), prev: dgettext("scrivener_phoenix", "Prev"), next: dgettext("scrivener_phoenix", "Next"), last: dgettext("scrivener_phoenix", "Last")}`):
      the texts used by links to describe the first, previous, next and last page
  """

  use Gettext, backend: Scrivener.Phoenix.Gettext

  defstruct [
    params: @default_params,
    left: @default_left,
    right: @default_right,
    window: @default_window,
    outer_window: @default_outer_window,
    live: @default_live,
    inverted: @default_inverted,
    display_if_single: @default_display_if_single,
    param_name: @default_param_name,
    merge_params: @default_merge_params,
    template: @default_template,
    labels: %{
      first: dgettext("scrivener_phoenix", "First"),
      prev: dgettext("scrivener_phoenix", "Prev"),
      next: dgettext("scrivener_phoenix", "Next"),
      last: dgettext("scrivener_phoenix", "Last"),
    },
    symbols: %{
      first: "«",
      prev: "‹",
      next: "›",
      last: "»",
      #gap: "…",
    },
  ]

  @type t :: %__MODULE__{
    params: Enumerable.t | nil,
    left: non_neg_integer,
    right: non_neg_integer,
    window: non_neg_integer,
    outer_window: non_neg_integer,
    live: boolean | nil,
    inverted: boolean,
    display_if_single: boolean,
    param_name: atom | String.t,
    merge_params: boolean | [atom | String.t],
    template: module,
    labels: %{
      first: String.t,
      prev: String.t,
      next: String.t,
      last: String.t,
    },
    symbols: %{
      first: String.t,
      prev: String.t,
      next: String.t,
      last: String.t,
#       gap: String.t,
    },
  }

  def merge(options) do
    options
    |> Enum.reduce(
      %__MODULE__{},
      fn {k, v}, acc ->
        Map.put(acc, k, v)
      end
    )
  end
end
