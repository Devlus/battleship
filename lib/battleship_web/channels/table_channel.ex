defmodule BattleshipWeb.TableChannel do
  use BattleshipWeb, :channel
  alias Battleship.GameAgent
  require Logger

  def join("table:"<>table_id, payload, socket) do
    if authorized?(table_id) do
      user_id = Battleship.GameAgent.add_player(table_id)
      socket = assign(socket, :user_id, user_id)
      socket = assign(socket, :table_id, table_id)
      {:ok, %{table_id: table_id, user_id: user_id }, socket}
    else
      {:error, %{reason: "table does not exist"}}
    end
  end

  def handle_in("claim", payload, socket) do
    table_id = socket.assigns[:table_id]
    user_id = socket.assigns[:user_id]
    if(payload["side"] == "left") do
      {:ok, state} = Battleship.GameAgent.claim_side(table_id, {:left, user_id})
      broadcast socket, "board", state
    else
      {:ok, state} = Battleship.GameAgent.claim_side(table_id, {:right, user_id})
      broadcast socket, "board", state
    end
    {:reply, :ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (table:lobby).
  def handle_in("need_state", payload, socket) do
    table_id = socket.assigns[:table_id]
    state = Battleship.GameAgent.get_state(table_id)
    broadcast socket, "board", state
    {:noreply, socket}
  end

  def handle_in("place", payload, socket) do
    table_id = socket.assigns[:table_id]
    user_id = socket.assigns[:user_id]
    state = Battleship.GameAgent.add_ship(table_id, user_id, payload["side"], payload["name"], payload["cells"])
    broadcast socket, "board", state
    {:noreply, socket}
  end
  def count(state, sideSym, attr) do
    Enum.count(Map.get(Map.get(state, sideSym), attr))
  end
  def bothDone(state) do
    cond do
      count(state, :left, :misses) == count(state, :right, :misses) ->
        :draw
      count(state, :left, :misses) < count(state, :right, :misses) ->
        :left
      count(state, :left, :misses) > count(state, :right, :misses) ->
        :right
    end
  end
  def checkOneDone(state) do
    cond do
      count(state, :left, :hits) == 17 ->
        #if the total shots for left to complete is less than the current number of turns of the enemy, win
        if(count(state, :left, :misses) + 17 < (count(state, :right, :misses) + count(state, :right, :hits))) do
          :left
        else
          :ongoing
        end
      count(state, :right, :hits) == 17 ->
        if(count(state, :right, :misses) + 17 < (count(state, :left, :misses) + count(state, :left, :hits))) do
          :right
        else
          :ongoing
        end
    end
  end
  def checkWinner(state) do
    cond do
      (count(state, :left, :hits) == 17 && count(state, :right, :hits) == 17) ->
        bothDone(state)
      (count(state, :left, :hits) == 17 || count(state, :right, :hits) == 17) ->
        checkOneDone(state)
      true-> :ongoing
    end
  end
  def handle_in("fire", payload, socket) do
    table_id = socket.assigns[:table_id]
    user_id = socket.assigns[:user_id]
    state = Battleship.GameAgent.fire(table_id, user_id, payload["side"], payload["pos"])
    broadcast socket, "board", state
    
    #Gets the winning side, winner is playing the opposite
    case checkWinner(state) do
      :ongoing -> nil
      :left -> broadcast socket, "game_over", %{winner: :right}
      :right -> broadcast socket, "game_over", %{winner: :left}
      :draw -> broadcast socket, "game_over", %{winner: :draw}
    end
    {:noreply, socket}
  end
  def handle_in("reset", payload, socket) do
    table_id = socket.assigns[:table_id]
    user_id = socket.assigns[:user_id]
    state = Battleship.GameAgent.reset_table(table_id)
    broadcast socket, "board", state
    {:noreply, socket}
  end


  # Remove enemy shops from state
  intercept ["board"]
  def handle_out("board", payload, socket) do
    # IO.puts("state(intercept): ")
    # IO.inspect(payload)
    user_id = socket.assigns[:user_id]
    if(Map.get(payload.left, :user) != user_id) do
      left = Map.put(payload.left, :ships, nil)
      payload = Map.put(payload, :left, left)
    end
    if(Map.get(payload.right, :user) != user_id) do
      right = Map.put(payload.right, :ships, nil)
      payload = Map.put(payload, :right, right)
    end
    push socket, "board", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(table_id) do
    :undefined != Battleship.Registry.whereis_name({:id, table_id})
  end
end
