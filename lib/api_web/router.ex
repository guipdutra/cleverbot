defmodule CleverbotWeb.Router do
  use CleverbotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CleverbotWeb do
    pipe_through :api
  end
end
