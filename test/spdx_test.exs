defmodule SPDXTest do
  use ExUnit.Case
  doctest SPDX

  test "greets the world" do
    assert SPDX.hello() == :world
  end
end
