use Mix.Config

config :uuid_utils, TestApp1UUID3, namespace: :dns

config :uuid_utils, TestApp2UUID3,
  type: :uuid3,
  namespace: :url,
  name: "elixir.com"
