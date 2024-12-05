defmodule AOC.Main do

  defp get_part(str) when str in ["s", "silver"], do: [:silver]
  defp get_part(str) when str in ["g", "gold"], do: [:gold]
  defp get_part(str) when str in ["b", "both"], do: [:silver, :gold]

  defp solutions, do: [
    AOC.Day1,
    AOC.Day2,
    AOC.Day3,
  ]

  def main, do: main(System.argv())
  def main(args) do
    [year, day, part, infile | _] = args
    year = String.to_integer(year)
    day = String.to_integer(day)
    part = get_part(part)

    Enum.find(solutions(), fn mod ->
      case apply(mod, :solution_info, []) do
        {^year, ^day, _} -> true
        _ -> false
      end
    end)
    |> apply(:_solve, [infile, part])
    |> IO.puts()
  end
end
