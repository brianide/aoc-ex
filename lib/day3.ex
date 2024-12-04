defmodule AOC.Day3 do
  use AOC.Scaffold.Solution, {2024, 3, "Mull It Over"}
  use AOC.Scaffold.DoubleSolver

  def parse(input) do
    Regex.scan(~r/(mul|do|don't)(?:\(\)|\((\d+),(\d+)\))/, input)
    |> Enum.map(&Kernel.tl/1)
    |> Enum.map(fn
      ["do"] -> {:turn, :on}
      ["don't"] -> {:turn, :off}
      ["mul", a, b] -> {:mul, String.to_integer(a) * String.to_integer(b)}
    end)
  end

  def solve(input) do
    Enum.reduce(input, {:on, 0, 0}, fn
      {:turn, o}, {_, s, g} -> {o, s, g}
      {:mul, n}, {:on, s, g} -> {:on, s + n, g + n}
      {:mul, n}, {:off, s, g} -> {:off, s + n, g}
    end)
    |> then(fn {_, s, g} -> {s, g} end)
  end
end
