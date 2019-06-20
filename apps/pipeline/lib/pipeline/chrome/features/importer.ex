defmodule Manifold.Chrome.Features.Importer do
  @moduledoc """
  The chrome importer will retrieve vehicle details from the Chrome Data source. For a batch of VMD.ModelYear schemas, this class will retrieve the chrome styles matching the make, model, and year, flatting all results into a single enumerable
  """

  alias Manifold.Chrome.ChromeClient
  alias Manifold.Chrome.Features.Category

  def import_chrome_data do
    fetch_vehicle_features()
    |> case do
      {:error, message} -> [{:error, message}]
      {:ok, categories} -> Stream.map(categories, &create_chrome_feature/1)
    end
  end

  defp fetch_vehicle_features do
    chrome_client().fetch_vehicle_features()
  end

  defp create_chrome_feature(
         %Category{
           group_id: _group_id,
           group_name: _group_name,
           header_id: _header_id,
           header_name: _header_name,
           category_id: _category_id,
           category_name: _category_name
         } = input
       ) do
    IO.inspect(input)
    # ChromeData.upsert_chrome_feature(%{
    #   group_id: group_id,
    #   group_name: group_name,
    #   header_id: header_id,
    #   header_name: header_name,
    #   category_id: category_id,
    #   category_name: category_name
    # })
  end

  defp chrome_client do
    Application.get_env(
      :manifold,
      :chrome_client,
      ChromeClient.HTTP
    )
  end
end
