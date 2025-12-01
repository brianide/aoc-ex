defmodule AOC.Y2019.Day12 do
  use AOC.Solution,
    title: "The N-Body Problem",
    url: "https://adventofcode.com/2019/day/12",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

  require AOC.Read

  def parse(input) do
    AOC.Read.fscan("<x=~d, y=~d, z=~d>\n", input)
  end

  def step(moons) do
    Enum.map(moons, fn {position, velocity} ->
      Enum.reduce(moons, velocity, fn {other_position, _}, velocity ->
        for {p1, p2, v} <- Enum.zip([position, other_position, velocity]) do
          cond do
            p1 > p2 -> v - 1
            p1 < p2 -> v + 1
            :else -> v
          end
        end
      end)
      |> case do velocity ->
        position = for {p, v} <- Enum.zip(position, velocity), do: p + v
        {position, velocity}
      end
    end)
  end

  def silver(input) do
    Enum.map(input, &{&1, [0, 0, 0]})
    |> Stream.iterate(&step/1)
    |> Enum.at(1000)
    |> Enum.reduce(0, fn {position, velocity}, acc ->
      ps = Enum.map(position, &Kernel.abs/1) |> Enum.sum()
      vs = Enum.map(velocity, &Kernel.abs/1) |> Enum.sum()
      acc + ps * vs
    end)
  end

  def gold(_input) do
    "Not implemented"
  end

end
