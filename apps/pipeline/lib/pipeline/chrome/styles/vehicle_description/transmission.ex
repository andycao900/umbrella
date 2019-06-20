defmodule Manifold.Chrome.Styles.VehicleDescription.Transmission do
  @moduledoc "A struct representing the structure of the chrome client vehicle description response's transmission"

  @type t :: %__MODULE__{
          category: String.t(),
          name: String.t(),
          style_ids: list(String.t())
        }

  defstruct category: nil,
            name: nil,
            style_ids: []
end
