defmodule AOC.Y2024.Day6 do

  def parse(input) do
    String.graphemes(input)
    |> Enum.reduce({MapSet.new(), 0, 0, 0, {0, 0}}, fn
      "\n", {obs, r, c, _, st} -> {obs, r + 1, 0, c, st}
      "^", {obs, r, c, wd, _} -> {obs, r, c + 1, wd, {r, c}}
      "#", {obs, r, c, wd, st} -> {MapSet.put(obs, {r, c}), r, c + 1, wd, st}
      ".", {obs, r, c, wd, st} -> {obs, r, c + 1, wd, st}
    end)
    |> then(fn {obs, r, _, wd, st} -> %{obs: obs, rows: r + 1, cols: wd, init: st} end)
  end

  def outside?(setup, r, c), do: r < 0 || r == setup.rows || c < 0 || c == setup.cols

  def turn(:north), do: :east
  def turn(:east), do: :south
  def turn(:south), do: :west
  def turn(:west), do: :north

  def offset(:north), do: {-1, 0}
  def offset(:east), do: {0, 1}
  def offset(:south), do: {1, 0}
  def offset(:west), do: {0, -1}

  def walk(setup), do: walk(setup, setup.init, :north, MapSet.new())
  def walk(setup, {r, c}, dir, seen) do
    {dr, dc} = offset(dir)
    {nr, nc} = {r + dr, c + dc}

    seen = MapSet.put(seen, {r, c})

    cond do
      MapSet.member?(setup.obs, {nr, nc}) ->
        walk(setup, {r, c}, turn(dir), seen)
      outside?(setup, nr, nc) ->
        seen
      :else ->
        walk(setup, {nr, nc}, dir, seen)
    end
  end

  def silver(setup) do
    walk(setup)
    |> MapSet.size()
    |> inspect()
  end

  def check_loop(setup), do: check_loop(setup, setup.init, :north, MapSet.new())
  def check_loop(setup, {r, c}, dir, seen) do
    {dr, dc} = offset(dir)
    {nr, nc} = {r + dr, c + dc}

    seen = MapSet.put(seen, {r, c, dir})

    cond do
      MapSet.member?(seen, {nr, nc, dir}) ->
        true
      MapSet.member?(setup.obs, {nr, nc}) ->
        check_loop(setup, {r, c}, turn(dir), seen)
      outside?(setup, nr, nc) ->
        false
      :else ->
        check_loop(setup, {nr, nc}, dir, seen)
    end
  end

  def gold(setup) do
    walk(setup)
    |> MapSet.delete(setup.init)
    |> MapSet.to_list()
    |> Stream.map(fn p -> %{setup | obs: MapSet.put(setup.obs, p)} end)
    |> Stream.filter(&check_loop/1)
    |> Enum.count()
    |> inspect()
  end

  def solver, do: AOC.Scaffold.chain_solver(&parse/1, &silver/1, &gold/1)

end
