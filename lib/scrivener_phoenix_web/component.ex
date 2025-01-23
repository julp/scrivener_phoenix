defmodule Scrivener.PhoenixWeb.Component do
  @moduledoc ~S"""
  TODO
  """

  use Phoenix.Component
  use Gettext, backend: Scrivener.Phoenix.Gettext

  attr :conn, :any, default: nil
  attr :route, :any, required: true
  attr :spage, Scrivener.Page, required: true
#   attr :options, :any, default: []
  attr :args, :list, default: []

  attr :left, :integer, default: 0
  attr :right, :integer, default: 0
  attr :window, :integer, default: 4
  attr :outer_window, :integer, default: 0
  attr :live, :atom, default: nil
  attr :inverted, :boolean, default: false
  attr :param_name, :atom, default: :page # TODO: renommer page_param ?
  attr :merge_params, :boolean, default: false
  attr :display_if_single, :boolean, default: :false
  attr :template, :atom, default: nil

  slot :page
  slot :gap
  slot :first
  slot :previous
  slot :next
  slot :last

  slot :labels, doc: "XXX" do
    attr :first, :string#, default: dgettext_noop("XXX", "First")
    attr :previous, :string#, default: dgettext_noop("XXX", "Previous")
  end

  def paginate(assigns) do
    options =
      assigns
      |> Phoenix.Component.assigns_to_attributes(~W[conn route spage args]a)
      # TODO: convertion Keyword => Map
      |> IO.inspect(label: "OPTIONS ?")

    # assigns = assign(assigns, Map.take(assigns, ~W[left right live inverted ...]a))
    do_paginate(assigns)
  end

  # skip pagination if:
  # - there is zero entry (total)
  # - there only is a single page and display_if_single = false
  defp do_paginate(assigns = %{spage: %Scrivener.Page{total_entries: 0}}) do
    ~H""
  end

  defp do_paginate(assigns = %{spage: %Scrivener.Page{total_pages: 1}, display_if_single: false}) do
    ~H""
  end

  defp do_paginate(assigns) do
    # TODO: calculs des pages
    # TODO: en inverted, switcher first <=> last et previous <=> next
    # spage transformé en first/prev/liste de pages/next/last
    ~H"""
    <%= if @first == [] do %>
      <.page href={@left.href} rel={rel_attribute_value(@left)} text={"TODO"} live={@live}/>
    <% else %>
      <%# TODO: options (live notamment) %>
      <%= render_slot(@first, @left) %>
    <% end %>

    <!-- pareil pour prev -->

    <%= for page <- @pages do %>
      <%# TODO: gap %>
      <%= if @page == [] do %>
        <.page href={@page.href} rel={rel_attribute_value(@page)} text={@page.no} live={@live}/>
      <% else %>
        <%# TODO: options (live notamment) %>
        <%= render_slot(@page, page) %>
      <% end %>
    <% end %>

    <!-- pareil pour next -->

    <!-- pareil pour last -->
    """
  end

  defp x(assigns) do
    ~H""
  end

  defp handle_inverted(assigns = %{inverted: true}) do
    # TODO: labels + symboles
    ~H"""
    <.x
      left={@next}
      right={@prev}
      xleft={@last}
      xright={@first}
      pages={Enum.reverse(@pages)}
    />
    """
  end

  defp handle_inverted(assigns) do
    # TODO: labels + symboles
    ~H"""
    <.x
      left={@prev}
      right={@next}
      xleft={@first}
      xright={@last}
      pages={@pages}
    />
    """
  end

#   defp rel_attribute_value(%Page{prev?: true}), do: "prev"
#   defp rel_attribute_value(%Page{next?: true}), do: "next"
  defp rel_attribute_value(_), do: nil

  defp page(assigns) do
    ~H"""
    <.link {@live && [patch: @href] || [href: @href]} rel={@rel}>{@text}</.link>
    """
  end
end
