defmodule AOC.Day4 do

  @behaviour AOC.Scaffold.Solution
  def solution_info(), do: {2024, 4, "Ceres Search"}

  use AOC.Scaffold.ChainSolver

  def parse(input) do
    String.graphemes(input)
    |> Enum.reduce({0, 0, 0, %{}}, fn
      "\n", {r, c, _, cells} -> {r + 1, 0, c, cells}
      l, {r, c, w, cells} -> {r, c + 1, w, Map.put(cells, {r, c}, l)}
    end)
    |> then(fn {r, _, w, cells} -> %{cells: cells, rows: r, cols: w} end)
  end

  ### Silver

  @dirs for r <- -1..1,
            c <- -1..1,
            r != 0 || c != 0,
            do: {r, c}

  defp check_crossword(grid, r, c) do
    if grid.cells[{r, c}] == "X" do
      for {dr, dc} <- @dirs, reduce: 0 do
        acc -> acc + check_crossword(grid, r + dr, c + dc, dr, dc, ["M", "A", "S"])
      end
    else
      0
    end
  end

  defp check_crossword(_, _, _, _, _, []), do: 1
  defp check_crossword(grid, r, c, dr, dc, [letter | rest]) do
    cond do
      r < 0 || r == grid.rows -> 0
      c < 0 || c == grid.cols -> 0
      grid.cells[{r, c}] == letter -> check_crossword(grid, r + dr, c + dc, dr, dc, rest)
      :else -> 0
    end
  end

  def silver(grid) do
    for r <- 0..grid.rows - 1,
        c <- 0..grid.cols - 1,
        reduce: 0 do
          acc -> acc + check_crossword(grid, r, c)
        end
  end

  ### Gold

  defp check_mas(grid, r, c) do
    freqs =
      [{-1, -1}, {-1, 1}, {1, -1}, {1, 1}]
      |> Stream.map(fn {dr, dc} -> grid.cells[{r + dr, c + dc}] end)
      |> Enum.frequencies()

    cond do
      freqs["M"] != 2 -> 0
      freqs["S"] != 2 -> 0
      grid.cells[{r - 1, c - 1}] == grid.cells[{r + 1, c + 1}] -> 0
      grid.cells[{r - 1, c + 1}] == grid.cells[{r + 1, c - 1}] -> 0
      :else -> 1
    end
  end

  def gold(grid) do
    for r <- 1..grid.rows - 2,
        c <- 1..grid.cols - 2,
        reduce: 0 do
          acc -> if grid.cells[{r, c}] == "A", do: acc + check_mas(grid, r, c), else: acc
        end
  end

end