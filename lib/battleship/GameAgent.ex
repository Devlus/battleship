# From Nat's Notes
defmodule Battleship.GameAgent do
  use GenServer

  ## Public Interface

  def start_link(id) do
    state0 = %{player1: nil, player2: nil, players: []}
    GenServer.start_link(__MODULE__, state0, name: {:via, Battleship.Registry, {:id, id}})
  end
  def add_player(id)do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:add_player})
  end
  def has_player(id, player_id) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:has_player, player_id})
  end

  def get(id, key) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:get, key})
  end

  def put(id, key, val) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:put, key, val})
  end

  ## Process Implementation

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end
  def handle_call({:has_player, id}, _from, state) do
    players = Map.get(state, :players)
    {:reply, Enum.any?(players,fn x -> x == id end), state}
  end

  def handle_call({:add_player}, _from, state) do
    players = Map.get(state, :players)
    new_id = if (is_nil(List.last(players))), do: 0, else: ( Enum.max(players) + 1)
    players = [new_id | players ]
    {:reply, new_id, Map.put(state, :players, players)}
  end

  def handle_call({:put, key, val}, _from, state) do
    {:reply, :ok, Map.put(state, key, val)}
  end
end