defmodule Randomex do
  use Application

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def start(_type, _args) do
    children = [
      {Randomex.SeedServer, []},
    ]
    opts = [strategy: :one_for_one, name: Randomex.Supervisor, max_restarts: 5000, max_seconds: 10]
    Supervisor.start_link(children, opts)
  end

  @doc """
  DEPRICATED
  """
  def apply_seed, do: :ok

  def uniform(), do: GenServer.call(:randomex_seed_server, {:uniform, nil})
  def uniform(max), do: GenServer.call(:randomex_seed_server, {:uniform, max})
  def shuffle(list), do: GenServer.call(:randomex_seed_server, {:shuffle, list})  

  def range(start, stop) when stop == start, do: stop
  def range(start, stop) when stop > start do
    uniform(stop - (start-1)) + (start-1)
  end

  def event(percent) when percent <= 0, do: false
  def event(percent) when percent >= 100, do: true
  def event(percent) do
    case range(0, 99) do
      x when x < percent -> true
      _ -> false
    end
  end

  @doc """
    Selects random weighted element
    > Enum.reduce 1..32000, {0,0,0}, fn(_, {a,b,c})->
        case Randomex.select([{1,5}, {2,1}, {3,10}]) do
          1 -> {a+1,b,c}
          2 -> {a,b+1,c}
          3 -> {a,b,c+1}
        end
      end

    {19867, 2099, 10034}

    Selects random element
    > Enum.reduce 1..32000, {0,0,0}, fn(_, {a,b,c})->
        case Randomex.select([1,2,3]) do
          1 -> {a+1,b,c}
          2 -> {a,b+1,c}
          3 -> {a,b,c+1}
        end
      end

    {10560, 10687, 10753}
  """
  def select(list = [{_,_}|_]) do 
    rnd = Enum.reduce(list, 0, fn({_, weight}, acc)-> acc + weight end)
        |> uniform

    {element, _} = Enum.reduce(list, {nil, rnd}, fn({element, weight}, {nil, rnd})->
        rnd = rnd - weight
        case rnd <= 0 do
            true -> {element, nil}
            false -> {nil, rnd}
        end
      (_, acc)-> acc end)

    element
  end

  def select(list = [_|_]) do 
    Enum.at(list, uniform(length(list)) - 1)
  end

end
