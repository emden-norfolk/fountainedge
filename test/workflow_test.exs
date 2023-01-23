defmodule WorkflowTest do
  use ExUnit.Case
  doctest Fountainedge.Workflow

  alias Fountainedge.{Workflow, Schema, Node, Edge, State}

  test "can initialise workflow" do
    # Initial state.
    schema = %Schema{
      nodes: [
        %Node{id: 1, label: "First", type: :initial},
        %Node{id: 2, label: "Second"},
        %Node{id: 3, label: "Third", type: :final},
      ],
      edges: [
        %Edge{id: 1, next: 2},
        %Edge{id: 2, next: 3},
        %Edge{id: 2, next: 1},
      ],
    }
    workflow = Workflow.initialize(schema)
    assert workflow.states == [%State{id: 1}]
    assert Fountainedge.out_edges(workflow) == [%Edge{id: 1, next: 2}]
  end

  test "raises exception when initialising without an initial node" do
    # Initial state.
    schema = %Schema{
      nodes: [
        %Node{id: 1, label: "First"},
        %Node{id: 2, label: "Second"},
        %Node{id: 3, label: "Third", type: :final},
      ],
      edges: [
        %Edge{id: 1, next: 2},
        %Edge{id: 2, next: 3},
        %Edge{id: 2, next: 1},
      ],
    }
    assert_raise RuntimeError, "Cannot initialise a workflow where the schema does not specify an initial node.", fn ->
      Workflow.initialize(schema)
    end
  end
end
