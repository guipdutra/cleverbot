defmodule Cleverbot.StocksService do
  use WebSockex
  @url "wss://api2.poloniex.com"

  def start_link(state) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, state)
    WebSockex.send_frame(pid,
      {:text, Poison.encode!(%{"command": "subscribe", "channel": 1002})})
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end
end
