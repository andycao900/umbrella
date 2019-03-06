defmodule Pipeline.External.S3.DefaultAdapter do
  @moduledoc """
  Default adapter for S3. Not yet implemented.
  """
  alias Pipeline.External.S3.Adapter
  @behaviour Adapter

  def list_objects(_bucket) do
    raise "S3 not implemented"
  end

  def get_object(_bucket, _object) do
    raise "S3 not implemented"
  end
end
