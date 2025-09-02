defmodule AOC.Y2019.Day2 do
  use AOC.Solution,
    title: "1202 Program Alarm",
    url: "https://adventofcode.com/2019/day/2",
    scheme: {:intcode, &silver/1, &gold/1},
    complete: true

  alias AOC.Intcode, as: VM

  def patch_program(prog, noun, verb) do
    for {n, i} <- Stream.with_index(prog) do
      case i do
        1 -> noun
        2 -> verb
        _ -> n
      end
    end
  end

  def silver(prog) do
    {:ok, vm} = VM.create()
    VM.run_program(vm, patch_program(prog, 12, 2))
    VM.peek(vm, 0)
    |> tap(fn _ -> VM.stop(vm) end)
  end

  def gold(prog) do
    {:ok, vm} = VM.create()

    for(noun <- 0..99, verb <- 0..99, do: {noun, verb})
    |> Enum.find(fn {noun, verb} ->
      VM.run_program(vm, patch_program(prog, noun, verb))
      VM.peek(vm, 0) == 19690720
    end)
    |> case do
      {noun, verb} ->
        VM.stop(vm)
        100 * noun + verb
    end
  end

end
