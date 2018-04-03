defmodule ExHttpBench.Server do
  import ExHttpBench

  def start() do
    {:ok, _} = Application.ensure_all_started(:cowboy)

    {:ok, _server} = :cowboy.start_tls(
      :test_server,
      [
        {:port, 8443},
        {:cacertfile, priv_file("/ssl/ca.crt")},
        {:certfile, priv_file("/ssl/localhost.ssl.crt")},
        {:keyfile, priv_file("/ssl/localhost.ssl.key")}
      ],
      %{
        env: %{dispatch: routes()},
        max_keepalive: :infinity
      }
    )
  end

  defp routes do
    :cowboy_router.compile([
      {:_, [
        {"/delay", ExHttpBench.Delay, []}
      ]}
    ])
  end
end
