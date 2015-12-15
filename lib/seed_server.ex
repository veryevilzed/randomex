defmodule Randomex.SeedServer do
  use GenServer
  @max_request 1700
  @max32bit_int round(:math.pow 2, 32) - 1
  @rng :sfmt

  def start_link, do: :gen_server.start_link({ :local, :randomex_seed_server }, __MODULE__, [], [])

  def init([]), do: {:ok, 0}


  defp seed() do
    <<a :: 32, b :: 32, c :: 32, _ :: binary >> = Enum.reduce 1..45, :crypto.rand_bytes(16), fn(_, acc)  ->  :crypto.md5(acc) end
    @rng.seed(a,b,c)
  end

  def handle_call({:uniform, max}, from, 0) do
    seed
    handle_call({:uniform, max}, from, @max_request)
  end

  def handle_call({:uniform, nil}, _, count) do
    {:reply, @rng.uniform, count-1}
  end

  def handle_call({:uniform, max}, _, count) do
    {:reply, @rng.uniform(max), count-1}
  end

	def handle_call({:shuffle, list}, _, count) do
		{
			:reply,
			:lists.keysort(1, Enum.map(list,&({:sfmt.uniform,&1})))
			|> Enum.map(fn({_,v}) -> v end),
			count-1
		}
	end

end
