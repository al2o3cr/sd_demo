defmodule SdDemoTest do
  use ExUnit.Case
  doctest SdDemo

  test "greets the world" do
    assert SdDemo.hello() == :world
  end
end
