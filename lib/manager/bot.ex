defmodule Cleverbot.Bot do
  use GenServer
  alias Cleverbot.Manager.Utils.StockParse
  alias Cleverbot.Repo.Repository
  alias Cleverbot.Manager.Strategies.SimpleMovingAverage
  alias Cleverbot.Manager.Homebroker

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: String.to_atom("bot_#{params.currency_code}"))
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def init(params) do
    Phoenix.PubSub.subscribe(:cleverbot_topic, "stocks_topic")
    {:ok, %{currency_code: params.currency_code, short_period: params.short_period, long_period: params.long_period}}
  end

  def handle_info({:stock, value}, state) do
    stock = StockParse.parse(Poison.decode!(value))

    if stock.currency_code == state.currency_code do
      Repository.save_stock(%{currency_code: state.currency_code, price: stock.price})
      {:ok, stocks} = Repository.get_stocks(state.currency_code)

      case SimpleMovingAverage.execute(%{short_period: state.short_period, long_period: state.long_period, stocks: stocks}) do
        :buy -> create_buy_order(state.currency_code, stock)
        :sell -> create_sell_order(state.currency_code, stock)
        _ -> :not_enough_periods
      end

      {:ok, orders} = Repository.get_orders(state.currency_code)
      IO.inspect orders
    end

    {:noreply, state}
  end

  defp create_buy_order(currency_code, stock) do
    {:ok, orders} = Repository.get_orders(currency_code)
    orders = orders |> Enum.map(&Poison.decode!/1)
    Homebroker.buy(%{currency_code: currency_code, quantity: 100, price: stock.price}, orders)
  end

  defp create_sell_order(currency_code, stock) do
    {:ok, orders} = Repository.get_orders(currency_code)
    orders = orders |> Enum.map(&Poison.decode!/1)
    Homebroker.sell(%{currency_code: currency_code, quantity: 100, price: stock.price}, orders)
  end
end
