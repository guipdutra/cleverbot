defmodule CleverbotWeb.BotsView do
  use CleverbotWeb, :view

  def render("created.json", %{}) do
    %{created: true}
  end

  def render("bots.json", %{bots: bots}) do
    %{bots: bots}
  end
end

