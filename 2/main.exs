defmodule Cubes do
  @configuration %{:red => 12, :green => 13, :blue => 14}
  def getFileString(path) do
    {_, file} = File.read(path)
    file
  end

  def get_draw(line) do
    Regex.replace(~r/Game\s[0-9]+:/, line, "")
    |> String.split(";")
    |> Enum.map(fn s -> Regex.replace(~r/\s/, s, "") end)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn s ->
      Enum.reduce(s, %{}, fn s, acc ->
        key = String.to_atom(String.replace(s, Regex.replace(~r/\D/, s, ""), ""))
        val = Regex.replace(~r/\D/, s, "") |> String.to_integer()

        Map.update(acc, key, val, fn p ->
          p + val
        end)
      end)
    end)
  end

  def check_draw(draw) do
    not (@configuration[:red] - Map.get(draw, :red, 0) < 0 or
           @configuration[:green] - Map.get(draw, :green, 0) < 0 or
           @configuration[:blue] - Map.get(draw, :blue, 0) < 0)
  end

  def get_draws(path) do
    path
    |> getFileString()
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.with_index()
    |> Enum.map(fn {s, index} -> {get_draw(s), index} end)
  end

  def get_lowest_cube_number(path) do
    path
    |> get_draws()
    |> Enum.map(fn {d, _index} ->
      Enum.reduce(d, %{}, fn d, acc ->
        Map.merge(acc, d, fn _, count1, count2 -> max(count1, count2) end)
      end)
    end)
  end

  def compute_set_power(set) do
    set
    |> Map.values()
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def compute_sum_of_powersets(path) do
    path
    |> get_lowest_cube_number()
    |> Enum.map(&compute_set_power/1)
    |> Enum.sum()
  end

  def check_valid_draws(path) do
    path
    |> get_draws()
    |> Enum.map(fn {d, index} ->
      is_valid =
        Enum.map(d, fn d ->
          check_draw(d)
        end)

      {not Enum.member?(is_valid, false), index}
    end)
    |> Enum.filter(fn {v, _index} -> v end)
    |> Enum.map(fn {_v, index} -> index + 1 end)
    |> Enum.sum()
  end
end
