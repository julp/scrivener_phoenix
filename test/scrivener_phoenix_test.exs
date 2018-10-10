defmodule Scrivener.PhoenixTest do
  use ExUnit.Case
  doctest Scrivener.Phoenix

  test "greets the world" do
    assert Scrivener.Phoenix.hello() == :world
  end
end
