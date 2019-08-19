defmodule CleverbotWeb.BotsView do
  use CleverbotWeb, :view

  def render("created.json", %{}) do
    %{created: true}
  end

  def render("orders.json", %{orders: orders}) do
    %{orders: orders}
  end
end

