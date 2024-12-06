# aoc-ex
Advent of Code solutions in Elixir

Run solutions with `mix run -e "AOC.Main.main()" -- <year> <day> <part> <input-root>`, or build with `mix escript.build` and run with `./aoc-ex <year> <day> <part> <input-root>`.

The `part` argument should be `silver`, `gold`, or `both`, or just the first letter of the respective word.

Input directories should have subfolders for years, containing files for each day named like `day1.txt`, `day2.txt`, etc.
