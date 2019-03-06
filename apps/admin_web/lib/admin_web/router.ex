defmodule AdminWeb.Router do
  use AdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AdminWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/sleep", PageController, :sleep
  end

  scope "/vmd", AdminWeb do
    pipe_through :browser

    resources "/vehicle_definitions", VehicleDefinitionController
    resources "/vehicles", VehicleController
  end

  scope "/inventory_tracker", AdminWeb do
    pipe_through :browser

    resources "/inventories", InventoryController
  end

  # Other scopes may use custom stacks.
  # scope "/api", AdminWeb do
  #   pipe_through :api
  # end
end
