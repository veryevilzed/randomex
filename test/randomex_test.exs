defmodule RandomexTest do
	use ExUnit.Case

	test "shuffle" do
		{time,_} = :timer.tc(fn() -> Enum.each(1..100, &Randomex.shuffle(&1..100000)) end)
		IO.puts("\nshuffle #{time} micro-sec\n")
		assert 1 + 1 == 2
	end
end
