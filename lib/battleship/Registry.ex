# https://m.alphasights.com/process-registry-in-elixir-a-practical-example-4500ee7c0dcc
defmodule Battleship.Registry do
  # Based on Registry docs.
  use GenServer
  # API
  def start_link do
    # We start our registry with a simple name,
    # just so we can reference it in the other functions.
    GenServer.start_link(__MODULE__, nil, name: :registry)
  end
  def whereis_name(id) do
    GenServer.call(:registry, {:whereis_name, id})
  end
  def register_name(id, pid) do
    GenServer.call(:registry, {:register_name, id, pid})
  end
  def unregister_name(id) do
    GenServer.cast(:registry, {:unregister_name, id})
  end
  def send(id, message) do
    # If we try to send a message to a process
    # that is not registered, we return a tuple in the format
    # {:badarg, {process_name, error_message}}.
    # Otherwise, we just forward the message to the pid of this
    # room.
    case whereis_name(id) do
      :undefined ->
        {:badarg, {id, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end
  # SERVER
  def init(_) do
    # We will use a simple Map to store our processes in
    # the format %{"room name" => pid}
    {:ok, Map.new}
  end
  def handle_call({:whereis_name, id}, _from, state) do
    IO.inspect(state)
    {:reply, Map.get(state, id, :undefined), state}
  end
  def handle_call({:register_name, id, pid}, _from, state) do
    # Registering a name is just a matter of putting it in our Map.
    # Our response tuple include a `:no` or `:yes` indicating if
    # the process was included or if it was already present.
    case Map.get(state, id) do
      nil ->
        {:reply, :yes, Map.put(state, id, pid)}
      _ ->
        {:reply, :no, state}
    end
  end
  def handle_cast({:unregister_name, id}, state) do
    # And unregistering is as simple as deleting an entry
    # from our Map
    {:noreply, Map.delete(state, id)}
  end
end