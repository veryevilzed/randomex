defmodule Randomex.InnerReceiver do
	use GenServer
	@ttl 10
	@max32bit_int ((:math.pow(2, 32) |> round) - 1)
	@dieharder_len 100000000
	@dieharder_file "./dieharder.txt"

	def start_link, do: GenServer.start_link(__MODULE__, [])
	def init(_), do: {:ok, (case Application.get_env(:randomex, :dieharder) do ; nil -> nil ; true -> {<<>>, 1} ; end), @ttl}
	def handle_info(:timeout, nil) do
		num = Randomex.uniform(@max32bit_int)
		{:noreply, nil, rem(@ttl,num)}
	end
	def handle_info(:timeout, {acc, @dieharder_len}) do
		IO.puts("exec dieharder")
		File.write!(@dieharder_file, acc)
		get_dieharder_tests
		|> Enum.each(&('dieharder -f ./dieharder.txt -g 201 -k 0 -D 256 #{&1}' |> :os.cmd |> IO.puts))
		IO.puts("end exec dieharder")
		{:noreply, {<<>>, 1}, @ttl}
	end
	def handle_info(:timeout, {acc, len}) when (len < @dieharder_len) do
		num = Randomex.uniform(@max32bit_int)
		{:noreply, {<<num::32>><>acc, len + 1}, rem(@ttl,num)}
	end

	defp get_dieharder_tests do
		'dieharder -l | grep \'Good\' | grep \'Diehard\' | awk \'{print $1, $2;}\''
		|> :os.cmd
		|> to_string
		|> String.split("\n")
		|> Stream.map(&String.strip/1)
		|> Enum.filter(&(&1 != ""))
	end

end
