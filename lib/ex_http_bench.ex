defmodule ExHttpBench do
  def priv_file(path) do
    Path.join(:code.priv_dir(:ex_http_bench), path)
  end
end
