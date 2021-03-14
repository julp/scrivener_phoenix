defmodule ScrivenerPhoenixTestWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :scrivener_phoenix

  @session_options [
    store: :cookie,
    key: "_scriver_phoenix_test_key",
    signing_salt: "K1grJTWham",
  ]

  # TODO: LiveView
  #socket "/live", Phoenix.LiveView.Socket,
    #websocket: [connect_info: [:peer_data, :x_headers]]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session, @session_options

  plug ScrivenerPhoenixTestWeb.Router
end
