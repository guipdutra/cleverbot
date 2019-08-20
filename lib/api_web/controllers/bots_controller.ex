defmodule CleverbotWeb.BotsController do
  use CleverbotWeb, :controller
  alias Cleverbot.BotManager

  def create_and_start(conn, params) do
    params = params |> atomize_keys

    {:ok, pid} = BotManager.create_and_start(%{
      short_period: String.to_integer(params.short_period),
      long_period: String.to_integer(params.long_period),
      money: String.to_float(params.money),
      name: params.name,
      currency_code: String.to_integer(params.currency_code)
    })

    render(conn, "created.json")
  end

  def bots(conn, params) do
    params = params |> atomize_keys

    {:ok, bots} = BotManager.bots(params.currency_codes)

    render(conn, "bots.json", bots: bots)
  end
end
