defmodule RandomexTest do
	use ExUnit.Case

	#test "shuffle" do
	#	{time,_} = :timer.tc(fn() -> Enum.each(1..100, &Randomex.shuffle(&1..100000)) end)
	#	IO.puts("\nshuffle #{time} micro-sec\n")
	#	assert 1 + 1 == 2
	#end

	@max32bit_int ((:math.pow(2, 32) |> round) - 1)
	@test_size 50000000

	@tag timeout: :timer.minutes(30000)
	test "all" do
		assert (n = Randomex.uniform |> IO.inspect; is_float(n) and (n < 1) and (n > 0))
		[a,b] = Enum.map(1..2, fn(_) -> Randomex.uniform(@max32bit_int) end) |> IO.inspect
		assert Enum.sort([a,b]) == Randomex.shuffle([a,b]) |> Enum.sort
		Randomex.range(0,a) |> IO.inspect
		Randomex.event(a) |> IO.inspect
		Randomex.select([a,b]) |> IO.inspect
		Randomex.select([{a,b},{b,a}]) |> IO.inspect
		Enum.each(1..1000, fn(_) ->
			case Enum.map(1..@test_size, fn(_) -> Randomex.uniform(@max32bit_int) end) |> Randomex.InnerReceiver.chisquare do
				{:ok, message} -> IO.puts(message)
				{:error, message} -> raise(message)
			end
		end)
	end

end
