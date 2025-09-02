defmodule AOC.Y2019.Day7 do
  use AOC.Solution,
    title: "Amplification Circuit",
    url: "https://adventofcode.com/2019/day/7",
    scheme: {:intcode, &silver/1, &gold/1},
    complete: false

  alias AOC.Intcode, as: VM

  @perms_a AOC.Util.permutations([0, 1, 2, 3, 4])
  @perms_b AOC.Util.permutations([5, 6, 7, 8, 9])
  @nodes 5

  def silver(prog) do
    {:ok, vm} = VM.create()

    Stream.map(@perms_a, fn perm ->
      for phase <- perm,
          reduce: 0 do
        prev ->
          VM.run_program(vm, prog)
          VM.input(vm, [phase, prev])
          VM.get_output!(vm)
      end
    end)
    |> Enum.max()
    |> tap(fn _ -> VM.stop(vm) end)
  end

  def gold(prog) do
    vms = for _ <- 1..5, {:ok, vm} = VM.create(), do: vm

    # Map each permutation to its score
    Stream.map(@perms_b, fn perm ->
      # Initial each VM
      for {phase, vm} <- Stream.zip(perm, vms) do
        VM.run_program(vm, prog)
        VM.input(vm, phase)
      end

      # Loop over VMs until all have exited
      Stream.cycle(vms)
      |> Stream.transform({0, @nodes}, fn
        _vm, {_n, 0} ->
          {:halt, nil}

        vm, {n, c} ->
          VM.input(vm, n)

          case VM.get_output(vm) do
            {:ok, v} -> {[v], {v, c}}
            :halt -> {[], {0, c - 1}}
          end
      end)
      |> Enum.at(-1)
    end)
    |> Enum.max()
    |> tap(fn _ -> Enum.each(vms, &VM.stop/1) end)
  end
end
