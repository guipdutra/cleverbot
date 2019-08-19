defmodule Cleverbot.Repo.Repository do
  def save_stock(stock) do
    case get_stocks(stock.currency_code) do
      {:ok, []} ->
        push(stocks_namespace(stock.currency_code), stock.price)

      {:ok, stocks} ->
        if (stock.price != List.first(stocks)) do
          push(stocks_namespace(stock.currency_code), stock.price)
        end
    end
  end

  def save_bot(currency_code, bot_params) do
    currency_code |>
    bot_namespace |>
    push(Poison.encode!(bot_params))
  end

  def get_bot(currency_code) do
    {:ok, bot} = currency_code |> bot_namespace |> pull
    {:ok, List.first(bot)}
  end

  def get_stocks(currency_code) do
    currency_code |>
    stocks_namespace |>
    pull
  end

  def get_orders(currency_code) do
    currency_code |>
    orders_namespace |>
    pull
  end

  def get_orders_total(currency_code) do
    {:ok, orders} = get_orders(currency_code)

    {:ok, Enum.map_reduce(orders, 0, fn order, acc ->
      order = Poison.decode!(order)
      case order["type"] do
        "buy" ->
          {order, acc - (order["quantity"] * String.to_float(order["price"])) }
        "sell" ->
          {order, acc + (order["quantity"] * String.to_float(order["price"]))}
      end
    end) }
  end

  def save_order(currency_code, order) do
    currency_code |>
    orders_namespace |>
    push(Poison.encode!(order))
  end

  defp push(namespace, params) do
    Redix.command(:redix, ["LPUSH", namespace, params])
  end

  defp pull(namespace) do
    Redix.command(:redix, ["LRANGE", namespace, 0, -1])
  end

  defp stocks_namespace(currency_code) do
    "stocks_#{currency_code}"
  end

  defp orders_namespace(currency_code) do
    "orders_#{currency_code}"
  end

  defp bot_namespace(currency_code) do
    "bot_#{currency_code}"
  end
end
