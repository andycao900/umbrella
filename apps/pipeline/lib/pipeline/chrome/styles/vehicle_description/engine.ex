defmodule Manifold.Chrome.Styles.VehicleDescription.Engine do
  @moduledoc "A struct representing the structure of the chrome client vehicle description response's engine"

  @type t :: %__MODULE__{
          category: String.t(),
          name: String.t(),
          style_ids: list(String.t())
        }

  defstruct category: nil,
            name: nil,
            style_ids: []
end
