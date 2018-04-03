defmodule ExHttpBenchTest do
  use ExUnit.Case
  doctest ExHttpBench

  test "greets the world" do
    assert ExHttpBench.hello() == :world
  end
end
