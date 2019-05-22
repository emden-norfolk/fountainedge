defmodule FountainedgeTest do
  use ExUnit.Case
  doctest Fountainedge

  alias Fountainedge, as: Workflow
  alias Fountainedge.Node
  alias Fountainedge.Edge
  alias Fountainedge.State

  test "can compute transitions" do
    workflow = %Workflow{
      nodes: [
        %Node{id: 1, type: 1},
        %Node{id: 2},
        %Node{id: 3, type: 2},
      ],
      edges: [
        %Edge{id: 1, next: 2},
        %Edge{id: 2, next: 3},
      ],
      states: [
        %State{id: 1},
      ],
    }

    workflow = Workflow.transition(workflow, %Edge{id: 1, next: 2})
    workflow = Workflow.transition(workflow, %Edge{id: 2, next: 3})
    IO.inspect workflow
  end
end
