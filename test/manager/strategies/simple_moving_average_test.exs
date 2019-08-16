defmodule Cleverbot.Manager.Strategies.SimpleMovingAverageTest do
  use ExUnit.Case
  alias Cleverbot.Manager.Strategies.SimpleMovingAverage

  test "based on the prices should return a buy operation" do
    stocks = ["1.94543425", "1.94421299", "1.93475671",
      "1.36616981", "1.401346989", "1.34543425", "1.22000000"]

    assert Cleverbot.Manager.Strategies.SimpleMovingAverage.execute(
      %{short_period: 3, long_period: 7, stocks: stocks}) == :buy
  end

  test "based on the prices should return a sell operation" do
    stocks = ["1.34543425", "1.34421299", "1.23475671",
      "1.36616981", "1.401346989", "1.34543425", "1.22000000"]

    assert Cleverbot.Manager.Strategies.SimpleMovingAverage.execute(
      %{short_period: 3, long_period: 7, stocks: stocks}) == :sell
  end
end
