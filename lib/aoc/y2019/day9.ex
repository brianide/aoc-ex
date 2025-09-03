defmodule AOC.Y2019.Day9 do
  use AOC.Solution,
    title: "Sensor Boost",
    url: "https://adventofcode.com/2019/day/9",
    scheme: {:intcode, &solve(&1, 1), &solve(&1, 2)},
    complete: true

  alias AOC.Intcode, as: VM

  def solve(prog, n) do
    {:ok, vm} = VM.create()
    VM.run_program(vm, prog)
    VM.input(vm, n)
    VM.get_output!(vm)
  end

end
