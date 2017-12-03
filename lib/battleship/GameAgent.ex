# From Nat's Notes
defmodule Battleship.GameAgent do
  use GenServer
  alias Battleship.BoardState

  ## Public Interface

  def start_link(id) do
    state0 = %{players: [], left: %BoardState{}, right: %BoardState{} }
    GenServer.start_link(__MODULE__, state0, name: {:via, Battleship.Registry, {:id, id}})
  end
  def add_player(id)do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:add_player})
  end
  def has_player(id, player_id) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:has_player, player_id})
  end

  def claim_side(id, side) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:claim, side})
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
  def handle_call({:claim, side}, _from, state) do
    side_state = Map.get(state, elem(side,0)) #:left or :right
    if(!is_nil(side_state.user)) do
      {:reply, {:error, state}, state}
    end
    side_state = %{side_state | user: elem(side,1)}
    state = Map.put(state, elem(side,0), side_state)
    {:reply, {:ok, state}, state}
  end

  def handle_call({:add_player}, _from, state) do
    players = Map.get(state, :players)
    # start with 1 so it is a truthy value in JS
    new_id = if (is_nil(List.last(players))), do: 1, else: ( Enum.max(players) + 1)
    players = [new_id | players ]
    {:reply, new_id, Map.put(state, :players, players)}
  end

  def handle_call({:put, key, val}, _from, state) do
    {:reply, :ok, Map.put(state, key, val)}
  end
end