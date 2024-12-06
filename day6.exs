#!/usr/bin/env elixir

defmodule Common do
  def example_input do
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """
  end

  def read_and_parse_input do
    input =
      "inputs/day6.txt"
      |> File.read!()

    # input = example_input()

    lines =
      input
      |> String.split()

    line_length = lines |> List.first() |> String.length()
    number_of_lines = Enum.count(lines)

    xy_to_position = fn {x, y} ->
      if x < line_length && x >= 0 && y < number_of_lines && y >= 0 do
        line_length * y + x
      else
        nil
      end
    end

    grid = Enum.join(lines)

    start =
      input
      |> String.split()
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        result =
          Regex.run(~r/\^/, line, return: :index) || []

        result
        |> Enum.map(fn {x, _} ->
          {x, y}
        end)
      end)

    %{
      start: start,
      grid: grid,
      xy_to_position: xy_to_position
    }
  end

  def next_direction(direction) do
    case direction do
      :up -> :right
      :right -> :down
      :down -> :left
      :left -> :up
    end
  end

  def next_position({x, y}, direction) do
    case direction do
      :up ->
        {x, y - 1}

      :right ->
        {x + 1, y}

      :down ->
        {x, y + 1}

      :left ->
        {x - 1, y}
    end
  end
end

defmodule Part1 do
  def main do
    %{grid: grid, start: [start], xy_to_position: xy_to_position} =
      Common.read_and_parse_input()

    walk(grid, start, :up, xy_to_position, MapSet.new([start])) |> Enum.count()
  end

  def walk(grid, current_position, direction, xy_to_position, visited_positions) do
    visited_positions = MapSet.put(visited_positions, current_position)

    next_position = Common.next_position(current_position, direction)

    case xy_to_position.(next_position) do
      prefix_size when is_integer(prefix_size) ->
        <<_prefix::binary-size(prefix_size), next_value::binary-size(1), _rest::binary>> = grid

        case next_value do
          "#" ->
            walk(
              grid,
              current_position,
              Common.next_direction(direction),
              xy_to_position,
              visited_positions
            )

          ok when ok in [".", "^"] ->
            walk(
              grid,
              next_position,
              direction,
              xy_to_position,
              visited_positions
            )
        end

      nil ->
        visited_positions
    end
  end
end

(Part1.main() == 5095) |> IO.inspect()

defmodule Part2 do
  def main do
    %{grid: grid, start: [start], xy_to_position: xy_to_position} =
      Common.read_and_parse_input()

    0..(String.length(grid) - 1)
    |> Task.async_stream(fn i ->
      if String.at(grid, i) == "#" do
        nil
      else
        <<
          prefix::binary-size(i),
          _value_to_replace_with_obstruction::binary-size(1),
          rest::binary
        >> = grid

        test_grid = <<prefix::binary, "#", rest::binary>>

        if walk(test_grid, start, :up, xy_to_position, MapSet.new()) == :loop_detected do
          true
        end
      end
    end)
    |> Enum.filter(fn {:ok, v} -> v end)
    |> Enum.count()
  end

  def walk(
        grid,
        current_position,
        direction,
        xy_to_position,
        visited_obstructions
      ) do
    next_position = Common.next_position(current_position, direction)

    case xy_to_position.(next_position) do
      prefix_size when is_integer(prefix_size) ->
        <<_prefix::binary-size(prefix_size), next_value::binary-size(1), _rest::binary>> = grid

        case next_value do
          "#" ->
            if MapSet.member?(visited_obstructions, {next_position, direction}) do
              :loop_detected
            else
              walk(
                grid,
                current_position,
                Common.next_direction(direction),
                xy_to_position,
                MapSet.put(visited_obstructions, {next_position, direction})
              )
            end

          ok when ok in [".", "^"] ->
            walk(
              grid,
              next_position,
              direction,
              xy_to_position,
              visited_obstructions
            )
        end

      nil ->
        nil
    end
  end
end

(Part2.main() == 1933) |> IO.inspect()
