defmodule Randomex.SeedServer do
	use GenServer
	@min_request 20000
	@max32bit_int ((:math.pow(2, 32) |> round) - 1)
	@rng :sfmt

	#
	#	public
	#

	def start_link, do: :gen_server.start_link({ :local, :randomex_seed_server }, __MODULE__, [], [])
	def init([]), do: {:ok, 0}

	def handle_call({cmd, arg}, from, 0) do
		seed
		handle_call({cmd, arg}, from, (@min_request + @rng.uniform(@min_request)))
	end
	def handle_call({:uniform, nil}, _, count), do: {:reply, @rng.uniform, count-1}
	def handle_call({:uniform, max}, _, count), do: {:reply, @rng.uniform(max), count-1}
	def handle_call({:shuffle, list}, _, count) do
		{list, _} = Enum.reduce(list, {[],MapSet.new}, &shuffle_code/2)
		{
			:reply,
			:lists.keysort(1, list) |> Enum.map(fn({_,v}) -> v end),
			count-1
		}
	end

	#
	#	priv
	#

	defp seed() do
		<<a :: 32, b :: 32, c :: 32, _ :: binary >> = Enum.reduce 1..45, :crypto.rand_bytes(16), fn(_, acc)  ->  :crypto.hash(:md5, acc) end
		@rng.seed(a,b,c)
	end

	defp shuffle_code(el, {acc,set}) do
		num = @rng.uniform
		case MapSet.member?(set, num) do
			false -> {[{num,el}|acc], MapSet.put(set,num)}
			true -> shuffle_code(el, {acc,set})
		end
	end

end
