defmodule AOC.Y2019.Day11 do
  use AOC.Solution,
    title: "Space Police",
    url: "https://adventofcode.com/2019/day/11",
    scheme: {:intcode, &silver/1, &gold/1},
    complete: true

  alias AOC.Intcode, as: VM
  alias AOC.Util.{Point, Direction}

  def move(position, facing, turn) do
    facing =
      case turn do
        0 -> Direction.turn_left(facing)
        1 -> Direction.turn_right(facing)
      end

    position = Direction.offset(facing) |> Point.add(position)

    {position, facing}
  end

  def step(vm, map \\ %{}, position \\ {0, 0}, facing \\ :north) do
    VM.input(vm, map[position] || 0)
      case VM.get_output(vm, 2) do
        {:ok, [color, turn]} ->
          map = put_in(map[position], color)
          {position, facing} = move(position, facing, turn)
          step(vm, map, position, facing)

        :halt ->
          map
      end
  end

  def silver(prog) do
    vm = VM.create!()
    VM.run_program(vm, prog)
    step(vm) |> map_size()
  end

  def gold(prog) do
    vm = VM.create!()
    VM.run_program(vm, prog)
    image = step(vm, %{{0, 0} => 1})

    {{minr, minc}, {maxr, maxc}} = Map.keys(image) |> Point.bounds()

    for r <- minr..maxr,
        c <- minc..maxc,
        into: <<>> do
      newl = if c == 0 and r > 0, do: "\n", else: ""
      color = if image[{r, c}] == 1, do: IO.ANSI.white_background(), else: IO.ANSI.default_background()
      newl <> color <> " "
    end
  end

end
