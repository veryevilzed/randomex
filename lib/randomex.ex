defmodule Randomex do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [ worker(Randomex.SeedServer, []) ]
    opts = [strategy: :one_for_one, name: Randomex.Supervisor, max_restarts: 5000, max_seconds: 10]
    Supervisor.start_link(children, opts)
  end

  def get_seed, do: :gen_server.call(:random_seed_server, :random)

  def apply_seed do
    {a,b,c} = Randomex.get_seed
    :random.seed a,b,c
    :ok
  end

end
