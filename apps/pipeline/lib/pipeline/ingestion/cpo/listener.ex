defmodule Pipeline.Ingestion.CPO.Listener do
  @moduledoc """
  Listens for files and runs appropriate ingestion process for each one found
  """
  use GenServer
  require Logger

  alias Pipeline.External.S3
  alias Pipeline.Ingestion.CPO.{Audi, VW}

  @period 5_000
  @bucket "cpo"

  ## Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  ## Server

  def init(count) do
    Logger.info("Starting #{__MODULE__}")
    send(self(), :check_files)
    {:ok, %{count: count}}
  end

  def handle_info(:check_files, %{count: count} = state) do
    check_for_files()
    Process.send_after(self(), :check_files, @period)
    count = count + 1
    state = %{state | count: count}
    Logger.info("New count #{count}")
    {:noreply, state}
  end

  def check_for_files do
    @bucket
    |> S3.list_objects()
    |> Enum.map(&handle_object/1)
  end

  def handle_object(object) do
    module = module_for_file(object)

    @bucket
    |> S3.get_object(object)
    |> module.inventory_from_string()
  end

  def module_for_file("vw.txt"), do: VW
  def module_for_file("audi.txt"), do: Audi
end
