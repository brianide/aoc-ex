defmodule AOC.Util.Guards do

  @doc "Returns true if `n` is in the range of `[l, u]`"
  defguard is_between(n, l, u) when l <= n and n <= u

  @doc "Returns true if point `p` is inside the rectangle bounded by `b1` and `b2`"
  defguard is_contained(p, b1, b2) when is_between(elem(p, 0), elem(b1, 0), elem(b2, 0)) and is_between(elem(p, 1), elem(b1, 1), elem(b2, 1))

end
