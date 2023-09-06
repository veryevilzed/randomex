defmodule Randomex do

  def get_seed, do: :os.timestamp()
  def apply_seed, do: :rand.seed(get_seed())

  def range(start, stop) do
    Enum.random(start..stop)
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
  """
  def select(list = [{_,_}|_]) do
    max = Enum.reduce(list, 0, fn({_, weight}, acc)-> acc + weight end)-1
    rnd = Enum.random(0..max)

    {element, _} = Enum.reduce(list, {nil, rnd}, fn({element, weight}, {nil, rnd})->
        rnd = rnd - weight
        case rnd <= 0 do
            true -> {element, nil}
            false -> {nil, rnd}
        end
      (_, acc)-> acc end)

    element
  end

  def select(list = [_|_]), do: Enum.random(list)

  def shuffle(list = [_|_]), do: Enum.shuffle(list)
  def shuffle(%{first: f, last: l}), do: Enum.into(f..l, []) |> shuffle

end
