defmodule Cleverbot.StocksService do
  use WebSockex
  @url "wss://api2.poloniex.com"

  def start_link(state) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, state)
    WebSockex.send_frame(pid, {:text, Poison.encode!(%{"command": "subscribe", "channel": 1002})})
    {:ok, pid}
  end

  def handle_frame({type, msg}, state) do
    #IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"

    case msg do
      "[1002,1]" ->
        IO.puts "Subscription acknowledgement"
      _ ->
        Phoenix.PubSub.broadcast(:cleverbot_topic, "stocks_topic", {:stock, msg})
    end

    {:ok, state}
  end

  def handle_disconnect(_conn, state) do
    IO.puts "disconnected"
    {:ok, state}
  end
end
