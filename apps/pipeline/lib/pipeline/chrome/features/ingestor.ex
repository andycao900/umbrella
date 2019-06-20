defmodule Manifold.Chrome.Features.Ingestor do
  @moduledoc """
  This module wraps chrome features import logic in an ingestor whose purpose is coordinating
  - Performing Chrome Data request
  - Streaming creation of Engine.ChromeData.ChromeStyle entries
  - Result logging and error aggregation
  """

  # alias Engine.ChromeData.ChromeFeature
  alias Manifold.Chrome.Features.Importer
  require Logger

  def run do
    Importer.import_chrome_data()
    |> log_results()
  end

  defp log_results(results) do
    results
    |> Stream.each(&log_record/1)
    |> Enum.filter(&match?({:error, _message}, &1))
    |> log_errors()
  end

  defp log_errors([]) do
    _ = Logger.info("Completed ingestion with no errors!")
  end

  defp log_errors(errors) do
    _ = Logger.error("Aggregated Error Messages for #{length(errors)} errors!")
    Enum.each(errors, &log_record/1)
  end

  defp log_record({:ok, %{category_id: category_id, category_name: category_name}}),
    do: _ = Logger.info("Successfully created chrome_feature #{category_id} #{category_name}")

  defp log_record({:error, message}), do: _ = Logger.error("#{message}")
end
