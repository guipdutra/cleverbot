defmodule Cleverbot.Bot do
  use GenServer
  alias Cleverbot.Manager.Utils.StockParse
  alias Cleverbot.Repo.Repository
  import SMA

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def init(params) do
    Phoenix.PubSub.subscribe(:cleverbot_topic, "stocks_topic")
    {:ok, %{currency_code: params.currency_code}}
  end

  def handle_info({:stock, value}, state) do
    stock = StockParse.parse(Poison.decode!(value))
    if stock.currency_code == state.currency_code do
      Repository.save_stock(%{currency_code: state.currency_code, price: stock.price})

      {:ok, stocks_updated} = Repository.get_stocks(state.currency_code)
      stocks = stocks_updated |> Enum.map(&String.to_float/1)

      short = sma(stocks, 9)
      long = sma(stocks, 40)

      IO.inspect stocks
      if !Enum.empty?(short) && !Enum.empty?(long) do
        IO.puts "media curta 9 periodos"
        short = List.first(short)
        IO.inspect short

        IO.puts "media longa 40 periodos"
        long = List.first(long)
        IO.inspect long

        if short > long do
          {:ok, transactions} = Repository.get_orders(state.currency_code)

          with false <- Enum.empty?(transactions),
               transaction <- List.first(transactions),
               "sell" <- Poison.decode!(transaction)["type"]
          do
            Repository.save_order(state.currency_code, %{price: stock.price, type: "buy", quantity: 100})
            IO.puts "ordem de COMPRA, preço: #{stock.price}"
          else
            true ->
              Repository.save_order(state.currency_code, %{price: stock.price, type: "buy", quantity: 100})
            "buy" ->
              IO.puts "Já existe uma ordem para esta ação: #{stock.currency_code}"
          end
        else
            {:ok, transactions} = Repository.get_orders(state.currency_code)

            with false <- Enum.empty?(transactions),
                 transaction <- List.first(transactions),
                 "buy" <- Poison.decode!(transaction)["type"]
            do
              Repository.save_order(state.currency_code, %{price: stock.price, type: "sell", quantity: 100})
              IO.puts "ordem de VENDA, preço: #{stock.price}"
            end
        end
      end

      {:ok, orders} = Repository.get_orders(state.currency_code)
      IO.inspect orders
    end

    {:noreply, state}
  end
end
