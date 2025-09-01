defmodule AOC.Intcode.Decoder do

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

  def parse_message(<<@resp_outp::unsigned-little-8, v::signed-little-64, rest::binary>>) do
    {:ok, {:output, v}, rest}
  end

  def parse_message(<<@resp_peek::unsigned-little-8, addr::signed-little-64, v::signed-little-64, rest::binary>>) do
    {:ok, {:peek, addr, v}, rest}
  end

  def parse_message(rest) do
    {:incomplete, rest}
  end

end

defmodule AOC.Intcode do

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
        args = ["--bin"] |> AOC.Util.prepend_if(opts[:debug], "--log")
        opts = [:binary, :exit_status, :stream, args: args]
        port = Port.open({:spawn_executable, dint_path}, opts)
        send(current, {self(), port})
        AOC.Intcode.Decoder.loop(port, current)
      end)

    receive do
      {^decoder, port} -> {:ok, port}
    end
  end

  def run_program(pid, prog) do
    prog = to_bitstring(prog)
    length = <<(byte_size(prog) |> div(8))::signed-little-64>>
    Port.command(pid, <<@code_load::unsigned-little-8>> <> length <> prog)
  end

  def stop(pid), do: Port.close(pid)

  def send_input(pid, val), do: send_control(pid, @code_inpt, [val])

  def get_output(pid, count) do
    for _ <- 1..count,
        into: [] do
          receive do
            {^pid, {:output, v}} -> v
          end
        end
  end

  def get_output(pid) do
    case get_output(pid, 1) do
      [n] -> n
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
    Port.command(port, <<code::unsigned-little-8>> <> to_bitstring(args))
  end

  defp to_bitstring(vals) do
    for s <- vals,
        n = <<s::signed-little-64>>,
        reduce: [] do acc ->
          [n | acc]
        end
    |> Enum.reverse()
    |> Enum.join()
  end

end
