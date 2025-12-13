defmodule AOC.Y2025.Day12 do
  import AOC.Read, only: [fscan: 2]

  use AOC.Solution,
    title: "Christmas Tree Farm",
    url: "https://adventofcode.com/2025/day/12",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

  @shape_count 6

  def read_shape(row \\ 0, col \\ 0, ps \\ [], bin) do
    case bin do
      <<_, ?:, ?\n, rest::binary>> -> read_shape(row, col, ps, rest)
      <<?\n, ?\n, rest::binary>> -> {ps, rest}
      <<?\n, rest::binary>> -> read_shape(row + 1, 0, ps, rest)
      <<?#, rest::binary>> -> read_shape(row, col + 1, [{row, col} | ps], rest)
      <<?., rest::binary>> -> read_shape(row, col + 1, ps, rest)
    end
  end

  def read_regions(bin) do
    for [rows, cols | rest] <- fscan("~dx~d: ~d ~d ~d ~d ~d ~d", bin) do
      {{rows, cols}, rest}
    end
  end

  def parse(input) do
    {shapes, rest} =
      for _ <- 1..@shape_count, reduce: {[], input} do
        {acc, bin} ->
          {ps, rest} = read_shape(bin)
          {[ps | acc], rest}
      end

    regions = read_regions(rest)
    {shapes, regions}
  end

  # def rotate(shape), do: for({r, c} <- shape, do: {c, 2 - r})

  # def flip(shape), do: for({r, c} <- shape, do: {r, 2 - c})

  # def permutations(shape) do
  #   flipped = flip(shape)

  #   for _ <- 1..3, reduce: [shape, flipped] do
  #     [shape, flip | _] = list -> [rotate(shape), rotate(flip) | list]
  #   end
  #   |> Enum.uniq()
  # end

  # def place_shape_at(grid, shape, r, c) do
  #   Enum.reduce_while(shape, grid, fn {dr, dc}, grid ->
  #     placed = {r + dr, c + dc}

  #     if not MapSet.member?(grid, placed) do
  #       {:cont, MapSet.put(grid, placed)}
  #     else
  #       {:halt, false}
  #     end
  #   end)
  # end

  # def can_fit_area?(shapes, {{rows, cols}, counts}) do
  #   space = rows * cols

  #   blocks = Enum.map(shapes, &Kernel.length/1) |> Enum.zip_with(counts, &Kernel.*/2) |> Enum.sum()
  #   area = Enum.sum(counts) * 9

  #   space >= blocks and space >= area
  # end

  # def silver({shapes, regions}) do
  #   Enum.count(regions, &can_fit_area?(shapes, &1))
  # end

  def silver({_, regions}) do
    Enum.count(regions, fn {dims, counts} -> Enum.sum(counts) * 9 <= Tuple.product(dims) end)
  end

  def gold(_input) do
    "Merry Christmas"
  end
end
