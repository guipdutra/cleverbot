defmodule Cleverbot.Bot do
  use GenServer
  alias Cleverbot.Manager.Utils.StockParse

  def start_link(redis_conn) do
    GenServer.start_link(__MODULE__, redis_conn, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def init(redis_conn) do
    Phoenix.PubSub.subscribe(:cleverbot_topic, "stocks_topic")
    {:ok, %{redis_conn: redis_conn}}
  end

  def handle_info({:stock, value}, state) do
    stock = StockParse.parse(Poison.decode!(value))
    Redix.command(state.redis_conn, ["RPUSH", "stock_#{stock.currency_code}", stock.price])

    case Redix.command(state.redis_conn, ["LRANGE", "stock_#{stock.currency_code}", 1, -1]) do
      {:ok , stocks} ->
        IO.puts stocks
      {:error , reason} ->
        IO.puts reason
    end

    {:noreply, state}
  end
end
