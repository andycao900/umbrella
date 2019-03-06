defmodule Pipeline.Ingestion.Delimited do
  require Logger

  NimbleCSV.define(NimblePipeParser, separator: "|", escape: "\0")

  def inventory_from_file(path, separator, escape, mapper_fn, keys \\ nil) do
    stream = parse_file(path, separator, escape)

    {keys, drop_count} = handle_keys(keys, stream)

    stream
    |> Stream.drop(drop_count)
    |> Stream.map(&zip_keys(&1, keys))
    |> Stream.map(mapper_fn)
    |> Stream.filter(fn
      {:ok, _inventory} ->
        true

      {:error, changeset} ->
        Logger.warn(fn -> "bad data: #{inspect(changeset)}" end)
        false
    end)
    |> Stream.map(fn {:ok, inventory} -> inventory end)
  end

  defp parse_file(path, separator, escape) do
    parser = parser(separator, escape)

    path
    |> File.stream!()
    |> parser.parse_stream(headers: false)
  end

  def zip_keys(line, keys) do
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

  defp parser("|", "\0"), do: NimblePipeParser
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
