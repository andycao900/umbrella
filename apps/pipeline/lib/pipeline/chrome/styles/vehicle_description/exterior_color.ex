defmodule Manifold.Chrome.Styles.VehicleDescription.ExteriorColor do
  @moduledoc "A struct representing the structure of the chrome client vehicle description response's exterior_color"

  @type t :: %__MODULE__{
          code: String.t(),
          generic_names: list(String.t()),
          name: String.t(),
          rgb_value: String.t(),
          style_ids: list(String.t())
        }

  defstruct code: nil,
            generic_names: [],
            name: nil,
            rgb_value: nil,
            style_ids: []
end
