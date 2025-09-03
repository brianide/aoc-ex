defmodule AOC.Intcode.Helpers do
  defmacro code, do: (quote do: unsigned-little-8)
  defmacro value, do: (quote do: signed-little-64)
end

defmodule AOC.Intcode.Decoder do

  import AOC.Intcode.Helpers

  @resp_halt 0x09
  @resp_outp 0x11
  @resp_peek 0x12

  def loop(port, rec, buffer \\ <<>>) do
    parse_message(buffer)
    |> case do
      {:ok, msg, rest} ->
        send(rec, {port, msg})
        loop(port, rec, rest)

      {:incomplete, rest} ->
        receive do
          {^port, {:data, data}} -> loop(port, rec, rest <> data)
          {^port, {:exit_status, _}} -> nil
        end
    end
  end

  def parse_message(<<@resp_outp::code(), v::value(), rest::binary>>) do
    {:ok, {:output, v}, rest}
  end

  def parse_message(<<@resp_peek::code(), addr::value(), v::value(), rest::binary>>) do
    {:ok, {:peek, addr, v}, rest}
  end

  def parse_message(<<@resp_halt::code(), rest::binary>>) do
    {:ok, :halt, rest}
  end

  def parse_message(rest) do
    {:incomplete, rest}
  end

end

defmodule AOC.Intcode do

  import AOC.Intcode.Helpers

  @code_load 0x08
  @code_inpt 0x10
  @code_peek 0x12
  @code_poke 0x13

  def create(opts \\ []) do
    # Start decoder process
    current = self()
    decoder =
      spawn_link(fn ->
        dint_path = System.get_env("DINTCODE_PATH") || Path.join(File.cwd!(), "dintcode/dintcode")
        args = ["--bin"] |> AOC.Util.prepend_if(:debug in opts, "--log")
        opts = [:binary, :exit_status, :stream, args: args]
        port = Port.open({:spawn_executable, dint_path}, opts)
        send(current, {self(), port})
        AOC.Intcode.Decoder.loop(port, current)
      end)

    receive do
      {^decoder, port} -> {:ok, port}
    end
  end

  def create!(opts \\ []) do
    case create(opts) do
      {:ok, vm} -> vm
    end
  end

  defp drop_stale_messages(pid) do
    receive do
      {^pid, _} ->
        drop_stale_messages(pid)
    after 0 ->
      nil
    end
  end

  def run_program(pid, prog) do
    drop_stale_messages(pid)
    prog = to_bitstring(prog)
    length = <<(byte_size(prog) |> div(8))::signed-little-64>>
    Port.command(pid, <<@code_load::code()>> <> length <> prog)
  end

  def stop(pid), do: Port.close(pid)

  def input(pid, vals) when is_list(vals) do
    for v <- vals,
        into: <<>> do
          <<@code_inpt::code(), v::value()>>
        end
    |> then(&Port.command(pid, &1))
  end

  def input(pid, val), do: send_control(pid, @code_inpt, [val])

  def get_output!(pid, count) do
    for _ <- 1..count,
        into: [] do
          receive do
            {^pid, {:output, v}} -> v
            {^pid, :halt} -> throw("Unexpected halt")
          end
        end
  end

  def get_output!(pid) do
    case get_output!(pid, 1) do
      [n] -> n
    end
  end

  def get_output(pid) do
    receive do
      {^pid, {:output, v}} -> {:ok, v}
      {^pid, :halt} -> :halt
    end
  end

  def peek(pid, addr) do
    send_control(pid, @code_peek, [addr])
    receive do
      {^pid, {:peek, ^addr, v}} -> v
    end
  end

  def poke(pid, addr, v) do
    send_control(pid, @code_poke, [addr, v])
  end

  defp send_control(port, code, args) do
    Port.command(port, <<code::code()>> <> to_bitstring(args))
  end

  defp to_bitstring(vals) do
    for s <- vals,
        n = <<s::value()>>,
        reduce: [] do acc ->
          [n | acc]
        end
    |> Enum.reverse()
    |> Enum.join()
  end

end
