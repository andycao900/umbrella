defmodule Manifold.Chrome.Features.Category do
  @moduledoc "A struct representing the structure of the chrome client feature response"

  @type t :: %__MODULE__{
          group_id: String.t(),
          group_name: String.t(),
          header_id: String.t(),
          header_name: String.t(),
          category_id: String.t(),
          category_name: String.t()
        }

  defstruct group_id: nil,
            group_name: nil,
            header_id: nil,
            header_name: nil,
            category_id: nil,
            category_name: nil
end
