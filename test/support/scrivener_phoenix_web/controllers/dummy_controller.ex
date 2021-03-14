defmodule ScrivenerPhoenixTestWeb.DummyController do
  use ScrivenerPhoenixTestWeb, :controller

  def index(conn, _params) do
    conn
    |> render(:index)
  end
end
