defmodule AOC.Util do

  def sign(x) when x > 0, do: 1
  def sign(x) when x < 0, do: -1
  def sign(_), do: 0

  def parse_parts(s) when s in ["s", "silver"], do: :silver
  def parse_parts(s) when s in ["g", "gold"], do: :gold
  def parse_parts(s) when s in ["b", "both"], do: :both

  def ensure_dir(path) do
    case File.mkdir_p(path) do
      {:error, :eexist} -> :ok
      res -> res
    end
  end

  @doc """
  Parses a rectangular map from `str`, producing a map associating characters/graphemes to lists of
  coordinates at which they occur. Optionally returns the dimensions of the map.
  """
  @type parsed_map() :: %{optional(char() | String.t()) => [{integer(), integer()}]}
  @spec parse_map(String.t(), [{:ignore, [String.t()]} | {:dims, boolean()} | {:as_strings, boolean()}]) :: parsed_map() | {parsed_map(), {integer(), integer()}}
  def parse_map(str, opts \\ []) do
    opts = Keyword.validate!(opts, ignore: [".", ?.], dims: true, as_strings: false)
    splitter = if opts[:as_strings], do: &String.graphemes/1, else: &String.to_charlist/1

    str
    |> String.trim()
    |> splitter.()
    |> Enum.reduce({%{}, 0, 0, 0}, fn
      ch, {chars, r, c, _} when ch in [?\n, "\n"] -> {chars, r + 1, 0, c}
      ch, {chars, r, c, wd} -> {(if ch in opts[:ignore], do: chars, else: Map.update(chars, ch, [{r, c}], &[{r, c} | &1])), r, c + 1, wd}
    end)
    |> case do
      {chars, r, _, wd} -> if not opts[:dims], do: chars, else: {chars, {r + 1, wd}}
    end
  end

  @doc """
  Returns the first value between `l` and `r` (inclusive) for which `pred` returns a truthy value,
  or `nil` if no such value exists.
  """
  @spec bin_search(term(), term(), (term() -> boolean())) :: term()
  def bin_search(l, r, _) when l === r, do: l
  def bin_search(l, r, pred) do
    m = ceil((l + r) / 2)
    if pred.(m) do
      bin_search(l, m - 1, pred)
    else
      bin_search(m, r, pred)
    end
  end

  @unset {__MODULE__, :unset}
  def pairwise(enum) do
    Stream.transform(enum, @unset, fn
      curr, @unset -> {[], curr}
      curr, prev -> {[{prev, curr}], curr}
    end)
  end

  def all_pairs(enum) when not is_list(enum), do: all_pairs(Enum.to_list(enum))
  def all_pairs([]), do: []
  def all_pairs([_]), do: []
  def all_pairs([h | rest]) do
    Stream.unfold({h, rest, rest}, fn
      {h, [t | ts], more} -> {{h, t}, {h, ts, more}}
      {_, [], [h, t | ts]} -> {{h, t}, {h, ts, [t | ts]}}
      {_, [], [_]} -> nil
    end)
  end

end
