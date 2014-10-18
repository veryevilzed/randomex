defmodule Randomex do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [ worker(Randomex.SeedServer, []) ]
    opts = [strategy: :one_for_one, name: Randomex.Supervisor, max_restarts: 5000, max_seconds: 10]
    Supervisor.start_link(children, opts)
  end

  def get_seed, do: :gen_server.call(:randomex_seed_server, :random)

  def apply_seed do
    {a,b,c} = Randomex.get_seed
    :random.seed a,b,c
    :ok
  end

  def range(start, stop) when stop == start, do: stop
  def range(start, stop) when stop > start do
    :random.uniform(stop - (start-1)) + (start-1)
  end

  def event(percent) when percent<=0, do: false
  def event(percent) when percent>=100, do: true
  def event(percent) do
    case range(0, 99) do
      x when x < percent -> true
      _ -> false
    end
  end


end
