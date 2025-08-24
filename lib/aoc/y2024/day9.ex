defmodule AOC.Y2024.Day9 do
  @moduledoc title: "Disk Fragmenter"
  @moduledoc url: "https://adventofcode.com/2024/day/9"

  use AOC.Solvers.Chain, [2024, 9, &parse/1, &silver/1, &gold/1]

  def parse(input), do: String.graphemes(input) |> Enum.map(&String.to_integer/1)

  ### Silver

  defp explode(ls), do: explode([], ls, :file, 0, 0)
  defp explode(segs, [], _, _, _), do: {Enum.reverse(segs), segs}
  defp explode(segs, [len | rest], mode, id, ind) do
    {val, mode, id} =
      case mode do
        :file -> {id, :gap, id + 1}
        :gap -> {:gap, :file, id}
      end

    (for k <- ind..(ind + len - 1)//1, reduce: segs, do: (acc -> [{val, k} | acc]))
    |> explode(rest, mode, id, ind + len)
  end

  defp score({fore, back}), do: score(0, fore, back)
  defp score(total, [{_, f_ind} | _], [{_, b_ind} | _]) when f_ind > b_ind, do: total
  defp score(total, fore, [{:gap, _} | b_rest]), do: score(total, fore, b_rest)
  defp score(total, [{:gap, f_ind} | f_rest], [{b_n, _} | b_rest]), do: score(total + f_ind * b_n, f_rest, b_rest)
  defp score(total, [{f_n, f_ind} | f_rest], back), do: score(total + f_ind * f_n, f_rest, back)

  def silver(nums), do: nums |> explode() |> score()

  ### Gold

  defp chunk(ls), do: chunk([], ls, :file, 0, 0)
  defp chunk(segs, [], _, _, _), do: {Enum.reverse(segs), segs}
  defp chunk(segs, [n | rest], :file, id, ind), do: chunk([{:file, id, ind, n} | segs], rest, :gap, id + 1, ind + n)
  defp chunk(segs, [n | rest], :gap, id, ind), do: chunk([{:gap, ind, n} | segs], rest, :file, id, ind + n)

  # {:file, ID, INDEX, LENGTH}
  # {:gap, INDEX, LENGTH}

  defp slide({segs, puts}), do: slide(segs, puts)
  defp slide(segs, []), do: segs
  defp slide(segs, [{:gap, _, _} | s_rest]), do: slide(segs, s_rest)
  defp slide(segs, [{:file, p_id, p_ind, p_len} | p_rest]) do
    Enum.find_index(segs, fn {:gap, s_ind, s_len} when p_ind > s_ind and s_len >= p_len -> true; _ -> false end)
    |> case do
      nil -> slide(segs, p_rest)
      k ->
        {pre, [{:gap, g_ind, g_len} | post]} = Enum.split(segs, k)
        new_p = [{:file, p_id, g_ind, p_len}]
        new_g = if g_len === p_len, do: [], else: [{:gap, g_ind + p_len, g_len - p_len}]
        post = Enum.filter(post, fn {:file, r_id, _, _} when r_id === p_id -> false; _ -> true end)
        segs = Enum.concat([pre, new_p, new_g, post])
        slide(segs, p_rest)
    end
  end

  def gold(nums) do
    nums
    |> chunk()
    |> slide()
    |> Enum.reduce(0, fn
      {:file, id, ind, len}, acc -> for n <- ind..(ind + len - 1)//1, reduce: acc, do: (acc -> acc + n * id)
      _, acc -> acc
    end)
  end

end
