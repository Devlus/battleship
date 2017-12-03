defmodule BattleshipWeb.TableChannel do
  use BattleshipWeb, :channel
  alias Battleship.GameAgent
  require Logger

  def join("table:"<>table_id, payload, socket) do
    Logger.info(inspect(payload))
    if authorized?(table_id, payload["user_id"]) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (table:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(table_id, user_id) do
    GameAgent.has_player(table_id, user_id)
  end
end
