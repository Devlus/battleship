defmodule BattleshipWeb.FloorChannel do
  use BattleshipWeb, :channel

  def join("floor:lobby", payload, socket) do
    # if authorized?(payload) do
    {:ok, socket}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("create", payload, socket) do
    id = Integer.to_string(DateTime.to_unix(DateTime.utc_now()))
    Battleship.ProcRegistry.start_table(id)
    user_id = Battleship.GameAgent.add_player(id)
    {:reply, {:created, %{code: id, user_id: user_id }}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (floor:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
end
