#!/usr/bin/env elixir

defmodule Common do
  def sample_input do
    """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
  end

  def read_and_parse_input do
    File.read!("inputs/day4.txt")
  end

  @forwards ~r/XMAS/
  @backwards ~r/SAMX/

  def find_xmas(input) do
    f = Regex.scan(@forwards, input, return: :index)
    b = Regex.scan(@backwards, input, return: :index)
    Enum.count(f) + Enum.count(b)
  end

  def rotate_90(input) do
    lines =
      input
      |> String.split()

    split_lines =
      Enum.map(lines, fn line ->
        String.split(line, "", trim: true)
      end)

    split_lines
    |> Enum.zip()
    |> Enum.map(fn column ->
      column
      |> Tuple.to_list()
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end

  def rotate_pos_45(input) do
    lines = input |> String.split()

    number_of_lines = Enum.count(lines)

    number_of_columns =
      lines
      |> List.first()
      |> String.split("", trim: true)
      |> Enum.count()

    matrix =
      Enum.map(lines, fn line ->
        String.split(line, "", trim: true)
      end)

    first_row_coordinates =
      0..(number_of_columns - 1)
      |> Enum.map(fn x -> {x, 0} end)

    first_column_coordinates =
      0..(number_of_lines - 1)
      |> Enum.map(fn y -> {0, y} end)

    for {x, y} <- MapSet.new(first_row_coordinates ++ first_column_coordinates), reduce: "" do
      acc ->
        new_line =
          {x, y}
          |> Stream.iterate(fn {x, y} -> {x + 1, y + 1} end)
          |> Enum.reduce_while("", fn {x, y}, acc ->
            if x < 0 || y < 0 do
              {:halt, acc}
            else
              line = Enum.at(matrix, y)

              if line do
                char = Enum.at(line, x)

                if char do
                  {:cont, acc <> char}
                else
                  {:halt, acc}
                end
              else
                {:halt, acc}
              end
            end
          end)

        acc <> new_line <> "\n"
    end
  end

  def rotate_neg_45(input) do
    lines = input |> String.split()

    number_of_lines = Enum.count(lines)

    number_of_columns =
      lines
      |> List.first()
      |> String.split("", trim: true)
      |> Enum.count()

    matrix =
      Enum.map(lines, fn line ->
        String.split(line, "", trim: true)
      end)

    first_row_coordinates =
      0..(number_of_columns - 1)
      |> Enum.map(fn x -> {x, 0} end)

    last_column_coordinates =
      0..(number_of_lines - 1)
      |> Enum.map(fn y -> {number_of_columns - 1, y} end)

    for {x, y} <- MapSet.new(first_row_coordinates ++ last_column_coordinates), reduce: "" do
      acc ->
        new_line =
          {x, y}
          |> Stream.iterate(fn {x, y} -> {x - 1, y + 1} end)
          |> Enum.reduce_while("", fn {x, y}, acc ->
            if x < 0 || y < 0 do
              {:halt, acc}
            else
              line = Enum.at(matrix, y)

              if line do
                char = Enum.at(line, x)

                if char do
                  {:cont, acc <> char}
                else
                  {:halt, acc}
                end
              else
                {:halt, acc}
              end
            end
          end)

        acc <> new_line <> "\n"
    end
  end
end

defmodule Part1 do
  def main do
    # input = Common.sample_input()
    input = Common.read_and_parse_input()

    # as is is correct == 5
    as_is_count =
      input
      |> Common.find_xmas()

    # correct == 3
    rotated_90_count =
      input
      |> Common.rotate_90()
      |> Common.find_xmas()

    # correct == 6
    rotated_pos_45_count =
      input
      |> Common.rotate_pos_45()
      |> Common.find_xmas()

    # correct == 5
    rotated_neg_45_count =
      input
      |> Common.rotate_neg_45()
      |> Common.find_xmas()

    as_is_count + rotated_90_count + rotated_pos_45_count + rotated_neg_45_count
  end
end

(Part1.main() == 2639) |> IO.inspect()

defmodule Part2 do
  def main do
    input = Common.read_and_parse_input()

    lines =
      input
      |> String.split()

    matrix =
      Enum.map(lines, fn line ->
        String.split(line, "", trim: true)
      end)

    as =
      for {row, y} <- Enum.with_index(matrix), {column, x} <- Enum.with_index(row), reduce: [] do
        acc ->
          if column == "A" do
            [{x, y} | acc]
          else
            acc
          end
      end

    for {x, y} = a <- as do
      [top_left, top_right, bottom_left, bottom_right] = [
        {x - 1, y - 1},
        {x + 1, y - 1},
        {x - 1, y + 1},
        {x + 1, y + 1}
      ]

      with top_left_letter when top_left_letter in ["M", "S"] <- get_in_matrix(matrix, top_left),
           bottom_right_letter
           when bottom_right_letter in ["M", "S"] and bottom_right_letter != top_left_letter <-
             get_in_matrix(matrix, bottom_right),
           top_right_letter when top_right_letter in ["M", "S"] <-
             get_in_matrix(matrix, top_right),
           bottom_left_letter
           when bottom_left_letter in ["M", "S"] and bottom_left_letter != top_right_letter <-
             get_in_matrix(matrix, bottom_left) do
        a
      else
        _ -> nil
      end
    end
    |> Enum.filter(fn
      {_x, _y} -> true
      _ -> false
    end)
    |> Enum.count()
  end

  def get_in_matrix(matrix, {x, y}) when x >= 0 and y >= 0 do
    line = Enum.at(matrix, y)

    if line do
      Enum.at(line, x)
    end
  end

  def get_in_matrix(_, _), do: nil
end

(Part2.main() == 2005) |> IO.inspect()
