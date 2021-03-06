# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :api,
  namespace: Cleverbot

# Configures the endpoint
config :api, CleverbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KG1ho5VfY+ClaaBnmPehM8dPUjXCJxORxhhZL63oQB0beq/L+8xlg9kOGYqSMqOg",
  render_errors: [view: CleverbotWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Cleverbot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
