defmodule AOC.Y2024.Day13 do
  @moduledoc title: "Claw Contraption"
  @moduledoc url: "https://adventofcode.com/2024/day/13"

  def solver, do: AOC.Scaffold.chain_solver(2024, 13, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    Regex.scan(~r/Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)/, input)
    |> Stream.map(fn m -> m |> tl() |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(fn [ax, ay, bx, by, tx, ty] -> {{ax, ay}, {bx, by}, {tx, ty}} end)
  end

  def solve_case({{ax, ay}, {bx, by}, {tx, ty}}) do
    (for ac <- 0..100,
        bc <- 0..100,
        ax * ac + bx * bc === tx,
        ay * ac + by * bc === ty,
        do: ac * 3 + bc)
    |> Enum.sort(:asc)
    |> List.first()
  end

  def silver(input) do
    input
    |> Task.async_stream(&solve_case/1)
    |> Enum.reduce(0, fn
      {:ok, n}, acc when not is_nil(n) -> acc + n
      _, acc -> acc
    end)
    |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
