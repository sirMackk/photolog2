# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :photolog2, Photolog2.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "yDzWityWUzfNAYn9LsmmAEOmKFk9lAerknNdIt9F8ul5d9XXTF8uXJv13/HSVBmC",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Photolog2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :photolog2, ecto_repos: [Photolog2.Repo]

config :photolog2, media_path: "media/"

