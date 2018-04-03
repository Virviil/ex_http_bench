defmodule ExHttpBench.Client do
  import ExHttpBench

  @calls 1000

  def mb(memory), do: memory / 1024 / 1024

  def test(fun) do
    memory = :erlang.memory(:total)
    :io.format("Starting ~p calls (~.3f MB)~n", [@calls, mb(memory)])
    test_loop(fun, memory, 0, 0, 0, 0)
  end

  def test_loop(fun, memory, count, run_time, clock_time, failures) do
    :erlang.statistics(:runtime)
    :erlang.statistics(:wall_clock)

    :ok = start_calls(fun, @calls)

    {success, new_failures} = collect_calls(@calls, {0, 0})
    {_, new_run_time} = :erlang.statistics(:runtime)
    {_, new_clock_time} = :erlang.statistics(:wall_clock)
    new_memory = :erlang.memory(:total)

    :io.format("~p: ~p rt, ~p ct, ~.3f MB (~.3f increase), ~p failures~n", [
      count + @calls,
      run_time + new_run_time,
      clock_time + new_clock_time,
      mb(memory),
      mb(new_memory - memory),
      failures + new_failures
    ])

    test_loop(
      fun,
      memory,
      count + @calls,
      run_time + new_run_time,
      clock_time + new_clock_time,
      failures + new_failures
    )
  end

  def start_calls(_, 0), do: :ok

  def start_calls(fun, n) do
    main_process = self()

    spawn(fn ->
      try do
        :ok = fun.()
        send(main_process, {:done, :ok})
      catch
        err ->
          IO.inspect(err)
          send(main_process, {:done, :error})
      end
    end)

    start_calls(fun, n - 1)
  end

  def collect_calls(0, acc), do: acc

  def collect_calls(n, {s, f}) do
    receive do
      {:done, :ok} ->
        collect_calls(n - 1, {s + 1, f})

      {:done, :error} ->
        collect_calls(n - 1, {s, f + 1})
    end
  end

  #### Functions
  def hackney() do
    {:ok, _} = Application.ensure_all_started(:hackney)
    :ok = test(&hackney_get/0)
    :io.format("Done~n")
    :ok
  end

  def hackney_get() do
    {:ok, 200, _headers, ref} =
      :hackney.get("https://localhost.ssl:8443/delay", [], <<>>, [
        pool: :default,
        ssl_options: [
            verify: :verify_peer,
            cacertfile: priv_file("/ssl/ca.crt")
          ]
      ])

    {:ok, _} = :hackney.body(ref)
    :ok
  end

  def httpc() do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
    :ok = test(&httpc_get/0)
    :io.format("Done~n")
    :ok
  end

  def httpc_get() do
    {:ok, {{_, 200, _}, _, _}} =
      :httpc.request(
        :get,
        {'https://localhost.ssl:8443/delay', []},
        [
          {:ssl,
           [
             {:verify, :verify_peer},
             {:cacertfile, priv_file("/ssl/ca.crt")}
           ]}
        ],
        []
      )

    :ok
  end

  def httpc_opt() do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
    :ok = test(&httpc_get/0)
    :httpc.set_options([{:max_sessions, 100}])
    :io.format("Done~n")
    :ok
  end

  def lhttpc() do
    {:ok, _} = Application.ensure_all_started(:lhttpc)
    :ok = test(&lhttpc_get/0)
    :io.format("Done~n")
    :ok
  end

  def lhttpc_get() do
    {:ok, {{200, _}, _, _}} =
      :lhttpc.request('https://localhost.ssl:8443/delay', :get, [], [], :infinity, [
        {:connect_options,
         [
           {:verify, :verify_peer},
           {:cacertfile, priv_file("/ssl/ca.crt")}
         ]}
      ])

    :ok
  end

  def ibrowse() do
    {:ok, _} = Application.ensure_all_started(:ibrowse)
    :ok = test(&ibrowse_get/0)
    :io.format("Done~n")
    :ok
  end

  def ibrowse_opt() do
    {:ok, _} = Application.ensure_all_started(:ibrowse)
    :ibrowse.set_max_pipeline_size('localhost', 8443, 1)
    :ibrowse.set_max_sessions('localhost', 8443, 300)
    :ok = test(&ibrowse_get/0)
    :io.format("Done~n")
    :ok
  end

  def ibrowse_get() do
    case :ibrowse.send_req(
           'https://localhost.ssl:8443/delay',
           [],
           :get,
           [],
           [
             ssl_options: [
               verify: :verify_peer,
               cacertfile: priv_file("/ssl/ca.crt")
             ]
           ],
           :infinity
         ) do
      {:ok, '200', _, _} ->
        :ok

      {:error, :retry_later} ->
        :timer.sleep(1)
        ibrowse_get()
    end

    :ok
  end
end
