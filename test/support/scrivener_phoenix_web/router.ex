defmodule ScrivenerPhoenixTestWeb.Router do
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller

  pipeline :browser do
    plug :accepts, ~W[html]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  scope "/forum", as: :forum do
    pipe_through [:browser]

    resources "/topics", ScrivenerPhoenixTestWeb.DummyController, only: ~W[show]a, name: :topic do
      get "/page/:page", ScrivenerPhoenixTestWeb.DummyController, :show, as: :page
    end
  end

  scope "/blog", as: :blog do
    get "/posts/seite/:nummer", ScrivenerPhoenixTestWeb.DummyController, :index, as: :seite
    resources "/posts", ScrivenerPhoenixTestWeb.DummyController, only: ~W[index]a, name: :post
  end
end
