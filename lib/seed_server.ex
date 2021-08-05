defmodule Randomex.SeedServer do
    use GenServer
    @max_request 100000
    @rng :sfmt

    @impl true
    def init(_), do: {:ok, 0}

    def start_link(default) when is_list(default) do
        GenServer.start_link(__MODULE__, default, name: :randomex_seed_server)
    end


    defp seed() do
        <<a :: 32, b :: 32, c :: 32, _ :: binary >> = Enum.reduce 1..45, :rand.bytes(16), fn(_, acc)  ->  :crypto.hash(:md5, acc) end
        @rng.seed(a,b,c)    
    end

    @impl true
    def handle_call({:uniform, max}, from, 0) do
        seed()
        handle_call({:uniform, max}, from, @max_request)    
    end

    def handle_call({:uniform, nil}, _, count) do
        {:reply, @rng.uniform(), count-1}
    end

    def handle_call({:uniform, max}, _, count) do
        {:reply, @rng.uniform(max), count-1}
    end  

    def handle_call({:shuffle, list}, _, count) do
        ret = :lists.keysort(1, Enum.reduce(list, [], fn(x, ret)-> 
            [{:sfmt.uniform, x} | ret]
          end))
          |> Enum.map(fn({_,x})-> x end)

        {:reply, ret, count-1}
    end
end