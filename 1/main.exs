defmodule Trebuchet do
  @spelled_out_numbers [
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "zero"
  ]

  def getFileString(path) do
    {_, file} = File.read(path)
    file
  end

  def outerMostNumber(line) do
    graphemes = line |> String.graphemes()
    areNumbers = graphemes |> Enum.map(&graphemeIsNumber/1)

    if hd(areNumbers) do
      Enum.at(graphemes, 0)
    else
      graphemes |> tl |> Enum.join() |> outerMostNumber()
    end
  end

  def leftMostNumber(line) do
    line |> outerMostNumber()
  end

  def rightMostNumber(line) do
    line |> String.reverse() |> outerMostNumber() |> String.reverse()
  end

  def computeCalibrationValue(line) do
    leftMostNumber(line) <> rightMostNumber(line)
  end

  def convertSpelledNumbers(line) do
    substrings = generateAllSubstrings(line)

    # Because Enum.find chooses the first element that satisfies the predicate
    # we may not convert the right number in cases like "twone".
    # So we just append or prepend overlapping chars, although this changes the line
    # it doesn't change the calculation
    case Enum.find(@spelled_out_numbers, &Enum.member?(substrings, &1)) do
      "one" ->
        String.replace(line, "one", "o1e")
        |> convertSpelledNumbers()

      "two" ->
        String.replace(line, "two", "t2o")
        |> convertSpelledNumbers()

      "three" ->
        String.replace(line, "three", "t3e")
        |> convertSpelledNumbers()

      "four" ->
        String.replace(line, "four", "4")
        |> convertSpelledNumbers()

      "five" ->
        String.replace(line, "five", "5e")
        |> convertSpelledNumbers()

      "six" ->
        String.replace(line, "six", "6")
        |> convertSpelledNumbers()

      "seven" ->
        String.replace(line, "seven", "7")
        |> convertSpelledNumbers()

      "eight" ->
        String.replace(line, "eight", "e8t")
        |> convertSpelledNumbers()

      "nine" ->
        String.replace(line, "nine", "9e")
        |> convertSpelledNumbers()

      "zero" ->
        String.replace(line, "zero", "0o")
        |> convertSpelledNumbers()

      nil ->
        line
    end
  end

  def generateAllSubstrings(word) do
    Enum.flat_map(0..(String.length(word) - 1), fn start ->
      Enum.map(start..(String.length(word) - 1), fn stop ->
        String.slice(word, start..stop)
      end)
    end)
  end

  def computeAllCalibrationValues(path) do
    path
    |> getFileString()
    |> String.split("\n")
    |> List.delete_at(-1)
    |> Enum.map(&convertSpelledNumbers/1)
    |> Enum.map(&computeCalibrationValue/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def graphemeIsNumber(grapheme) do
    try do
      String.to_integer(grapheme)
      true
    rescue
      ArgumentError -> false
    end
  end
end
