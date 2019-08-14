defmodule Cleverbot.Bot do
  use GenServer
  alias Cleverbot.Manager.Utils.StockParse
  import SMA

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def init(params) do
    Phoenix.PubSub.subscribe(:cleverbot_topic, "stocks_topic")
    {:ok, %{redis_conn: params.redis_conn, currency_code: params.currency_code}}
  end

  def handle_info({:stock, value}, state) do
    stock = StockParse.parse(Poison.decode!(value))

    if stock.currency_code == state.currency_code do
      case Redix.command(state.redis_conn, ["LRANGE", "stock_#{state.currency_code}", 0, -1]) do
        {:ok, []} ->
          Redix.command(state.redis_conn, ["LPUSH", "stock_#{state.currency_code}", stock.price])
        {:ok, stocks} ->
          if (stock.price != List.first(stocks)) do
            Redix.command(state.redis_conn, ["LPUSH", "stock_#{state.currency_code}", stock.price])
          end

          {:ok, stocks_updated} = Redix.command(state.redis_conn, ["LRANGE", "stock_#{state.currency_code}", 0, -1])
          stocks = stocks_updated |> Enum.map(&String.to_float/1)
          short = sma(stocks, 9)
          long = sma(stocks, 40)

          IO.inspect stocks
          if !Enum.empty?(short) && !Enum.empty?(long) do
            IO.puts "media curta 9 periodos"
            short = List.first(short)
            IO.inspect short

            IO.puts "media longa 20 periodos"
            long = List.first(long)
            IO.inspect long

            if short > long do
              {:ok, transactions} = Redix.command(state.redis_conn, ["LRANGE", "transactions_#{state.currency_code}", 0, -1])

              with false <- Enum.empty?(transactions),
                   transaction <- List.first(transactions),
                   "sell" <- Poison.decode!(transaction)["type"]
              do
                Redix.command(state.redis_conn, ["LPUSH", "transactions_#{state.currency_code}", Poison.encode!(%{price: stock.price, type: "buy", quantity: 100})])
                IO.puts "ordem de COMPRA, preço: #{stock.price}"
              else
                true ->
                  Redix.command(state.redis_conn, ["LPUSH", "transactions_#{state.currency_code}", Poison.encode!(%{price: stock.price, type: "buy", quantity: 100})])
                "buy" ->
                  IO.puts "Já existe está ação: #{stock.currency_code}"
              end

            else
              {:ok, transactions} = Redix.command(state.redis_conn, ["LRANGE", "transactions_#{state.currency_code}", 0, -1])

              with false <- Enum.empty?(transactions),
                   transaction <- List.first(transactions),
                   "buy" <- Poison.decode!(transaction)["type"]
              do
                Redix.command(state.redis_conn, ["LPUSH", "transactions_#{state.currency_code}", Poison.encode!(%{price: stock.price, type: :sell, quantity: 100})])
                IO.puts "ordem de VENDA, preço: #{stock.price}"
              end
            end
          end

          {:ok, transactions} = Redix.command(state.redis_conn, ["LRANGE", "transactions_#{state.currency_code}", 0, -1])
          IO.inspect transactions

        {:error , reason} ->
          IO.puts reason
      end
    end

    {:noreply, state}
  end
end
