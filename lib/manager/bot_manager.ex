defmodule Cleverbot.BotManager do
  alias Cleverbot.Repo.Repository

  def create_and_start(%{short_period: short_period, long_period: long_period, currency_code: currency_code, name: name, money: money}) do
    {:ok, pid} = Cleverbot.Bot.start_link(
      %{currency_code: currency_code,
        short_period: short_period,
        long_period: long_period})

    Repository.save_bot(currency_code, %{money: money, name: name, currency_code: currency_code})
  end

  def bots(currency_codes) do
    {:ok, Enum.map(currency_codes, fn currency_code ->
      {:ok, bot} = Repository.get_bot(currency_code)
      {:ok, orders} = Repository.get_orders(currency_code)
      case {orders, bot} do
        {[], nil} ->
          %{currency_code =>%{ orders: [], bot: nil} }
        _ ->
          orders = orders |> Enum.map(fn order ->
            order = Poison.decode!(order)
          end)

          %{ orders: orders, bot: Poison.decode!(bot)}
      end
    end)}
  end

  def stop(currency_code) do
    GenServer.stop(String.to_atom("bot_#{currency_code}"))
  end
end

