defmodule Pipeline.External.S3.DevAdapter do
  @moduledoc """
  Dev environment adapter for S3.
  """
  alias Pipeline.External.S3.Adapter
  @behaviour Adapter

  def list_objects("cpo") do
    ["vw.txt", "audi.txt"]
  end

  def get_object("cpo", "vw.txt") do
    File.read!("apps/pipeline/test/support/delimited/vw1.txt")
  end

  def get_object("cpo", "audi.txt") do
    File.read!("apps/pipeline/test/support/delimited/audi1.txt")
  end
end
