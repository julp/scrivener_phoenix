defmodule ScrivenerPhoenixTestWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: ScrivenerPhoenixTestWeb
      import Plug.Conn
      alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "test/support/scrivener_phoenix_web/templates",
        namespace: ScrivenerPhoenixTestWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1, action_name: 1, controller_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes
      #import ScrivenerPhoenixTestWeb.ErrorHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
