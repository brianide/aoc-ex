defmodule AOC.Y2025.Day2 do
  use AOC.Solution,
    title: "Gift Shop",
    url: "https://adventofcode.com/2025/day/2",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: true,
    favorite: true

  def parse(input) do
    for [_, st, ed] <- Regex.scan(~r/(\d+)-(\d+)/, input),
        st = String.to_integer(st),
        ed = String.to_integer(ed) do
          {st, ed}
        end
  end

  def digits(n), do: :math.log10(n + 1) |> ceil()

  def normalize_range({st, ed}) do
    len = digits(st)
    scale = 10 ** div(len, 2)
    init =
      if rem(len, 2) === 0 do
        fore = div(st, scale)
        aft = rem(st, scale)
        if fore >= aft, do: fore, else: fore + 1
      else
        scale
      end

    len = digits(ed)
    limit =
      if rem(len, 2) === 0 do
        ed
      else
        10 ** (len - 1) - 1
      end

    {init, limit}
  end

  def count_invalid(count, prefix, limit) do
    len = digits(prefix)
    case prefix + prefix * 10 ** len do
      n when n > limit ->
        count
      n ->
        count_invalid(count + n, prefix + 1, limit)
    end
  end

  def silver(input) do
    for range <- input,
        {prefix, stop} = normalize_range(range),
        reduce: 0 do acc ->
          count_invalid(acc, prefix, stop)
    end
  end

  def factors(n), do: factors([1], n, 2, floor(:math.sqrt(n)))

  def factors(coll, _n, i, limit) when i > limit, do: coll

  def factors(coll, n, i, limit) do
    cond do
      i * i === n ->
        factors([i | coll], n, i + 1, limit)
      rem(n, i) === 0 ->
        factors([i, div(n, i) | coll], n, i + 1, limit)
      :else ->
        factors(coll, n, i + 1, limit)
    end
  end

  def mask(mult, t) do
    for _ <- 2..t,
        reduce: 1 do acc ->
          acc * mult + 1
        end
  end

  def divisors_for_length(len, mem) when is_map_key(mem, len), do: {mem[len], mem}

  def divisors_for_length(len, mem) do
    for k <- factors(len),
        f = 10 ** k,
        m = div(len, k) do
          mask(f, m)
        end
    |> case do res ->
      {res, put_in(mem[len], res)}
    end
  end

  def check_invalid(id, mem) do
    len = digits(id)
    {divs, mem} = divisors_for_length(len, mem)
    res = Enum.any?(divs, fn div -> rem(id, div) === 0 end)
    {res, mem}
  end

  def gold(input) do
    for {st, ed} <- input,
        n <- st..ed,
        reduce: {0, %{}} do {total, mem} ->
          {inv, mem} = check_invalid(n, mem)
          if inv do
            {total + n, mem}
          else
            {total, mem}
          end
        end
    |> case do {res, _} -> res end
  end

end
