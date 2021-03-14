defmodule ScrivenerPhoenixWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ScrivenerPhoenix.TestHelpers
      alias ScrivenerPhoenixTestWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint ScrivenerPhoenixTestWeb.Endpoint
    end
  end

  setup _tags do
    #:ok = Ecto.Adapters.SQL.Sandbox.checkout(ScrivenerPhoenixTest.Repo)

    #unless tags[:async] do
      #Ecto.Adapters.SQL.Sandbox.mode(ScrivenerPhoenixTest.Repo, {:shared, self()})
    #end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Map.replace!(:secret_key_base, ScrivenerPhoenixTestWeb.Endpoint.config(:secret_key_base))
      |> Plug.Conn.put_private(:phoenix_endpoint, ScrivenerPhoenixTestWeb.Endpoint)

    {:ok, conn: conn}
  end
end
