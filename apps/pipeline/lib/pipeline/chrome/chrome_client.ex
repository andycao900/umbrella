defmodule Manifold.Chrome.ChromeClient do
  @moduledoc """
  A behavior describing the external integration with Chrome Data
  """

  alias Manifold.Chrome.Features.Category
  alias Manifold.Chrome.Styles.VehicleDescription

  @callback fetch_vehicle_description(make :: binary(), model :: binary(), year :: binary()) ::
              {:ok, %VehicleDescription{}} | {:error, binary()}

  @callback fetch_vehicle_features() ::
              {:ok, %Category{}} | {:error, binary()}
end
