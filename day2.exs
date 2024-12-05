#!/usr/bin/env elixir

defmodule Common do
  def read_and_parse_inputs do
    "inputs/day2.txt"
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(fn n ->
        {n, _} = Integer.parse(n)
        n
      end)
    end)
  end

  def sorted_invariant(report) do
    Enum.sort(report, :asc) == report ||
      Enum.sort(report, :desc) == report
  end

  def counter_invariant(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [a, b] ->
      diff = abs(a - b)
      diff >= 1 && diff <= 3
    end)
  end
end

defmodule Part1 do
  def main do
    reports = Common.read_and_parse_inputs()

    reports
    |> Stream.filter(fn report ->
      Common.sorted_invariant(report) && Common.counter_invariant(report)
    end)
    |> Enum.count()
  end
end

(Part1.main() == 606) |> IO.inspect()

defmodule Part2 do
  def main do
    reports = Common.read_and_parse_inputs()

    reports
    |> Stream.filter(fn report ->
      if Common.sorted_invariant(report) && Common.counter_invariant(report) do
        true
      else
        len = Enum.count(report)

        Enum.reduce_while(0..(len - 1), false, fn idx, acc ->
          new = List.delete_at(report, idx)

          if Common.sorted_invariant(new) && Common.counter_invariant(new) do
            {:halt, true}
          else
            {:cont, acc}
          end
        end)
      end
    end)
    |> Enum.count()
  end
end

(Part2.main() == 644) |> IO.inspect()
