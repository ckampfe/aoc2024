#!/usr/bin/env elixir

defmodule Common do
  def read_and_parse_inputs do
    "inputs/day3.txt"
    |> File.read!()
    |> String.trim()
  end

  def mul_expr do
    ~r/mul\((?<left>\d+),(?<right>\d+)\)/
  end

  def multiply_and_sum_matches(matches) do
    Enum.reduce(matches, 0, fn [_, left, right], acc ->
      {left, _} = Integer.parse(left)
      {right, _} = Integer.parse(right)
      left * right + acc
    end)
  end
end

defmodule Part1 do
  def main do
    s = Common.read_and_parse_inputs()
    matches = Regex.scan(Common.mul_expr(), s)
    Common.multiply_and_sum_matches(matches)
  end
end

(Part1.main() == 174_960_292) |> IO.inspect()

defmodule Part2 do
  def main do
    s = Common.read_and_parse_inputs()
    enabled = parse(s)
    matches = Regex.scan(Common.mul_expr(), enabled)
    Common.multiply_and_sum_matches(matches)
  end

  def parse(s) do
    parse(s, :enabled, <<>>)
  end

  def parse(<<>>, _state, acc), do: acc

  def parse(<<"do()", rest::binary>>, _state, acc) do
    parse(rest, :enabled, acc)
  end

  def parse(<<"don't()", rest::binary>>, _state, acc) do
    parse(rest, :disabled, acc)
  end

  def parse(<<c::binary-size(1), rest::binary>>, :enabled = state, acc) do
    parse(rest, state, acc <> c)
  end

  def parse(<<_c::binary-size(1), rest::binary>>, :disabled = state, acc) do
    parse(rest, state, acc)
  end
end

(Part2.main() == 56_275_602) |> IO.inspect()
