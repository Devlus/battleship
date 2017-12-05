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
  def get_state(id) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:state})
  end
  def add_ship(id, user_id, side, shipName, cells) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:place, user_id, side, shipName, cells })
  end
  def fire(id, user_id, side, pos) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:fire, user_id, side, pos })
  end
  def reset_table(id) do
    GenServer.call({:via, Battleship.Registry, {:id, id}}, {:reset})
  end

  ## Process Implementation
  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end
  
  def handle_call({:reset}, _from, state) do
    state = Map.put(state, :left, %BoardState{})
    state = Map.put(state, :right, %BoardState{})
    {:reply, state, state}
  end

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
  def handle_call({:place, user_id, side, shipName, cells}, _from, state) do
    side = String.to_atom(side)
    shipName = String.to_atom(shipName)
    state_side = Map.get(state, side)

    #only let the owner place ships
    if(state_side.user == user_id) do
      if(is_nil(Map.get(state_side.ships, shipName))) do
        state_side = %{state_side | ships: Map.put(state_side.ships, shipName, cells)}
        if(Enum.all?(Map.values(state_side.ships), fn(x)-> !is_nil(x) end)) do
          state_side = %{state_side | donePlacing: true}
          IO.puts("done placing")
        end
      end
    end
    state = Map.put(state, side, state_side)
    {:reply, state, state}
  end
  def flattenValuesOneLevel(map)do
    vals = Map.values(map)
    Enum.reduce(vals,[],fn (x,acc) -> acc ++ x end)    
  end

  def get_opposite(sym) do
    case sym do
      :left ->
         :right
      :right ->
         :left
    end
  end

  def handle_call({:fire, user_id, side, pos}, _from, state) do
    enemy_side = String.to_atom(side)
    enemy_state_side = Map.get(state, enemy_side)
    my_side = get_opposite(enemy_side)
    my_state_side = Map.get(state, my_side)
    IO.puts("My: ")
    IO.inspect(my_state_side)
    IO.puts("Enemy: ")
    IO.inspect(enemy_state_side)

    #Make sure request is from the player
    if(my_state_side.user == user_id) do
      shipsCoords = flattenValuesOneLevel(Map.get(enemy_state_side, :ships))
      IO.puts("COORDS: ")
      IO.inspect(shipsCoords)
      IO.inspect(pos)
      if(Enum.any?(shipsCoords, fn x -> x == pos end)) do
        enemy_state_side = %{enemy_state_side | hits: [pos | enemy_state_side.hits]}
        state = Map.put(state, enemy_side, enemy_state_side)
      else
        enemy_state_side = %{enemy_state_side | misses: [pos | enemy_state_side.misses]}
        state = Map.put(state, enemy_side, enemy_state_side)
      end
    end
    {:reply, state, state}
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