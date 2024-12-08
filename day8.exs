defmodule Common do
  def example_input do
    """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """
  end

  def read_and_parse_input do
    input =
      "inputs/day8.txt"
      |> File.read!()

    # input =
    #   example_input()

    lines =
      input
      |> String.split()

    number_of_columns = lines |> List.first() |> String.length()
    number_of_rows = Enum.count(lines)
    grid = Enum.join(lines)

    xy_to_i = fn {x, y} ->
      if x < number_of_columns && x >= 0 && y < number_of_rows && y >= 0 do
        number_of_columns * y + x
      end
    end

    grid_length = String.length(grid)

    i_to_xy = fn i ->
      if i >= 0 and i <= grid_length do
        {rem(i, number_of_columns), div(i - rem(i, number_of_columns), number_of_columns)}
      end
    end

    %{grid: grid, xy_to_i: xy_to_i, i_to_xy: i_to_xy}
  end

  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def vectors_for({x1, y1}, {x2, y2}) do
    {
      {x1 - x2, y1 - y2},
      {x2 - x1, y2 - y1}
    }
  end

  def unique_pairings(xys) do
    for a <- xys, b <- xys, a != b, uniq: true do
      # this sorting ensures the points are ordered ascending,
      # which is important for the subsequent vectors and addition steps
      [a, b] = Enum.sort([a, b])
      {a, b}
    end
  end

  def antennas_and_unique_pairings(antenna_indexes, grid, i_to_xy) do
    for [{i, _}] <- antenna_indexes do
      <<_prefix::binary-size(i), antenna::binary-size(1), _rest::binary>> = grid
      antenna_xy = i_to_xy.(i)
      {antenna, antenna_xy}
    end
    |> Enum.group_by(
      fn {antenna, _} -> antenna end,
      fn {_, xy} -> xy end
    )
    |> Enum.map(fn {antenna_type, locations} ->
      {antenna_type, Common.unique_pairings(locations)}
    end)
    |> Enum.into(%{})
  end

  def antenna_indexes(grid) do
    Regex.scan(~r/[A-Za-z0-9]/, grid, return: :index)
  end
end

defmodule Part1 do
  def main do
    %{grid: grid, xy_to_i: xy_to_i, i_to_xy: i_to_xy} = Common.read_and_parse_input()

    antenna_indexes = Common.antenna_indexes(grid)

    antennas_and_unique_pairings =
      Common.antennas_and_unique_pairings(antenna_indexes, grid, i_to_xy)

    Enum.reduce(
      antennas_and_unique_pairings,
      MapSet.new(),
      fn {_antenna, unique_pairings}, acc ->
        Enum.reduce(unique_pairings, acc, fn {a, b}, acc2 ->
          MapSet.union(acc2, antinodes(a, b, xy_to_i))
        end)
      end
    )
    |> Enum.count()
  end

  def antinodes(a, b, xy_to_i) do
    {v1, v2} = Common.vectors_for(a, b)

    [Common.add(a, v1), Common.add(b, v2)]
    |> Enum.filter(fn xy -> xy_to_i.(xy) end)
    |> Enum.into(MapSet.new())
  end
end

(Part1.main() == 249) |> IO.inspect()

defmodule Part2 do
  def main do
    %{grid: grid, xy_to_i: xy_to_i, i_to_xy: i_to_xy} = Common.read_and_parse_input()

    antenna_indexes = Common.antenna_indexes(grid)

    antennas_and_unique_pairings =
      Common.antennas_and_unique_pairings(antenna_indexes, grid, i_to_xy)

    Enum.reduce(
      antennas_and_unique_pairings,
      MapSet.new(),
      fn {_antenna, unique_pairings}, acc ->
        Enum.reduce(unique_pairings, acc, fn {a, b}, acc2 ->
          MapSet.union(acc2, antinodes(a, b, xy_to_i))
        end)
      end
    )
    |> Enum.count()
  end

  def antinodes(a, b, xy_to_i) do
    {v1, v2} = Common.vectors_for(a, b)

    a_antinodes =
      a
      |> Stream.iterate(fn xy ->
        Common.add(xy, v1)
      end)
      |> Enum.take_while(fn xy ->
        xy_to_i.(xy)
      end)
      |> Enum.into(MapSet.new())

    b_antinodes =
      b
      |> Stream.iterate(fn xy ->
        Common.add(xy, v2)
      end)
      |> Enum.take_while(fn xy ->
        xy_to_i.(xy)
      end)
      |> Enum.into(MapSet.new())

    MapSet.union(a_antinodes, b_antinodes)
  end
end

(Part2.main() == 905) |> IO.inspect()
