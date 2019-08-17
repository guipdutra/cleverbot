defmodule Cleverbot.BotManager do
  def create_and_start(%{short_period: short_period, long_period: long_period, currency_code: currency_code}) do
    {:ok, pid} = Cleverbot.Bot.start_link(%{currency_code: currency_code, short_period: short_period, long_period: long_period})
  end

  def stop(currency_code) do
    GenServer.stop(String.to_atom("bot_#{currency_code}"))
  end
end

