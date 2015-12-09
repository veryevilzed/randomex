defmodule Randomex.InnerReceiver do
	use GenServer
	@ttl 100
	@len 7
	defmacrop request do
		quote location: :keep do
			[
				fn(_,_) -> Randomex.uniform end,
				fn(a,_) -> Randomex.uniform(a) end,
				fn(a,b) -> Randomex.shuffle([a,b]) end,
				fn(a,_) -> Randomex.range(0,a) end,
				fn(a,_) -> Randomex.event(a) end,
				fn(a,b) -> Randomex.select([a,b]) end,
				fn(a,b) -> Randomex.select([{a,b},{b,a}]) end
			]
		end
	end

	def start_link, do: GenServer.start_link(__MODULE__, [])
	def init(_), do: {:ok, {@ttl,@ttl}, @ttl}
	def handle_info(:timeout, {a,b}) do
		_ = Enum.at(request, rem(a,@len)).(a,b)
		{:noreply, {b,Randomex.uniform(@ttl)}, @ttl}
	end
end
