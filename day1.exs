#!/usr/bin/env elixir

defmodule Part1 do
  def main do
    rows =
      "inputs/day1_1.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.split()
        |> Enum.map(fn n ->
          {n, _} = Integer.parse(n)
          n
        end)
      end)

    left_column = Enum.map(rows, fn [left, _] -> left end)
    right_column = Enum.map(rows, fn [_, right] -> right end)

    left_column_sorted = Enum.sort(left_column)
    right_column_sorted = Enum.sort(right_column)

    Enum.zip(left_column_sorted, right_column_sorted)
    |> Enum.map(fn {left, right} -> abs(left - right) end)
    |> Enum.sum()
  end
end

defmodule Part2 do
  def main do
    rows =
      "inputs/day1_1.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.split()
        |> Enum.map(fn n ->
          {n, _} = Integer.parse(n)
          n
        end)
      end)

    left_column = Enum.map(rows, fn [left, _] -> left end)
    right_column = Enum.map(rows, fn [_, right] -> right end)

    right_counts =
      right_column
      |> Enum.group_by(fn value -> value end)
      |> Enum.map(fn {value, occurences} -> {value, Enum.count(occurences)} end)
      |> Enum.into(%{})

    left_column
    |> Enum.map(fn value ->
      value * Map.get(right_counts, value, 0)
    end)
    |> Enum.sum()
  end
end

Part2.main() |> IO.inspect()
