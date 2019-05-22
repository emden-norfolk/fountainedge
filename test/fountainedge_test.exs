defmodule FountainedgeTest do
  use ExUnit.Case
  doctest Fountainedge

  test "can compute transitions" do
    nodes = [
      %Fountainedge.Node{id: 1, type: 1},
      %Fountainedge.Node{id: 2},
      %Fountainedge.Node{id: 3, type: 2},
    ]
    edges = [
      %Fountainedge.Edge{from: 1, to: 2},
      %Fountainedge.Edge{from: 2, to: 3},
    ]
    engine = %Fountainedge{nodes: nodes, edges: edges}

    IO.inspect engine
  end
end
