defmodule AOC.Y2024.Day17 do
  @moduledoc title: "Chronospatial Computer"
  @moduledoc url: "https://adventofcode.com/2024/day/17"

  alias Bitwise, as: Bit

  def solver, do: AOC.Scaffold.chain_solver(2024, 17, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    (for [s] <- Regex.scan(~r/\d+/, input), do: String.to_integer(s))
    |> case do
      [a, b, c | prog] -> {{a, b, c}, List.to_tuple(prog)}
    end
  end

  defp combo({a, b, c}, arg) do
    case arg do
      n when n in 0..3 -> n
      4 -> a
      5 -> b
      6 -> c
    end
  end

  defp run_prog(regs, ip \\ 0, out \\ [], prog)
  defp run_prog(_, ip, out, prog) when ip >= tuple_size(prog), do: Enum.reverse(out)
  defp run_prog({a, b, c}, ip, out, prog) do
    op = elem(prog, ip)
    arg = elem(prog, ip + 1)
    case op do
      0 ->
        {div(a, 2 ** combo({a, b, c}, arg)), b, c, ip + 2, out}
      1 ->
        {a, Bit.bxor(b, arg), c, ip + 2, out}
      2 ->
        {a, rem(combo({a, b, c}, arg), 8), c, ip + 2, out}
      3 when a !== 0 ->
        {a, b, c, arg, out}
      4 ->
        {a, Bit.bxor(b, c), c, ip + 2, out}
      5 ->
        {a, b, c, ip + 2, [rem(combo({a, b, c}, arg), 8) | out]}
      6 ->
        {a, div(a, 2 ** combo({a, b, c}, arg)), c, ip + 2, out}
      7 ->
        {a, b, div(a, 2 ** combo({a, b, c}, arg)), ip + 2, out}
      _ ->
        {a, b, c, ip + 2, out}
    end
    |> case do
      {a, b, c, ip, out} ->
        run_prog({a, b, c}, ip, out, prog)
    end
  end

  def silver({regs, prog}) do
    run_prog(regs, prog)
    |> Enum.join(",")
  end

  def gold(_), do: "Not implemented"

end
