defmodule Cleverbot.Manager.Utils.StockParse do
  def parse(stock_data) do
    stock_data_flattened = List.flatten(stock_data)
    %{currency_code: Enum.at(stock_data_flattened, 2), price: Enum.at(stock_data_flattened, 3)}
  end
end
