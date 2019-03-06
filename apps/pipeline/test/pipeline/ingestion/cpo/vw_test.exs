defmodule Pipeline.Ingestion.CPO.VWTest do
  use ExUnit.Case

  alias Pipeline.Ingestion.CPO.VW

  describe "inventory_from_file" do
    test "returns correct" do
      return =
        "test/support/delimited/vw1.txt"
        |> VW.inventory_from_file()
        |> Enum.into([])

      assert length(return) == 15
      [inventory1 | _] = return
      assert inventory1.make == "Volkswagen"
      assert inventory1.model == "Jetta"
      assert inventory1.year == 2017
    end
  end
end
