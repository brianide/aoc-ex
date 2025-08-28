defmodule AOC.Read do

  defp find_seqs(fmt) when is_list(fmt), do: find_seqs(List.to_string(fmt))

  defp find_seqs(fmt) do
    for [omit, seq] <- Regex.scan(~r/~(\*)?(?:\d+)?t?([~du\-#fsacl])/, fmt, capture: :all_but_first),
        reduce: [] do acc ->
          cond do
            omit == "*" or seq == "~" ->
              acc
            seq in ~w(s c) ->
              [:string | acc]
            :else ->
              [:identity | acc]
          end
        end
    |> Enum.reverse()
  end

  def fscan(fmt, seqs, str, coll)

  def fscan(fmt, seqs, str, coll) when is_binary(str) do
    fscan(fmt, seqs, String.to_charlist(str), coll)
  end

  def fscan(fmt, seqs, str, coll) do
    case :io_lib.fread(fmt, str) do
      {:ok, res, more} ->
        Enum.zip_reduce(res, seqs, [], fn
          term, :string, acc ->
            [List.to_string(term) | acc]

          term, :identity, acc ->
            [term | acc]
        end)
        |> Enum.reverse()
        |> case do n -> fscan(fmt, seqs, more, [n | coll]) end

      _ ->
        Enum.reverse(coll)
    end
  end

  defmacro fscan(fmt, str) do
    fmt = Macro.expand(fmt, __CALLER__)
    fmt_bin = if is_binary(fmt), do: fmt, else: List.to_string(fmt)
    fmt_chars = if is_list(fmt), do: fmt, else: String.to_charlist(fmt)
    seqs = find_seqs(fmt_bin)

    quote do
      apply(unquote(__MODULE__), :fscan, [unquote(fmt_chars), unquote(seqs), unquote(str), []])
    end
  end

end
