defmodule Manifold.Chrome.Styles.Ingestor do
  @moduledoc """
  This module wraps chrome style import logic in an ingestor whose purpose is coordinating
  - Query for make, model, years
  - Streaming Chrome Data request
  - Streaming creation of Engine.ChromeData.ChromeStyle entries
  - Result logging and error aggregation
  """

  # alias Engine.ChromeData.ChromeStyle
  # alias Engine.Repo
  # alias Engine.VMD
  # alias Manifold.Chrome.Styles.Importer
  require Logger

  @spec run(pos_integer()) :: :ok
  def run(_minimum_year) do
    # _ =
    #   minimum_year
    #   |> VMD.query_for_make_model_years()
    #   |> Repo.all()
    #   |> Stream.flat_map(&Importer.import_chrome_data/1)
    #   |> log_results()

    :ok
  end

  defp log_results(results) do
    results
    |> Stream.each(&log_record/1)
    |> Enum.filter(&match?({:error, _message}, &1))
    |> log_result
  end

  defp log_result([]), do: Logger.info("Completed ingestion with no errors!")
  defp log_result(errors), do: Logger.error("Completed with #{length(errors)} errors!")

  defp log_record(
         {:ok,
          %{
            chrome_id: chrome_id,
            division: make,
            model: model,
            model_year: year
          }}
       ),
       do:
         _ =
           Logger.info(
             "Successfully created chrome_style #{chrome_id} for #{year} #{make} #{model}"
           )

  defp log_record({:error, errors}) when is_list(errors),
    do: Enum.each(errors, &log_record/1)

  defp log_record(%Ecto.Changeset{} = changeset), do: log_record(inspect(changeset))
  defp log_record({:error, message}), do: log_record(message)
  defp log_record(error_message), do: _ = Logger.error(error_message)
end
