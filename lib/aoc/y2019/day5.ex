defmodule AOC.Y2019.Day5 do
  use AOC.Solution,
    title: "Sunny with a Chance of Asteroids",
    url: "https://adventofcode.com/2019/day/5",
    scheme: {:intcode, &solve(&1, 1), &solve(&1, 5)},
    complete: false

  alias AOC.Intcode, as: VM

  def solve(prog, n) do
    vm = VM.start()
    VM.send_program(vm, prog)
    VM.send(vm, n)
    VM.await(vm, discard: &(&1 == 0))
  end

end
