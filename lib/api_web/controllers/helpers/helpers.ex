defmodule CleverbotWeb.Controllers.Helpers do
  import Plug.Conn
  import Phoenix.Controller

  def atomize_keys(nil), do: nil

  def atomize_keys(%{__struct__: _} = struct) do
    struct
  end

  def atomize_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), atomize_keys(v)} end)
    |> Enum.into(%{})
  end

  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  def atomize_keys(not_a_map) do
    not_a_map
  end

  def render_bad_request_error(conn, changeset) do
    conn
    |> put_status(:bad_request)
    |> put_view(ApiWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end
end
