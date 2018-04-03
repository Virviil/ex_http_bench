defmodule ExHttpBench.Delay do
  @behaviour :cowboy_handler

  def init(req, state) do
    :ok = :timer.sleep(10)
    {:ok, :cowboy_req.reply(200, req), state}
  end

  def terminate(_reason, _req, _state), do: :ok
end
