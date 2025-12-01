defmodule AOC.Y2025.Day1 do
  use AOC.Solution,
    title: "Secret Entrance",
    url: "https://adventofcode.com/2025/day/1",
    scheme: {:once, &parse/1, &solve/1},
    complete: true

  def parse(input) do
    for [_, l, d] <- Regex.scan(~r/(L|R)(\d+)/, input) do
      case l do
        "L" -> -1 * String.to_integer(d)
        "R" -> String.to_integer(d)
      end
    end
  end

  def solve(input) do
    for d <- input,
        reduce: {50, 0, 0} do {val, a, b} ->
          case val + d do
            n when n <= 0 ->
              c = div(n, -100)
              n = rem(n + 100 * (c + 1), 100)
              m = if val == 0, do: 0, else: 1
              {n, c + m}
            n when n >= 100 ->
              c = div(n, 100)
              n = rem(n, 100)
              {n, c}
            n ->
              {n, 0}
          end
          |> case do
            {0, cnt} -> {0, a + 1, b + cnt}
            {n, cnt} -> {n, a, b + cnt}
          end
        end
    |> case do
      {_, a, b} -> {a, b}
    end
  end
end
