defmodule Manifold.Chrome.Styles.Importer do
  @moduledoc """
  The chrome importer will retrieve vehicle details from the Chrome Data source. For a batch of VMD.ModelYear schemas, this class will retrieve the chrome styles matching the make, model, and year, flatting all results into a single enumerable
  """

  # alias Engine.ChromeData
  alias Engine.ChromeData.ChromeStyle
  alias Manifold.Chrome.ChromeClient
  alias Manifold.Chrome.Styles.VehicleDescription
  alias Manifold.TaggedTuple

  @type result() ::
          {:ok, ChromeStyle.t()}
          | {:error, Ecto.Changeset.t(ChromeStyle.t())}
          | {:error, String.t()}

  @spec import_chrome_data(%{
          required(:make) => String.t(),
          required(:model) => String.t(),
          required(:year) => String.t()
        }) :: [result()]
  def import_chrome_data(model_year) do
    case fetch_vehicle_description(model_year) do
      {:error, message} -> [{:error, message}]
      {:ok, vehicle_description} -> create_chrome_records(vehicle_description)
    end
  end

  defp fetch_vehicle_description(%{make: make_name, model: model_name, year: year_name}) do
    chrome_client().fetch_vehicle_description(make_name, model_name, year_name)
  end

  defp create_chrome_records(%VehicleDescription{} = vehicle_description) do
    vehicle_description.styles
    |> Enum.map(&create_style_tree(&1, vehicle_description))
  end

  defp create_style_tree(
         %VehicleDescription.Style{
           chrome_id: _chrome_id,
           division: division,
           drivetrain: _drivetrain,
           model: model,
           model_year: model_year,
           msrp: _msrp,
           name: _name,
           trim: _trim
         } = style,
         vehicle_description
       ) do
    with {:ok, engines} <- engines_for_style(style, vehicle_description),
         {:ok, exterior_colors} <- exterior_colors_for_style(style, vehicle_description),
         {:ok, _interior_colors} <- interior_colors_for_style(style, vehicle_description),
         {:ok, _transmissions} <- transmissions_for_style(style, vehicle_description) do
      IO.inspect(engines)
      IO.inspect(exterior_colors)
      # ChromeData.upsert_chrome_style(
      #   %{
      #     chrome_engines: Enum.uniq(engines),
      #     chrome_exterior_colors: Enum.uniq(exterior_colors),
      #     chrome_id: chrome_id,
      #     chrome_interior_colors: Enum.uniq(interior_colors),
      #     division: division,
      #     drivetrain: drivetrain,
      #     model: model,
      #     model_year: model_year,
      #     msrp: msrp,
      #     name: name,
      #     chrome_transmissions: Enum.uniq(transmissions),
      #     trim: trim
      #   },
      #   [:chrome_engines, :chrome_exterior_colors, :chrome_interior_colors, :chrome_transmissions]
      # )
    else
      {:error, errors} ->
        {:error,
         [
           "Unable to create chrome style for #{model_year} #{division} #{model}"
           | errors
         ]}
    end
  end

  defp engines_for_style(style, %VehicleDescription{engines: engines}) do
    style
    |> VehicleDescription.filter_by_style(engines)
    |> Enum.map(&find_or_create_engine/1)
    |> TaggedTuple.sequence()
  end

  defp exterior_colors_for_style(style, %VehicleDescription{exterior_colors: exterior_colors}) do
    style
    |> VehicleDescription.filter_by_style(exterior_colors)
    |> Enum.map(&find_or_create_exterior_color/1)
    |> TaggedTuple.sequence()
  end

  defp interior_colors_for_style(style, %VehicleDescription{interior_colors: interior_colors}) do
    style
    |> VehicleDescription.filter_by_style(interior_colors)
    |> Enum.map(&find_or_create_interior_color/1)
    |> TaggedTuple.sequence()
  end

  defp transmissions_for_style(style, %VehicleDescription{transmissions: transmissions}) do
    style
    |> VehicleDescription.filter_by_style(transmissions)
    |> Enum.map(&find_or_create_transmission/1)
    |> TaggedTuple.sequence()
  end

  defp find_or_create_engine(%VehicleDescription.Engine{
         category: _category,
         name: _name
       }) do
    # ChromeData.find_or_create_chrome_engine(%{
    #   category: category,
    #   name: name
    # })
  end

  defp find_or_create_exterior_color(%VehicleDescription.ExteriorColor{
         code: _code,
         generic_names: _generic_names,
         name: _name,
         rgb_value: _rgb_value
       }) do
    # ChromeData.find_or_create_chrome_exterior_color(%{
    #   code: code,
    #   generic_names: generic_names,
    #   name: name,
    #   rgb_value: rgb_value
    # })
  end

  defp find_or_create_interior_color(%VehicleDescription.InteriorColor{
         code: _code,
         name: _name
       }) do
    # ChromeData.find_or_create_chrome_interior_color(%{
    #   code: code,
    #   name: name
    # })
  end

  defp find_or_create_transmission(%VehicleDescription.Transmission{
         category: _category,
         name: _name
       }) do
    # ChromeData.find_or_create_chrome_transmission(%{
    #   category: category,
    #   name: name
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
