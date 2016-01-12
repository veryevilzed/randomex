defmodule Randomex.InnerReceiver do
	use GenServer
	require Logger
	@ttl 10
	@max32bit_int ((:math.pow(2, 32) |> round) - 1)
	@dieharder_len 10000000
	@dieharder_file "#{:code.priv_dir(:randomex) |> :erlang.list_to_binary}/dieharder.txt"
	@ets_tab :randomex_dieharder

	#
	#	public
	#

	def get_status do
		case :ets.lookup(@ets_tab, :status) do
			[{:status, lst = [_|_]}] -> {:error, lst}
			[{:status, :ok}] -> :ok
			[] -> :ok
		end
	end
	def set_status(some), do: (true = :ets.insert(@ets_tab, {:status, some}))

	def start_link, do: GenServer.start_link(__MODULE__, [])
	def init(_), do: {:ok, (case Application.get_env(:randomex, :dieharder) do ; nil -> nil ; true -> <<>> ; end), @ttl}
	def handle_info(:timeout, nil) do
		num = Randomex.uniform(@max32bit_int)
		{:noreply, nil, rem(@ttl,num)}
	end
	def handle_info(:timeout, bytestring) when (byte_size(bytestring) == @dieharder_len) do
		File.write!(@dieharder_file, bytestring)
		:rpc.pmap({:os,:cmd}, [], (get_dieharder_tests |> Enum.map(&('dieharder -f #{@dieharder_file} -g 201 -k 0 -D 8 -D 256 #{&1}'))))
		|> Stream.map(&to_string/1)
		|> Enum.filter(&(not(String.contains?(&1,"PASSED"))))
		|> check_dieharder_results
		{:noreply, <<>>, @ttl}
	end
	def handle_info(:timeout, bytestring) when (byte_size(bytestring) < @dieharder_len) do
		num = Randomex.uniform(@max32bit_int)
		{:noreply, <<num::32>><>bytestring, rem(@ttl,num)}
	end

	#
	#	priv
	#

	defp get_dieharder_tests do
		'dieharder -l | grep \'Good\' | grep \'Diehard\' | awk \'{print $1, $2;}\''
		|> :os.cmd
		|> to_string
		|> String.split("\n")
		|> Stream.map(&String.strip/1)
		|> Enum.filter(&(&1 != ""))
	end

	defp check_dieharder_results([]) do
		Logger.debug("PASSED all dieharder tests")
		set_status(:ok)
	end
	defp check_dieharder_results(lst = [_|_]) do
		Logger.error("FAIL dieharder tests #{Enum.join(lst," , ")}")
		set_status(lst)
	end

end
