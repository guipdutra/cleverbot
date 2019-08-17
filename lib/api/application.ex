defmodule Cleverbot.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      {Cleverbot.StocksService, []},
      supervisor(CleverbotWeb.Endpoint, []),
      {Redix, name: :redix},
      %{
        id: Phoenix.PubSub.PG2,
        start: {Phoenix.PubSub.PG2, :start_link, [:cleverbot_topic, []]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cleverbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CleverbotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
