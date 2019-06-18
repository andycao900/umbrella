defmodule AdminWeb.Plug.ParentEntity do
  @moduledoc """
  Populates entities in Conn.private based on presence of entity_id in params.
  """
  # alias Engine.VMD
  # import Plug.Conn, only: [assign: 3]
  # alias Plug.Conn

  # def init(_), do: :ok

  # def call(%Conn{} = conn, _) do
  #   conn
  #   |> populate_make()
  #   |> populate_model()
  #   |> populate_year()
  #   |> populate_model_year()
  #   |> populate_drivetrain()
  # end

  # def populate_make(%Conn{params: %{"make_id" => make_slug}} = conn),
  #   do: assign(conn, :make, VMD.get_make_by_slug!(make_slug))

  # def populate_make(conn), do: conn

  # def populate_model(%Conn{assigns: %{make: make}, params: %{"model_id" => model_slug}} = conn),
  #   do: assign(conn, :model, VMD.get_model_by_slug!(make, model_slug))

  # def populate_model(conn), do: conn

  # @doc """
  # Not a typo. The slug we use for model_year_id is actually the year slug
  # """
  # def populate_year(%Conn{params: %{"model_year_id" => year_slug}} = conn),
  #   do: assign(conn, :year, VMD.get_year_by_slug!(year_slug))

  # def populate_year(conn), do: conn

  # def populate_model_year(%Conn{assigns: %{model: model, year: year}} = conn),
  #   do: assign(conn, :model_year, VMD.get_model_year_by_model_and_year(model, year))

  # def populate_model_year(conn), do: conn

  # def populate_drivetrain(%Conn{params: %{"drivetrain_id" => drivetrain_slug}} = conn),
  #   do: assign(conn, :drivetrain, VMD.get_drivetrain_by_slug!(drivetrain_slug))

  # def populate_drivetrain(conn), do: conn
end
