#!/usr/bin/env elixir

defmodule Common do
  def example_input do
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
  end

  def read_and_parse_input do
    input =
      "inputs/day7.txt"
      |> File.read!()

    # input =
    #   example_input()

    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [test, rest] = String.split(line, ":", trim: true)

      {test, _} = Integer.parse(test)

      rest =
        rest
        |> String.trim()
        |> String.split(" ", trim: true)
        |> Enum.map(fn n ->
          {n, _} = Integer.parse(n)
          n
        end)

      %{test: test, rest: rest}
    end)
  end

  def combos(possibilities, slots) when is_list(possibilities) and is_integer(slots) do
    n = Enum.count(possibilities) ** slots
    max_digits = Integer.digits(n - 1, Enum.count(possibilities))
    max_bit_count = Enum.count(max_digits)

    Stream.map(0..(n - 1), fn i ->
      i = Integer.digits(i, Enum.count(possibilities))

      padding =
        fn -> 0 end
        |> Stream.repeatedly()
        |> Enum.take(max_bit_count - Enum.count(i))

      indexes = padding ++ i

      Enum.map(indexes, fn index ->
        Enum.at(possibilities, index)
      end)
    end)
  end
end

defmodule Part1 do
  def main do
    for %{test: test, rest: rest} <- Common.read_and_parse_input() do
      possibilities = Common.combos([:+, :*], Enum.count(rest) - 1)

      solvable? =
        Enum.reduce_while(possibilities, false, fn p, _acc ->
          ops = p

          {acc, _} =
            Enum.reduce(rest, fn
              el, acc when is_integer(acc) ->
                [op | rest_of_ops] = ops
                acc = apply(Kernel, op, [el, acc])
                {acc, rest_of_ops}

              el, {acc, [op | rest_of_ops]} ->
                acc = apply(Kernel, op, [el, acc])
                {acc, rest_of_ops}
            end)

          if acc == test do
            {:halt, true}
          else
            {:cont, false}
          end
        end)

      if solvable? do
        test
      end
    end
    |> Enum.filter(fn v -> v end)
    |> Enum.sum()
  end
end

(Part1.main() == 465_126_289_353) |> IO.inspect()

defmodule Part2 do
  def main do
    Common.read_and_parse_input()
    |> Task.async_stream(fn %{test: test, rest: rest} ->
      possibilities = Common.combos([:+, :*, :|], Enum.count(rest) - 1)

      solvable? =
        Enum.reduce_while(possibilities, false, fn p, _acc ->
          ops = p

          {acc, _} =
            Enum.reduce(rest, fn
              el, acc when is_integer(acc) ->
                [op | rest_of_ops] = ops

                case op do
                  :| ->
                    {acc, _} = Integer.parse("#{acc}#{el}")
                    {acc, rest_of_ops}

                  op ->
                    acc = apply(Kernel, op, [el, acc])
                    {acc, rest_of_ops}
                end

              el, {acc, [op | rest_of_ops]} ->
                case op do
                  :| ->
                    {acc, _} = Integer.parse("#{acc}#{el}")
                    {acc, rest_of_ops}

                  op ->
                    acc = apply(Kernel, op, [el, acc])
                    {acc, rest_of_ops}
                end
            end)

          if acc == test do
            {:halt, true}
          else
            {:cont, false}
          end
        end)

      if solvable? do
        test
      end
    end)
    |> Stream.filter(fn {:ok, v} -> v end)
    |> Stream.map(fn {:ok, v} -> v end)
    |> Enum.sum()
  end
end

(Part2.main() == 70_597_497_486_371) |> IO.inspect()
