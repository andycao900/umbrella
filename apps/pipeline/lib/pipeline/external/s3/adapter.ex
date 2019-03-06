defmodule Pipeline.External.S3.Adapter do
  @moduledoc """
  Defines callbacks for the S3 behaviour
  """

  @callback list_objects(bucket :: String.t()) :: [String.t()]

  @callback get_object(bucket :: String.t(), object_name :: String.t()) :: String.t()
end
