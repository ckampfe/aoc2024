#!/usr/bin/env elixir

defmodule Common do
  def example_input do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end

  def read_and_parse_input do
    b = File.read!("inputs/day5.txt")
    # b = example_input()

    [rules, updates] = String.split(b, "\n\n")

    rules =
      rules
      |> String.split()
      |> Enum.map(fn line ->
        line
        |> String.split("|", trim: true)
        |> Enum.map(fn i ->
          {i, _} = Integer.parse(i)
          i
        end)
      end)

    updates =
      updates
      |> String.split()
      |> Enum.map(fn line ->
        line
        |> String.split(",", trim: true)
        |> Enum.map(fn i ->
          {i, _} = Integer.parse(i)
          i
        end)
      end)

    %{rules: rules, updates: updates}
  end

  def correct?(update, rules) do
    Enum.all?(update, fn {update_n, i} ->
      if afters = rules[update_n] do
        Enum.all?(afters, fn afterr ->
          i < update[afterr]
        end)
      else
        true
      end
    end)
  end

  def middle(update) do
    length = map_size(update) - 1

    i = length / 2

    Enum.find(update, fn {_k, v} ->
      v == i
    end)
  end

  def index_rules_by_happens_before(rules) do
    Enum.reduce(rules, %{}, fn [before, afterr], acc ->
      if Map.has_key?(acc, before) do
        Map.update!(acc, before, fn afters ->
          [afterr | afters]
        end)
      else
        Map.put(acc, before, [afterr])
      end
    end)
  end

  def index_updates_with_position(updates) do
    updates
    |> Enum.map(fn update ->
      update
      |> Enum.with_index()
      |> Enum.into(%{})
    end)
  end
end

defmodule Part1 do
  def main do
    %{rules: rules, updates: updates} = Common.read_and_parse_input()

    rules_with_happens_before = Common.index_rules_by_happens_before(rules)

    updates_with_position = Common.index_updates_with_position(updates)

    updates_with_position
    |> Enum.filter(fn update ->
      Common.correct?(update, rules_with_happens_before)
    end)
    |> Enum.map(fn update ->
      Common.middle(update)
    end)
    |> Enum.map(fn {v, _} -> v end)
    |> Enum.sum()
  end
end

(Part1.main() == 5208) |> IO.inspect(charlists: :lists)

defmodule Part2 do
  def main do
    %{rules: rules, updates: updates} = Common.read_and_parse_input()

    rules_with_happens_before = Common.index_rules_by_happens_before(rules)

    updates_with_position = Common.index_updates_with_position(updates)

    updates_with_position
    |> Enum.reject(fn update ->
      Common.correct?(update, rules_with_happens_before)
    end)
    |> Enum.map(fn update ->
      correct_incorrect_update(update, rules_with_happens_before)
    end)
    |> Enum.map(fn update ->
      Common.middle(update)
    end)
    |> Enum.map(fn {v, _} -> v end)
    |> Enum.sum()
  end

  def correct_incorrect_update(update, rules) do
    if Common.correct?(update, rules) do
      update
    else
      new_update = make_one_correction(update, rules)
      correct_incorrect_update(new_update, rules)
    end
  end

  # this is really ugly due to elixir not having mutation,
  # but it seems to work
  def make_one_correction(update, rules) do
    Enum.reduce_while(update, update, fn {update_n, i}, acc ->
      if afters = rules[update_n] do
        res =
          Enum.reduce_while(afters, update, fn afterr, acc2 ->
            if i < update[afterr] do
              {:cont, acc2}
            else
              # make correction
              {:halt,
               {:halt,
                acc2
                |> Map.put(update_n, Map.get(acc2, afterr))
                |> Map.put(afterr, i)}}
            end
          end)

        case res do
          {:halt, h} ->
            {:halt, h}

          c ->
            {:cont, c}
        end
      else
        {:cont, acc}
      end
    end)
  end
end

(Part2.main() == 6732) |> IO.inspect(charlists: :lists)
