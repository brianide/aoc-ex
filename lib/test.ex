defmodule Foo do
  # def test do
  #   limit = 20 ** 2
  #   for i <- 0..(limit - 1) do
  #     nums = "1" |> String.pad_leading(i + 1, "0") |> String.pad_trailing(limit, "0")
  #     IO.puts("P1\n20 20\n" <> nums)
  #   end
  # end

  def test do
    limit = 20 ** 2
    for _ <- 1..(limit) do
      nums = Stream.repeatedly(fn -> :rand.uniform(14) end) |> Enum.take(40 ** 2) |> Enum.join(" ")
      IO.puts("P2\n40 40\n15\n" <> nums)
    end
  end
end
