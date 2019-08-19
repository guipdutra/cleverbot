defmodule CleverbotWeb.BotsController do
  use CleverbotWeb, :controller
  alias Cleverbot.BotManager

  def create_and_start(conn, params) do
    params = params |> atomize_keys

    {:ok, pid} = BotManager.create_and_start(%{
      short_period: params.short_period,
      long_period: params.long_period,
      currency_code: params.currency_code
    })

    render(conn, "created.json")
  end

  def orders(conn, params) do
    params = params |> atomize_keys

    {:ok, orders} = BotManager.orders(params.currency_codes)

    render(conn, "orders.json", orders: orders)
  end
end
