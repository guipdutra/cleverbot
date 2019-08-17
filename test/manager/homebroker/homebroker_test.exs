defmodule Cleverbot.Manager.HomebrokerTest do
  use ExUnit.Case
  alias Cleverbot.Manager.Homebroker

  test "create a buy order when there is no one" do
    stock = %{currency_code: 218, price: 1.34543425, quantity: 100}

    assert Homebroker.buy(stock, []) ==
      {:ok, %{price: stock.price, "type": "buy", quantity: stock.quantity, currency_code: stock.currency_code}}
  end

  test "do not create a buy order if there is at least one active waiting for sell" do
    stock = %{currency_code: 218, price: 1.34543425, quantity: 100}

    assert Homebroker.buy(stock, [%{"price" => 1.45, "type" => "buy", "quantity" => 100}]) ==
      {:ok, :already_exist_order_waiting_for_sell}
  end

  test "create a buy order if the last operation was a sell" do
    stock = %{currency_code: 218, price: 1.34543425, quantity: 100}

    assert Homebroker.buy(stock, [%{"price" => 1.45, "type" => "sell", "quantity" => 100}]) ==
      {:ok, %{price: stock.price, type: "buy", quantity: stock.quantity, currency_code: stock.currency_code}}
  end

  test "do not create a sell order if does not exist buy order" do
    stock = %{currency_code: 218, price: 1.34543425, quantity: 100}

    assert Homebroker.sell(stock, []) ==
      {:ok, :there_is_no_stocks_to_sell}
  end

  test "create a sell order only if there is one buy order waiting" do
    stock = %{currency_code: 218, price: 1.34543425, quantity: 100}

    assert Homebroker.sell(stock, [%{"price" => 1.45, "type" => "buy", "quantity" => 100}]) ==
      {:ok, %{price: stock.price, type: "sell", quantity: stock.quantity, currency_code: stock.currency_code}}
  end
end
