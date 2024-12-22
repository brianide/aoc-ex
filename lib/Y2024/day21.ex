defmodule AOC.Y2024.Day21 do
  @moduledoc title: "Keypad Conundrum"
  @moduledoc url: "https://adventofcode.com/2024/day/21"

  def solver, do: AOC.Scaffold.chain_solver(2024, 21, &parse/1, &silver/1, &gold/1)

  defmodule Grids do
    import AOC.Sigils

    @keypad ~g"""
              789
              456
              123
              #0A
              """

    @panel ~g"""
             #^A
             <v>
             """

    def keypad, do: @keypad
    def panel, do: @panel

    def offset("<"), do: {0, -1}
    def offset(">"), do: {0, 1}
    def offset("^"), do: {-1, 0}
    def offset("v"), do: {1, 0}
  end

  def parse(input) do
    for s <- String.split(input, "\n"),
        score = String.slice(s, 0..2) |> String.to_integer(),
        digits = String.graphemes(s),
        do: {digits, score}
  end

  defp diff({r, c}, {br, bc}), do: {r - br, c - bc}
  defp add({r, c}, {br, bc}), do: {r + br, c + bc}

  defp combos(a, b, prefix \\ [])
  defp combos([], [], prefix), do: [prefix]
  defp combos([], b, prefix), do: [b ++ prefix]
  defp combos(a, [], prefix), do: combos([], a, prefix)
  defp combos([ha | resta], [hb | restb], prefix) do
    [
      combos(resta, [hb | restb], [ha | prefix]),
      combos([ha | resta], restb, [hb | prefix]),
    ]
    |> Stream.concat()
  end

  defp check_path(pos, path, grid) do
    dud = Map.get(grid, "#")

    Stream.map(path, &Grids.offset/1)
    |> Stream.scan(pos, &add/2)
    |> Enum.all?(&(&1 !== dud))
  end

  defp paths(src, dst, depth) do
    grid = if depth === 0, do: Grids.keypad(), else: Grids.panel()
    src_pos = Map.get(grid, src)
    dst_pos = Map.get(grid, dst)
    {dr, dc} = diff(dst_pos, src_pos)

    moves =
      fn d, inc, dec ->
        (if d > 0, do: inc, else: dec)
        |> Stream.duplicate(abs(d))
        |> Enum.to_list()
      end

    combos(moves.(dr, "v", "^"), moves.(dc, ">", "<"))
    |> Enum.filter(&check_path(src_pos, &1, grid))
  end

  def silver(_input) do
    paths("7", "3", 0)
    |> inspect()
  end

  def gold(_input) do
    "Not implemented"
  end

end
