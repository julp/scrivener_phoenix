import Config

config :scrivener_phoenix, ScrivenerPhoenixTestWeb.Endpoint,
  http: [port: 4004],
  url: [host: "www.scrivener-phoenix.test", port: 2043, scheme: "https"],
  secret_key_base: "SF/Kdza2QBqCslYWOivWQnoAzsxuRSaJ0/3+awC87PfgCpBcQXDAQhyRUvgCKR8E",
  server: false
