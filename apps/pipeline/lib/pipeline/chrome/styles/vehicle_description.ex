defmodule Manifold.Chrome.Styles.VehicleDescription do
  @moduledoc "A struct representing the structure of the chrome client vehicle description response"

  alias Manifold.Chrome.Styles.VehicleDescription.{
    Engine,
    ExteriorColor,
    InteriorColor,
    Style,
    Transmission
  }

  @type t :: %__MODULE__{
          engines: list(Engine.t()),
          exterior_colors: list(ExteriorColor.t()),
          interior_colors: list(InteriorColor.t()),
          styles: list(Style.t()),
          transmissions: list(Transmission.t())
        }

  defstruct engines: [],
            exterior_colors: [],
            interior_colors: [],
            styles: [],
            transmissions: []

  def filter_by_style(%Style{chrome_id: style_id}, associations) do
    Enum.filter(
      associations,
      &contains_matching_style_id?(style_id, &1)
    )
  end

  defp contains_matching_style_id?(style_id, style_association) do
    !!Enum.find(
      style_association.style_ids,
      fn association_id -> association_id == style_id end
    )
  end
end
