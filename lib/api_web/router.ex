defmodule CleverbotWeb.Router do
  use CleverbotWeb, :router

  pipeline :api do
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
  end

  scope "/api", CleverbotWeb do
    pipe_through :api

    post "/bot/create", BotsController, :create_and_start
    post "/bots", BotsController, :bots
  end
end
