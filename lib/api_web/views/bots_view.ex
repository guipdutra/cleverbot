defmodule CleverbotWeb.BotsView do
  use CleverbotWeb, :view

  def render("created.json", %{}) do
    %{created: true}
  end
end

