defmodule Manifold.Chrome.Styles.VehicleDescription.InteriorColor do
  @moduledoc "A struct representing the structure of the chrome client vehicle description response's interior_color"

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          style_ids: list(String.t())
        }

  defstruct code: nil,
            name: nil,
            style_ids: []
end
