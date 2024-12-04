defmodule AOC.Main do
  @solutions [
    AOC.Day1,
    AOC.Day2,
    AOC.Day3,
  ]

  def main(args \\ []) do
    [year, day, part, infile | _] = args
    year = String.to_integer(year)
    day = String.to_integer(day)

    Enum.find(@solutions, fn mod ->
      case apply(mod, :_solution_info, []) do
        {^year, ^day, _} -> true
        _ -> false
      end
    end)
    |> apply(:_solve, [infile, part])
    |> IO.puts()
  end
end
