defmodule Manifold.Chrome.Styles.VehicleDescription.Style do
  @moduledoc "A struct representing the structure of the chrome client vehicle description response's style"

  @type t :: %__MODULE__{
          chrome_id: String.t(),
          division: String.t(),
          drivetrain: String.t(),
          model: String.t(),
          model_year: String.t(),
          msrp: String.t(),
          name: String.t(),
          trim: String.t()
        }

  defstruct chrome_id: nil,
            division: nil,
            drivetrain: nil,
            model: nil,
            model_year: nil,
            msrp: nil,
            name: nil,
            trim: nil
end
