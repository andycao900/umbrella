defmodule Pipeline.Ingestion.Delimited do
  @moduledoc """
  Generic Delimited file parser
  """
  require Logger
  alias Engine.InventoryTracker

  NimbleCSV.define(NimblePipeNullParser, separator: "|", escape: "\0")
  NimbleCSV.define(NimblePipeDoubleQuoteParser, separator: "|", escape: "\"")

  @spec inventory_from_file(String.t(), String.t(), String.t(), any(), [String.t()] | nil) ::
          Enumerable.t()
  def inventory_from_file(path, separator, escape, mapper_fn, keys \\ nil) do
    path
    |> File.stream!()
    |> inventory_from_stream(separator, escape, mapper_fn, keys)
  end

  @spec inventory_from_string(String.t(), String.t(), String.t(), any(), [String.t()] | nil) ::
          Enumerable.t()
  def inventory_from_string(string, separator, escape, mapper_fn, keys \\ nil) do
    parser = parser(separator, escape)

    string
    |> parser.parse_string(headers: false)
    |> handle_parsed_stream(mapper_fn, keys)
  end

  @spec inventory_from_stream(Enumerable.t(), String.t(), String.t(), any(), [String.t()] | nil) ::
          Enumerable.t()
  def inventory_from_stream(in_stream, separator, escape, mapper_fn, keys \\ nil) do
    parser = parser(separator, escape)

    in_stream
    |> parser.parse_stream(headers: false)
    |> handle_parsed_stream(mapper_fn, keys)
  end

  defp handle_parsed_stream(parsed_stream, mapper_fn, keys) do
    {keys, drop_count} = handle_keys(keys, parsed_stream)

    parsed_stream
    |> Stream.drop(drop_count)
    |> Stream.map(&zip_keys(&1, keys))
    |> Stream.map(mapper_fn)
    |> Stream.map(&InventoryTracker.build_cpo_inventory/1)
    |> Stream.filter(fn
      {:ok, _inventory} ->
        true

      {:error, changeset} ->
        Logger.warn(fn -> "bad data: #{inspect(changeset)}" end)
        false
    end)
    |> Stream.map(fn {:ok, inventory} -> inventory end)
  end

  @spec zip_keys(list(String.t()), list(String.t())) :: map()
  defp zip_keys(line, keys) do
    keys
    |> Enum.zip(line)
    |> Enum.into(%{})
  end

  defp handle_keys(keys, stream) do
    case keys do
      nil -> {stream |> Enum.take(1) |> hd(), 1}
      keys -> {keys, 0}
    end
  end

  defp parser("|", "\0"), do: NimblePipeNullParser
  defp parser("|", "\""), do: NimblePipeDoubleQuoteParser

  defp parser(separator, escape),
    do:
      raise(
        "No parser defined in #{inspect(__MODULE__)} for #{inspect(separator)} #{inspect(escape)}"
      )
end

#   |> Stream.filter(fn {x, y} ->
#   case x do
#     {:ok, _inventory} ->
#       true
#     {:error, changeset} ->
#       Logger.warn()
#       false
#   end
# end)

# |> Stream.filter(fn {x, y} ->
#   x == :ok
# end)

# def foo1 do
#   time = 40
#   x = 1
#   if time > 30 do
#     x = x + 1
#   else
#     x = x - 1
#   end
#   inspect x # 1
# end

# def foo2 do
#   time = 40
#   x = 1
#   x = if time > 30 do
#     x + 1
#   else
#     x - 1
#   end
#   inspect x # 2
# end
