defmodule Pipeline.Ingestion.CPO.AudiTest do
  use ExUnit.Case

  alias Pipeline.Ingestion.CPO.Audi

  describe "inventory_from_file" do
    test "returns correct" do
      return =
        "test/support/delimited/audi1.txt"
        |> Audi.inventory_from_file()
        |> Enum.into([])

      assert length(return) == 15
      [inventory1 | _] = return
      assert inventory1.make == "Audi"
      assert inventory1.model == "S3"
      assert inventory1.year == 2016
    end
  end
end
