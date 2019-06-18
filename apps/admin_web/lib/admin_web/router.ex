defmodule AdminWeb.Router do
  use AdminWeb, :router

  require Ueberauth

  alias Authentication.Plug.{BasicAuthCars, FetchUserFromSession, RequireAuthentication}

  pipeline :unauthenticated_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BasicAuthCars, config_root: :admin_web
    plug FetchUserFromSession, user_resolver: &Engine.Accounts.get_user/1
  end

  pipeline :browser do
    plug :unauthenticated_browser
    plug RequireAuthentication, routes_helper: AdminWeb.Router.Helpers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AdminWeb do
    pipe_through :unauthenticated_browser

    get "/", PageController, :index
  end

  scope "/login", AdminWeb do
    pipe_through :unauthenticated_browser

    get "/", AuthController, :request
    get "/callback", AuthController, :callback
    post "/callback", AuthController, :callback
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
