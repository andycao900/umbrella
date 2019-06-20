defmodule Manifold.TaggedTuple do
  @moduledoc """
  Utility functions for working with tagged tuples
  """

  def sequence([]), do: {:ok, []}
  def sequence([h | t]), do: sequence(h, sequence(t))
  defp sequence({:ok, value}, {:ok, values}), do: {:ok, [value | values]}
  defp sequence({:ok, _value}, {:error, values}), do: {:error, values}
  defp sequence({:error, value}, {:ok, _values}), do: {:error, [value]}
  defp sequence({:error, value}, {:error, values}), do: {:error, [value | values]}
end
