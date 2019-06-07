defmodule ExGithubPollerTest do
  use ExUnit.Case
  doctest ExGithubPoller

  test "greets the world" do
    assert ExGithubPoller.hello() == :world
  end
end
