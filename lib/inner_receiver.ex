defmodule Randomex.InnerReceiver do
	use GenServer
	require Logger
	@ttl 300
	@max32bit_int ((:math.pow(2, 32) |> round) - 1)
	@test_size 50000000
	@ets_tab :randomex_monitor
	@newstate %{lst: [], counter: 0}
	# from 0.01
	@chitable_left %{
		7 => 1.2390,
		8 => 1.6465,
		9 => 2.0879,
		10 => 2.5582,
		11 => 3.0535,
		12 => 3.5706,
		13 => 4.1069,
		14 => 4.6604,
		15 => 5.2293
	}
	# to 0.975
	@chitable_right %{
		7 => 16.0128,
		8 => 17.5345,
		9 => 19.0228,
		10 => 20.4832,
		11 => 21.9200,
		12 => 23.3367,
		13 => 24.7356,
		14 => 26.1189,
		15 => 27.4884
	}

	#
	#	public
	#

	def get_status do
		case :ets.lookup(@ets_tab, :status) do
			[{:status, some}] -> some
			[] -> nil
		end
	end
	def set_status(some) do
		true = :ets.insert(@ets_tab, {:status, some})
		some
	end

	#
	#	inner
	#

	def start_link, do: GenServer.start_link(__MODULE__, [])
	def init(_), do: {:ok, (case Application.get_env(:randomex, :monitoring) do ; nil -> nil ; false -> nil ; true -> @newstate ; end), @ttl}
	def handle_info(:timeout, nil) do
		num = Randomex.uniform(@max32bit_int)
		{:noreply, nil, rem(num,@ttl)}
	end
	def handle_info(:timeout, %{lst: lst, counter: counter}) when (counter == @test_size) do
		case chisquare(lst) do
			{:ok, _} -> :ok
			{:error, message} -> IO.puts(message)
		end
		{:noreply, @newstate, @ttl}
	end
	def handle_info(:timeout, state = %{counter: counter}) when (counter < @test_size) do
		num = Randomex.uniform(@max32bit_int)
		{
			:noreply,
			Map.update!(state, :lst, &([num|&1])) |> Map.update!(:counter, &(&1+1)),
			rem(num,@ttl)
		}
	end

	#
	#	monitoring funcs
	#

	def chisquare(lst) do
		samplenum = Randomex.range(8,16)
		limit_left = Map.get(@chitable_left, samplenum - 1)
		limit_right = Map.get(@chitable_right, samplenum - 1)
		case chisquare_process(samplenum, lst) do
			%{lst: [], chivalue: x} when ((x >= limit_left) and (x <= limit_right)) ->
				set_status({:ok, "samples #{samplenum}, chi-square test OK, got #{x} value"})
			%{lst: [], chivalue: x} ->
				set_status({:error, "samples #{samplenum}, chi-square test FAILED, got #{x} value"})
		end
	end
	defp chisquare_process(samplenum, lst) do
		base_sample = @max32bit_int / samplenum
		Enum.reduce(1..samplenum, %{lst: lst, chivalue: 0}, fn(this_sample, acc = %{lst: lst}) ->
			this_begin = (base_sample * (this_sample - 1)) |> round
			this_end = (base_sample * this_sample) |> round
			this_prob = (this_end - this_begin) / @max32bit_int
			%{lst: lst, counter: counter} = get_entries(lst, this_begin, this_end)
			Map.put(acc, :lst, lst)
			|> Map.update!(:chivalue, &(&1 + calchi(counter, this_prob)))
		end)
	end
	defp get_entries(lst, this_begin, this_end) do
		Enum.reduce(lst, %{lst: [], counter: 0}, fn
			el, acc when (el > this_begin) and (el <= this_end) -> Map.update!(acc, :counter, &(&1+1))
			el, acc -> Map.update!(acc, :lst, &([el|&1]))
		end)
	end
	defp calchi(counter, this_prob) do
		theor = this_prob * @test_size
		diff = counter - theor
		(diff * diff) / theor
	end

end
