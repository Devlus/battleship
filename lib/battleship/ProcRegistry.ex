# https://m.alphasights.com/process-registry-in-elixir-a-practical-example-4500ee7c0dcc
defmodule Battleship.ProcRegistry do
  use Supervisor
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :proc_registry)
    Battleship.Registry.start_link
  end
  def start_table(id) do
    Supervisor.start_child(:proc_registry, [id])
  end
  def init(_) do
    children = [
      worker(Battleship.GameAgent, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end