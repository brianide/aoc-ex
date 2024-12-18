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
    for s <- String.graphemes(input), s !== "\n" do
      case s do
        "<" -> {0, -1}
        ">" -> {0, 1}
        "v" -> {1, 0}
        "^" -> {-1, 0}
      end
    end
  end

  def parse(input) do
    [map, dirs] = String.split(input, "\n\n")
    Tuple.append(parse_map(map), parse_dirs(dirs))
  end

  defp add({r, c}, {dr, dc}), do: {r + dr, c + dc}

  defp score(rocks) do
    Stream.map(rocks, fn {r, c} -> 100 * r + c end)
    |> Enum.sum()
  end

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

  def silver({walls, rocks, start, dirs}) do
    simulate(walls, rocks, start, dirs)
    |> score()
  end

  defp convert({walls, rocks, {sr, sc}, dirs}) do
    walls = walls |> Stream.flat_map(fn {r, c} -> [{r, c * 2}, {r, c * 2 + 1}] end) |> MapSet.new()
    rocks = rocks |> Stream.map(fn {r, c} -> {r, c * 2} end) |> MapSet.new()
    {walls, rocks, {sr, sc * 2}, dirs}
  end

  # defp check_rock(rocks, {r, c}), do: Enum.find([{r, c}, {r, c - 1}], &(&1 in rocks))

  defp push_wide(walls, rocks, pos, dir, reached \\ MapSet.new()) do
    next = add(pos, dir)
    offs = add(next, {0, -1})

    cond do
      next in walls ->
        :error
      next in rocks || offs in rocks ->
        next = Enum.find([next, offs], &(&1 in rocks))
        push_wide(walls, rocks, next, dir)
      :else -> {:ok, next}
    end
  end

  defp simulate_wide(walls, rocks, pos, [dir | dirs]) do
    next = add(pos, dir)
    offs = add(next, {0, -1})

    cond do
      next in walls ->
        simulate_wide(walls, rocks, pos, dirs)
      next in rocks || offs in rocks ->
        next = Enum.find([next, offs], &(&1 in rocks))
        case push_wide(walls, rocks, next, dir) do
          {:ok, reached} ->
            rocks =
              for {r, c} <- reached,
                  reduce: rocks do
                    rocks -> rocks |> MapSet.delete({r, c}) |> MapSet.put(add({r, c}, dir))
                  end
            simulate_wide(walls, rocks, pos, dirs)
        end
      :else -> simulate(walls, rocks, next, dirs)
    end
  end

  def gold(input) do
    {walls, rocks, start, dirs} = convert(input)
    simulate_wide(walls, rocks, start, dirs)
    |> inspect(charlists: :as_lists)
  end

end
