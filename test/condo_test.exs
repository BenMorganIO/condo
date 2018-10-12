defmodule CondoTest do
  use ExUnit.Case
  doctest Condo

  test "greets the world" do
    assert Condo.hello() == :world
  end
end
