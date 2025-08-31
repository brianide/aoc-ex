defmodule AOC.Y2019.Day5 do
  use AOC.Solution,
    title: "Sunny with a Chance of Asteroids",
    url: "https://adventofcode.com/2019/day/5",
    scheme: {:intcode, &solve(&1, 1), &solve(&1, 5)},
    complete: false

  alias AOC.Intcode, as: VM

  def await(port) do
    receive do
      {^port, d} ->
        IO.inspect(d)
        await(port)
    end
  end

  def solve(prog, n) do
    {:ok, vm} = VM.create()
    VM.run_program(vm, prog)
    VM.send_input(vm, n);

    Stream.repeatedly(fn -> VM.get_output(vm) end)
    |> Enum.find(&(&1 != 0))
  end

end
