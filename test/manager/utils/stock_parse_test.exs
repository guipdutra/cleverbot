defmodule Cleverbot.Manager.Utils.StockParseTest do
  use ExUnit.Case
  alias Cleverbot.Manager.Utils.StockParse

  test "convert streaming data from string to Stock" do
    stock_data = [
      1002,
      nil,
      [218, "1.34543425", "1.34421299", "1.23475671", "0.06616981", "5744.01346989",
        "4629.36825592", 0, "1.34543425", "1.22000000"]
    ]

    assert Cleverbot.Manager.Utils.StockParse.parse(stock_data) == %{currency_code: 218, price: "1.34543425"}
  end
end
