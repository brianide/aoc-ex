defmodule AOC.Util.Regex do
  defp parse_match(groups, types) do
    Enum.zip_with(types, groups, fn
      :str, t ->
        t
      :int, t ->
        String.to_integer(t)
      :point, t ->
        [x, y] = Regex.run(~r/^\s*(\d+)\s*,\s*(\d+)\s*$/, t, capture: :all_but_first)
        {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def scan_typed(reg, types, text) do
    for groups <- Regex.scan(reg, text, capture: :all_but_first) do
      parse_match(groups, types)
    end
  end
end
