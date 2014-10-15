defmodule Randomex.SeedServer do
  use GenServer
  @max_request 170
  @max32bit_int round(:math.pow 2, 32) - 1

  def start_link, do: :gen_server.start_link({ :local, :random_seed_server }, __MODULE__, [], [])

  def init([]), do: {:ok, 0}

  defp get_seed, do: {:random.uniform(@max32bit_int), :random.uniform(@max32bit_int), :random.uniform(@max32bit_int)}


  def handle_call(:random, _from, 0) do
    <<a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
    :random.seed(a, b, c)
    {:reply, get_seed, @max_request}
  end

  def handle_call(:random, _from, count), do: {:reply, get_seed, count-1}

end