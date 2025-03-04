defmodule Scrivener.PhoenixWeb.Component do
  @moduledoc ~S"""
  TODO
  """

  use Phoenix.Component
  use Gettext, backend: Scrivener.Phoenix.Gettext

  attr :conn, :any, default: nil
  attr :route, :any, default: nil
  attr :spage, Scrivener.Page, required: true
#   attr :options, :any, default: []
  attr :args, :list, default: []

  attr :left, :integer, default: 0
  attr :right, :integer, default: 0
  attr :window, :integer, default: 4
  attr :outer_window, :integer, default: 0
  attr :live, :atom, default: nil
  attr :inverted, :boolean, default: false
  attr :param_name, :atom, default: :page # TODO: renommer en page_param ?
  attr :merge_params, :boolean, default: false
  attr :display_if_single, :boolean, default: :false
  attr :template, :atom, default: nil

  slot :page
  slot :gap
#   slot :first
#   slot :previous
#   slot :next
#   slot :last

  # ATTENTION: conflit slot :labels et options.labels
#   slot :labels, doc: "XXX" do
    # TODO: conversion en map avec cette forme ?
#     attr :name, :string, values: ~W[first previous next last]
#     attr :value, :string
#     attr :first, :string#, default: dgettext_noop("XXX", "First")
#     attr :previous, :string#, default: dgettext_noop("XXX", "Previous")
#   end

  # ATTENTION: conflit slot :symbols et options.symbols
  # TODO: conversion en map avec cette forme ?
#   slot :symbols, doc: "XXX" do
  slot :test do
    attr :name, :string, values: ~W[first previous gap next last]
#     attr :value, :string
  end

  def paginate(assigns) do
    assigns
    |> do_paginate()
  end

  # skip pagination if there is zero entry (total)
  defp do_paginate(assigns = %{spage: %Scrivener.Page{total_entries: 0}}) do
    ~H""
  end

  # skip pagination if there only is a single page and display_if_single = false
  defp do_paginate(assigns = %{spage: %Scrivener.Page{total_pages: 1}, display_if_single: false}) do
    ~H""
  end

  defp do_paginate(assigns) do
    options =
      assigns
      # assigns = assign(assigns, Map.take(assigns, ~W[left right live inverted ...]a))
      |> Phoenix.Component.assigns_to_attributes(~W[conn route spage args page]a)
      |> Scrivener.Phoenix.Options.merge()
      |> Scrivener.Phoenix.Options.auto_set_live_option(assigns.conn)
#       |> IO.inspect()

    fun = Scrivener.Phoenix.URLBuilder.url(assigns.conn, assigns.route, assigns.args, options)
    {first, prev} = Scrivener.Phoenix.Paginator.first_previous_page(assigns.spage, fun, options)
    {next, last} = Scrivener.Phoenix.Paginator.next_last_page(assigns.spage, fun, options)
    window_pages = Scrivener.Phoenix.Paginator.window_pages(assigns.spage, fun, options)
    # TODO: drop @spage from assigns

#     IO.inspect(assigns.page, label: "@page")
#     IO.inspect(assigns.test, label: "@test")

    assigns
    |> assign(:options, options)
    |> assign(:first, first)
    |> assign(:prev, prev)
    |> assign(:next, next)
    |> assign(:last, last)
    |> assign(:pages, window_pages)
    # <TODO>
    |> assign(:first_label, options.labels.first)
    |> assign(:prev_label, options.labels.prev)
    |> assign(:next_label, options.labels.next)
    |> assign(:last_label, options.labels.last)
    # </TODO>
    # <TODO>
    |> assign(:xleft_symbol, options.symbols.xleft)
    |> assign(:left_symbol, options.symbols.left)
    |> assign(:right_symbol, options.symbols.right)
    |> assign(:xright_symbol, options.symbols.xright)
    # </TODO>
    |> handle_inverted()
  end

  # NOTE: slot :page as attr forwarded from do_paginate/1
  attr :page, :list, required: true
  attr :pages, :list, required: true
  # NOTE: :any for Scrivener.Phoenix.Page | nil
  attr :first, :any, required: true
  attr :next, :any, required: true
  attr :prev, :any, required: true
  attr :last, :any, required: true

  # TODO: :any (String.t | nil) ?
  attr :xleft_label, :string, required: true
  attr :left_label, :string, required: true
  attr :right_label, :string, required: true
  attr :xright_label, :string, required: true

  # TODO: :any (String.t | nil) ?
  attr :first_symbol, :string, required: true
  attr :prev_symbol, :string, required: true
  attr :next_symbol, :string, required: true
  attr :last_symbol, :string, required: true

  defp handle_inverted(assigns = %{inverted: true}) do
    ~H"""
    <.real_paginate
      left_page={@next}
      right_page={@prev}
      xleft_page={@last}
      xright_page={@first}
      pages={Enum.reverse(@pages)}
      page={@page}
      live={@options.live}
      xleft_label={@last_label}
      left_label={@next_label}
      right_label={@prev_label}
      xright_label={@first_label}
      xleft_symbol={@xleft_symbol}
      left_symbol={@left_symbol}
      right_symbol={@right_symbol}
      xright_symbol={@xright_symbol}
    />
    """
  end

  defp handle_inverted(assigns) do
    ~H"""
    <.real_paginate
      left_page={@prev}
      right_page={@next}
      xleft_page={@first}
      xright_page={@last}
      pages={@pages}
      page={@page}
      live={@options.live}
      xleft_label={@first_label}
      left_label={@prev_label}
      right_label={@next_label}
      xright_label={@last_label}
      xleft_symbol={@xleft_symbol}
      left_symbol={@left_symbol}
      right_symbol={@right_symbol}
      xright_symbol={@xright_symbol}
    />
    """
  end

  attr :live, :boolean, required: true

  attr :pages, :list, required: true
  # NOTE: :any for Scrivener.Phoenix.Page | nil
  attr :xleft_page, :any, required: true
  attr :left_page, :any, required: true
  attr :right_page, :any, required: true
  attr :xright_page, :any, required: true

  # TODO: :any (String.t | nil) ?
  attr :xleft_label, :string, required: true
  attr :left_label, :string, required: true
  attr :right_label, :string, required: true
  attr :xright_label, :string, required: true

  # TODO: :any (String.t | nil) ?
  attr :xleft_symbol, :string, required: true
  attr :left_symbol, :string, required: true
  attr :right_symbol, :string, required: true
  attr :xright_symbol, :string, required: true

  # NOTE: slot :page as attr forwarded from do_paginate/1 > handle_inverted/1
  attr :page, :list, required: true
  defp real_paginate(assigns) do
    # TODO: calculs des pages
    # TODO: en inverted, switcher first <=> last et previous <=> next
    # spage transformé en first/prev/liste de pages/next/last
    ~H"""
    <%= if @xleft_page do %>
      <%= if @page == [] do %>
        <.page
          live={@live}
          text={@xleft_label}
          left_symbol={@xleft_symbol}
          href={@xleft_page.href}
          rel={rel_attribute_value(@xleft_page)}
        />
      <% else %>
        <%# TODO: options (live notamment) %>
        <%= render_slot(@page, @xleft_page) %>
      <% end %>
    <% end %>

    <%!-- pareil pour left --%>

    <%= for page <- @pages do %>
      <%# TODO: gap %>
      <%= if @page == [] do %>
        <.page
          live={@live}
          text={page.no}
          href={page.rel == :current && "#" || page.href}
          rel={rel_attribute_value(page)}
        />
      <% else %>
        <%# TODO: faire suivre les options (live notamment) %>
        <%= render_slot(@page, page) %>
      <% end %>
    <% end %>

    <%!-- pareil pour right --%>

    <%!-- pareil pour xright --%>
    """
  end

#   defp rel_attribute_value(%Scrivener.Phoenix.Page{prev?: true}), do: "prev"
#   defp rel_attribute_value(%Scrivener.Phoenix.Page{next?: true}), do: "next"
  defp rel_attribute_value(%Scrivener.Phoenix.Page{rel: :prev}), do: "prev"
  defp rel_attribute_value(%Scrivener.Phoenix.Page{rel: :next}), do: "next"
  defp rel_attribute_value(_), do: nil

  attr :live, :boolean, required: true
  attr :text, :string, required: true
  attr :href, :string, required: true
  attr :left_symbol, :string, default: nil
  attr :right_symbol, :string, default: nil
  # NOTE: :any for String.t | nil
  attr :rel, :any, default: nil, values: ["prev", "next", nil]
  defp page(assigns) do
    ~H"""
    <.link {[{@live && :patch || :href, @href}]} rel={@rel}><%= if @left_symbol do %>{@left_symbol}&nbsp;<% end %>{@text}<%= if @right_symbol do %>&nbsp;{@right_symbol}<% end %></.link>
    """
  end
end
