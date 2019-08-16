defmodule Cleverbot.Manager.Strategies.SimpleMovingAverage do
  import SMA

  def execute(%{short_period: short_period, long_period: long_period, stocks: stocks}) do
    stocks = stocks |> Enum.map(&String.to_float/1)
    short_moving_average = sma(stocks, short_period)
    long_moving_average = sma(stocks, long_period)

    if !Enum.empty?(short_moving_average) && !Enum.empty?(long_moving_average) do
      IO.puts "short moving average #{List.first(short_moving_average)}"
      IO.puts "long moving average #{List.first(long_moving_average)}"
      case List.first(short_moving_average) > List.first(long_moving_average) do
        true -> :buy
        false -> :sell
      end
    end
  end
end
