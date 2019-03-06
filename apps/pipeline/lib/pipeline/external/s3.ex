defmodule Pipeline.External.S3 do
  @moduledoc """
  Public interface for S3 adapter
  """
  alias Pipeline.External.S3.{Adapter, DefaultAdapter}

  @behaviour Adapter

  def list_objects(bucket) do
    adapter().list_objects(bucket)
  end

  def get_object(bucket, object) do
    adapter().get_object(bucket, object)
  end

  defp adapter do
    Application.get_env(:pipeline, :s3_adapter, DefaultAdapter)
  end
end
