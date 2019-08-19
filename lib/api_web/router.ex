defmodule CleverbotWeb.Router do
  use CleverbotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CleverbotWeb do
    pipe_through :api

    post "/bot/create", BotsController, :create_and_start
    post "/orders", BotsController, :orders
  end
end
