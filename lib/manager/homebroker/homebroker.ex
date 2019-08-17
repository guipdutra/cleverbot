defmodule Cleverbot.Manager.Homebroker do
  alias Cleverbot.Repo.Repository

  def buy(stock, orders) do
    stock = %{price: stock.price, type: "buy", quantity: stock.quantity, currency_code: stock.currency_code}

    result = case Enum.empty?(orders) do
      true ->
        Repository.save_order(stock.currency_code, %{price: stock.price, type: "buy", quantity: 100})
        IO.puts "ordem de COMPRA, preço: #{stock.price}"
        stock
      false -> save_order_if_there_is_one_active(stock, orders)
    end

    {:ok, result}
  end

  def sell(stock, orders) do
    stock = %{price: stock.price, type: "sell", quantity: stock.quantity, currency_code: stock.currency_code}

    result = case Enum.empty?(orders) do
      true -> :there_is_no_stocks_to_sell
      false -> save_order_if_there_is_stocks(stock, orders)
        IO.puts "ordem de VENDA, preço: #{stock.price}"
        stock
    end

    {:ok, result}
  end

  defp save_order_if_there_is_stocks(stock, orders) do
    case List.first(orders)["type"] do
      "buy" ->
        Repository.save_order(stock.currency_code, %{price: stock.price, type: "sell", quantity: 100})
        stock
      "sell" ->
        :there_is_no_stocks_to_sell
    end
  end

  defp save_order_if_there_is_one_active(stock, orders) do
    case List.first(orders)["type"] do
      "buy" ->
        :already_exist_order_waiting_for_sell
      "sell" ->
        Repository.save_order(stock.currency_code, %{price: stock.price, type: "buy", quantity: 100})
        stock
    end
  end
end
