defmodule AOC.Y2024.Day15 do
  @moduledoc title: "Warehouse Woes"
  @moduledoc url: "https://adventofcode.com/2024/day/15"

  def solver, do: AOC.Scaffold.chain_solver(2024, 15, &parse/1, &silver/1, &gold/1)

  defp parse_map(input) do
    String.graphemes(input)
    |> Enum.reduce({[], [], nil, 0, 0, 0}, fn
      "\n", {walls, rocks, st, r, c, _} -> {walls, rocks, st, r + 1, 0, c}
      ".", {walls, rocks, st, r, c, wd} -> {walls, rocks, st, r, c + 1, wd}
      "#", {walls, rocks, st, r, c, wd} -> {[{r, c} | walls], rocks, st, r, c + 1, wd}
      "O", {walls, rocks, st, r, c, wd} -> {walls, [{r, c} | rocks], st, r, c + 1, wd}
      "@", {walls, rocks, _, r, c, wd} -> {walls, rocks, {r, c}, r, c + 1, wd}
    end)
    |> case do {walls, rocks, st, _, _, _} -> {MapSet.new(walls), MapSet.new(rocks), st} end
  end

  defp parse_dirs(input) do
    String.graphemes(input)
    |> Stream.map(fn
      "<" -> {0, -1}
      ">" -> {0, 1}
      "v" -> {1, 0}
      "^" -> {-1, 0}
      _ -> nil
    end)
    |> Enum.filter(&(not is_nil(&1)))
  end

  def parse(input) do
    [map, dirs] = String.split(input, "\n\n")
    Tuple.append(parse_map(map), parse_dirs(dirs))
  end

  defp add({r, c}, {dr, dc}), do: {r + dr, c + dc}

  defp try_push(walls, rocks, pos, dir) do
    next = add(pos, dir)
    cond do
      next in walls -> :error
      next in rocks -> try_push(walls, rocks, next, dir)
      :else -> {:ok, next}
    end
  end

  defp simulate(_, rocks, _, []), do: rocks
  defp simulate(walls, rocks, pos, [dir | dirs]) do
    next = add(pos, dir)
    cond do
      next in walls -> simulate(walls, rocks, pos, dirs)
      next in rocks ->
        case try_push(walls, rocks, next, dir) do
          {:ok, dst} ->
            rocks = rocks |> MapSet.delete(next) |> MapSet.put(dst)
            simulate(walls, rocks, next, dirs)
          :error ->
            simulate(walls, rocks, pos, dirs)
        end
      :else -> simulate(walls, rocks, next, dirs)
    end
  end

  defp score(rocks) do
    Stream.map(rocks, fn {r, c} -> 100 * r + c end)
    |> Enum.sum()
  end

  def silver({walls, rocks, start, dirs}) do
    simulate(walls, rocks, start, dirs)
    |> score()
    # |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
