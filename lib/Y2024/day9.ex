defmodule AOC.Y2024.Day9 do
  @moduledoc title: "Disk Fragmenter"
  @moduledoc url: "https://adventofcode.com/2024/day/9"

  def solver, do: AOC.Scaffold.chain_solver(2024, 9, &parse/1, &silver/1, &gold/1)

  defp chunk_files(ls), do: chunk_files([], ls, :file, 0, 0)
  defp chunk_files(segs, [], _, _, _), do: {Enum.reverse(segs), segs}
  defp chunk_files(segs, [len | rest], mode, id, ind) do
    {val, mode, id} =
      case mode do
        :file -> {id, :gap, id + 1}
        :gap -> {:gap, :file, id}
      end

    (for k <- ind..(ind + len - 1)//1, reduce: segs, do: (acc -> [{val, k} | acc]))
    |> chunk_files(rest, mode, id, ind + len)
  end

  # {:file, ID, INDEX, LENGTH}
  # {:gap, INDEX, LENGTH}

  def parse(input) do
    String.graphemes(input)
    |> Enum.map(&String.to_integer/1)
    |> chunk_files()
  end

  defp score(fore, back), do: score(0, fore, back)
  defp score(total, [{_, f_ind} | _], [{_, b_ind} | _]) when f_ind > b_ind, do: total
  defp score(total, fore, [{:gap, _} | b_rest]), do: score(total, fore, b_rest)
  defp score(total, [{:gap, f_ind} | f_rest], [{b_n, _} | b_rest]), do: score(total + f_ind * b_n, f_rest, b_rest)
  defp score(total, [{f_n, f_ind} | f_rest], back), do: score(total + f_ind * f_n, f_rest, back)

  def silver({fore, back}) do
    score(fore, back)
  end

  def gold(_input) do
    "Not implemented"
  end

end
