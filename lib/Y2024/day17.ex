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
      7 -> throw("Invalid operator")
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

  # def silver({regs, prog}), do: run_prog(regs, prog) |> Enum.join(",")

  def silver({regs, prog}) do
    for n <- 0..4096,
        res = run_prog(put_elem(regs, 0, n), prog) |> Enum.join(",") do
          IO.puts("#{n}: #{res}")
        end
  end

  # def search_proc(parent, ind, {regs, prog}, targ) do
  #   send(parent, {:ready, self()})
  #   receive do
  #     {:search, range} ->
  #       case Enum.find(range, &(run_prog(put_elem(regs, 0, &1), prog)) === targ) do
  #         nil ->
  #           search_proc(parent, ind, {regs, prog}, targ)
  #         n ->
  #           send(parent, {:found, n})
  #       end
  #   after
  #     10000 -> nil
  #   end
  # end

  # @step 10000000

  # def search_cont(input, n \\ 0) do
  #   receive do
  #     {:found, n} -> n
  #     {:ready, pid} ->
  #       lim = n + @step - 1
  #       IO.puts("Running #{n} through #{lim}")
  #       send(pid, {:search, n..lim})
  #       search_cont(input, lim + 1)
  #   end
  # end

  # def gold({regs, prog}) do
  #   parent = self()
  #   target = Tuple.to_list(prog)

  #   Enum.each(1..System.schedulers_online(), &spawn(__MODULE__, :search_proc, [parent, &1, {regs, prog}, target]))
  #   search_cont({regs, prog})
  # end

  #### Powers of 8 ####
  # def gold({regs, prog}) do
  #   for n <- 0..1000000 do
  #     res = run_prog(put_elem(regs, 0, n), prog)
  #     {n, length(res), res}
  #   end
  #   |> Enum.chunk_by(&elem(&1, 1))
  #   |> Enum.map(fn ch -> Enum.map(ch, &elem(&1, 0)) end)
  #   |> Enum.map(&List.first/1)
  #   |> IO.inspect(charlists: :as_lists)
  #   ""
  # end

  #### Nth digit ####
  # def gold({regs, prog}) do
  #   for n <- 0..1000000 do
  #     res = run_prog(put_elem(regs, 0, n), prog)
  #     Enum.at(res, 1)
  #   end
  #   |> Enum.join(" ")
  #   |> IO.puts()
  #   ""
  # end

  defp run_expect(_, ip, _, prog) when ip >= tuple_size(prog), do: :error
  defp run_expect(_, _, [], _), do: :ok
  defp run_expect({a, b, c}, ip \\ 0, expect, prog) do
    op = elem(prog, ip)
    arg = elem(prog, ip + 1)
    case op do
      0 ->
        {div(a, 2 ** combo({a, b, c}, arg)), b, c, ip + 2, expect}
      1 ->
        {a, Bit.bxor(b, arg), c, ip + 2, expect}
      2 ->
        {a, rem(combo({a, b, c}, arg), 8), c, ip + 2, expect}
      3 when a !== 0 ->
        {a, b, c, arg, expect}
      4 ->
        {a, Bit.bxor(b, c), c, ip + 2, expect}
      5 ->
        if rem(combo({a, b, c}, arg), 8) === hd(expect) do
          {a, b, c, ip + 2, tl(expect)}
        else
          :error
        end
      6 ->
        {a, div(a, 2 ** combo({a, b, c}, arg)), c, ip + 2, expect}
      7 ->
        {a, b, div(a, 2 ** combo({a, b, c}, arg)), ip + 2, expect}
      _ ->
        {a, b, c, ip + 2, expect}
    end
    |> case do
      {a, b, c, ip, expect} ->
        run_expect({a, b, c}, ip, expect, prog)
      :error -> :error
    end
  end

  def search_proc(parent, ind, {regs, prog}, targ) do
    send(parent, {:ready, self()})
    receive do
      {:search, range} ->
        case Enum.find(range, &(run_expect(put_elem(regs, 0, &1), targ, prog)) === :ok) do
          nil ->
            search_proc(parent, ind, {regs, prog}, targ)
          n ->
            send(parent, {:found, n})
        end
    after
      10000 -> nil
    end
  end

  @step 10000000

  def search_cont(input, n \\ 8 ** 16) do
    receive do
      {:found, n} -> n
      {:ready, pid} ->
        lim = n + @step - 1
        IO.puts("Running #{n} through #{lim}")
        send(pid, {:search, n..lim})
        search_cont(input, lim + 1)
    end
  end

  def gold({regs, prog}) do
    parent = self()
    target = Tuple.to_list(prog)

    Enum.each(1..System.schedulers_online(), &spawn(__MODULE__, :search_proc, [parent, &1, {regs, prog}, target]))
    search_cont({regs, prog})
  end

end
