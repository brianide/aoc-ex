defmodule AOC.Y2024.Day11 do
  @moduledoc title: "Plutonian Pebbles"
  @moduledoc url: "https://adventofcode.com/2024/day/11"

  use AOC.Solvers.AndThen, [2024, 11, &parse/1, &silver/1, &gold/2]

  def parse(input) do
    String.split(input, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def digits(a), do: :math.log10(a + 1) |> ceil()

  def update_stone(_n, 0, mem), do: {1, mem}

  def update_stone(0, steps, mem), do: update_stone(1, steps - 1, mem)

  def update_stone(n, steps, mem) when is_map_key(mem, {n, steps}), do: {mem[{n, steps}], mem}

  def update_stone(n, steps, mem) do
    case digits(n) do
      len when rem(len, 2) === 0 ->
        d = 10 ** div(len, 2)
        {left, mem} = update_stone(div(n, d), steps - 1, mem)
        {right, mem} = update_stone(rem(n, d), steps - 1, mem)
        {left + right, mem}

      _ ->
        update_stone(n * 2024, steps - 1, mem)
    end
    |> case do {res, mem} ->
      {res, put_in(mem[{n, steps}], res)}
    end
  end

  def solve(input, steps, mem \\ %{}) do
    for rock <- input, reduce: {0, mem} do {acc, mem} ->
      {val, mem} = update_stone(rock, steps, mem)
      {acc + val, mem}
    end
  end

  def silver(input), do: solve(input, 25)

  def gold(input, mem), do: solve(input, 75, mem) |> then(&elem(&1, 0))

end
