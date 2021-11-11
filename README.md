# scrivener_phoenix

Helper to render a [Scrivener](https://hex.pm/packages/scrivener) pagination for phoenix.

## Features

### Inverted pagination

In a standard pagination, the first page contains the latest content:

`« First ‹ Prev ... 2 3 4 5 6 7 8 9 10 ... Next › Last »`

This package provides an option for an inverted pagination where the first page contains the oldest content:

`« Last ‹ Next ... 10 9 8 7 6 5 4 3 2 ... Prev › First »`

## Installation

The package can be installed by adding `scrivener_phoenix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # ...
    {:scrivener_ecto, "~> 2.7"},
    {:scrivener_phoenix, "~> 0.2.1"},
  ]
end
```

The docs can be found at [https://hexdocs.pm/scrivener_phoenix](https://hexdocs.pm/scrivener_phoenix).

## Configuration

Configure scrivener_phoenix in your_app/config/config.exs:

```
config :scrivener_phoenix,
  left: 0,
  right: 0,
  window: 4,
  outer_window: 0,
  inverted: false,
  param_name: :page,
  merge_params: false,
  display_if_single: false,
  template: Scrivener.Phoenix.Template.Bootstrap4
```

(these are the defaults and can be omitted)

* left (default: `0`): display the *left* first pages
* right (default: `0`): display the *right* last pages
* window (default: `4`): display *window* pages before and after the current page (eg, if 7 is the current page and window is 2, you'd get: `5 6 7 8 9`)
* outer_window (default: `0`), equivalent to left = right = outer_window: display the *outer_window* first and last pages (eg valued to 2: `« First ‹ Prev 1 2 ... 5 6 7 8 9 ... 19 20 Next › Last »` as opposed to left = 1 and right = 3: `« First ‹ Prev 1 ... 5 6 7 8 9 ... 18 19 20 Next › Last »`)
* inverted (default: `false`): see **Inverted pagination** above
* display_if_single (default: `false`): `true` to force a pagination to be displayed when there only is a single page of result(s)
* param_name (default: `:page`): the name of the parameter generated in URL (query string) to propagate the page number
* merge_params (default: `false`): `true` to copy the entire query string between requests, `false` to ignore it or a list of the parameter names to only reproduce
* template (default: `Scrivener.Phoenix.Template.Bootstrap4`): the module which implements `Scrivener.Phoenix.Template` to use to render links to pages
* symbols (default: `%{first: "«", prev: "‹", next: "›", last: "»"}`): the symbols to add before or after the label for the first, previous, next and last page (`nil` or `""` for none)
* labels (default: `%{first: dgettext("scrivener_phoenix", "First"), prev: dgettext("scrivener_phoenix", "Prev"), next: dgettext("scrivener_phoenix", "Next"), last: dgettext("scrivener_phoenix", "Last")}`): the texts used by links to describe the first, previous, next and last page

## Usage

In your Repo (the file is probably lib/your_app/repo.ex), add `use Scrivener`

In concerned views, add:

```elixir
import Scrivener.PhoenixView
```

Or, to be global, add it to lib/your_app_web.ex:

```elixir
defmodule YourAppWeb do
  # ...
  def view do
    quote do
      # ...
      import Scrivener.PhoenixView # <= add this line
    end
  end
  # ...
end
```

(a third solution is to directly use `Scrivener.PhoenixView.paginate` instead of just `paginate` in your templates)

In your context, the resultset of your query is paginated with scrivener:

```diff
defmodule MyApp.Blog do
  def posts_at_page(page) do
    MyApp.Post
    |> order_by(:created_at)
-   |> Repo.all()
+   |> Repo.paginate(page: page) # <= this line is your scrivener pagination
  end
end
```

Then, in your controller, assign it to the view:

```elixir
defmodule MyAppWeb.BlogController do
  # ...

  def index(conn, params) do
    posts =
      params
      |> Map.get(:page, 1) # <= extract the page number from params if present else default to first page
      |> Blog.posts_at_page()

    conn
    |> assign(:posts, posts)
    # ...
    |> render(:index)
  end

  # ...
end
```

Then, in your template, you just have to call the `paginate` helper:

```eex
<%= paginate @conn, @posts, route_function, route_params %>
```

Where:
* route_function is the helper (YourAppWeb.Router.Helpers.\*_url or YourAppWeb.Router.Helpers.\*_path) - don't forget to add the `&` and the `/arity`. Example: `&MyBlogWeb.Router.Helpers.blog_path/3`
* route_params is a **list** of parameters passed to *route_function* excepted the conn (`%Plug.Conn{}`). This list should at least contains the action. Example: `[:index]`

**NOTES:**

By "default", scrivener_phoenix will simply propagate the page number in the query string (eg: /blog?page=1).

For this route:

```elixir
defmodule MyBlogWeb.Router do
  scope "/" do
    # ...
    get "/", MyBlogWeb.PostController, :index
    # ...
  end
end
```

You have to paginate this way:

```eex
<%= paginate @conn, @posts, &MyBlogWeb.Router.Helpers.blog_path/3, [:index] %>
```

The `/3` arity stands for:

1. the *conn*
2. the action (:index)
3. the additionnal (and facultative) parameters to add in query string (where the *page* parameter will be injected)

Because Phoenix defines the corresponding *path helper* this way:

```elixir
def blog_path(conn_or_endpoint, action = :index, query_params \\ [])
```

But the *page* parameter can also be included in the path of the URL instead of the query string (eg /blog/page/1), like this:

```elixir
defmodule MyBlogWeb.Router do
  scope "/" do
    # ...
    get "/page/:page", MyBlogWeb.PostController, :index, as: :page
    # ...
  end
end
```

And you paginate as follows:

```eex
<%= paginate @conn, @posts, &MyBlogWeb.Router.Helpers.blog_page_path/4, [:index] %>
```

The arity becomes `/4` with the additionnal :page parameter:

1. the *conn*
2. the action (:index)
3. the page
4. the additionnal (and facultative) parameters to add in query string

In this case, the corresponding *path helper* is defined as:

```elixir
def blog_page_path(conn_or_endpoint, action = :index, page, query_params \\ [])
```

TL;DR: for arity, add 3 to the length of the list you pass as parameters if page number is a parameter to your route else 2 (and the page number will be part of the query string)
