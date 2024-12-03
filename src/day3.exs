defmodule Day3 do
  def parse(filename) do
    File.read!(filename)
    |> then(&Regex.scan(~r/(do)\(\)|(don't)\(\)|mul\((\d+),(\d+)\)/, &1))
    |> Enum.map(&Kernel.tl/1)
    |> Enum.map(fn
      ["do"] -> :on
      [_, "don't"] -> :off
      [_, _, a, b] -> String.to_integer(a) * String.to_integer(b)
    end)
  end

  def solve(input) do
    Enum.reduce(input, {:on, 0, 0}, fn
      :on, {_, s, g} -> {:on, s, g}
      :off, {_, s, g} -> {:off, s, g}
      n, {:on, s, g} -> {:on, s + n, g + n}
      n, {:off, s, g} -> {:off, s + n, g}
    end)
    |> then(fn {_, s, g} -> "#{s}\n#{g}" end)
  end
end

System.argv()
|> List.first()
|> Day3.parse()
|> Day3.solve()
|> IO.puts()
