defmodule AOC.Y2024.Day13 do
  @moduledoc title: "Claw Contraption"
  @moduledoc url: "https://adventofcode.com/2024/day/13"

  def solver, do: AOC.Scaffold.chain_solver(2024, 13, &parse/1, &solve/1, &solve(&1, 10 ** 13))

  def parse(input) do
    Regex.scan(~r/Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)/, input)
    |> Stream.map(fn m -> m |> tl() |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(fn [ax, ay, bx, by, tx, ty] -> {{ax, ay}, {bx, by}, {tx, ty}} end)
  end

  def solve(input, add \\ 0) do
    input
    |> Stream.filter(fn {{ax, ay}, {bx, by}, _} -> bx * ay !== ax * by && bx * by !== 0 end)
    |> Stream.map(fn {{ax, ay}, {bx, by}, {tx, ty}} ->
      tx = tx + add
      ty = ty + add
      ac = div((tx * by - bx * ty), (ax * by - bx * ay))
      bc = div((ty - ac * ay), by)
      eq = tx === ac * ax + bc * bx && ty === ac * ay + bc * by

      if eq, do: ac * 3 + bc, else: 0
    end)
    |> Enum.sum()
  end

end
