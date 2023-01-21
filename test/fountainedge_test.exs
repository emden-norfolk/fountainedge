defmodule FountainedgeTest do
  use ExUnit.Case
  doctest Fountainedge

  alias Fountainedge, as: Workflow
  alias Fountainedge.{Schema, Node, Edge, State, Token, OutEdge, Graph}

  test "can compute ranks" do
    # TODO Separate schema from workflow.
  end

  test "can compute transitions" do
    workflow = %Workflow{
      schema: %Schema{
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
      },
      states: [
        %State{id: 1},
      ],
    }

    workflow = Workflow.transition(workflow, %Edge{id: 1, next: 2})
    assert workflow.states == [%State{id: 2}]

    workflow = Workflow.transition(workflow, %Edge{id: 2, next: 3})
    assert workflow.states == [%State{id: 3}]

    assert Workflow.out_edges(workflow, %State{id: 2}) == [%OutEdge{edge: %Edge{id: 2, next: 1}}, %OutEdge{edge: %Edge{id: 2, next: 3}}]

    Graph.graph(workflow)
    |> Graphvix.Graph.compile("test1")

    workflow = Graph.rank(workflow, "test1")

    assert workflow.schema.nodes == [
      %Fountainedge.Node{id: 1, label: "First", rank: 1, type: :initial},
      %Fountainedge.Node{id: 2, label: "Second", rank: 2},
      %Fountainedge.Node{id: 3, label: "Third", rank: 3, type: :final}
    ]
  end

  test "can compute forks and joins" do
    workflow = %Workflow{
      schema: %Schema{
        nodes: [
          %Node{id: 1, type: :initial},
          %Node{id: 2, type: :fork, join: 7},
          %Node{id: 3},
          %Node{id: 4},
          %Node{id: 5},
          %Node{id: 6},
          %Node{id: 7, type: :join},
          %Node{id: 8, type: :final},
        ],
        edges: [
          %Edge{id: 1, next: 2},
          %Edge{id: 2, next: 3},
          %Edge{id: 2, next: 5},
          %Edge{id: 3, next: 4},
          %Edge{id: 4, next: 7},
          %Edge{id: 5, next: 6},
          %Edge{id: 6, next: 7},
          %Edge{id: 7, next: 8},
        ],
      },
      states: [
        %State{id: 1},
      ],
    }

    workflow = Workflow.transition(workflow, %Edge{id: 1, next: 2})
    assert workflow.states == [
      %State{id: 5, tokens: [%Token{id: 2, token: 5}]},
      %State{id: 3, tokens: [%Token{id: 2, token: 3}]},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 3, next: 4})
    assert workflow.states == [
      %State{id: 4, tokens: [%Token{id: 2, token: 3}]},
      %State{id: 5, tokens: [%Token{id: 2, token: 5}]},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 5, next: 6})
    assert workflow.states == [
      %State{id: 6, tokens: [%Token{id: 2, token: 5}]},
      %State{id: 4, tokens: [%Token{id: 2, token: 3}]},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 4, next: 7})
    assert workflow.states == [
      %State{id: 7, tokens: [%Token{id: 2, token: 3}]},
      %State{id: 6, tokens: [%Token{id: 2, token: 5}]},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 6, next: 7})
    assert workflow.states == [
      %State{id: 8},
    ]

    Graph.graph(workflow)
    |> Graphvix.Graph.compile("test2")
  end

  test "nested forks and joins" do
    workflow = %Workflow{
      schema: %Schema{
        nodes: [
          %Node{id: 1, type: :initial},
          %Node{id: 2, type: :fork, join: 11},
          %Node{id: 3, type: :fork, join: 8},
          %Node{id: 4},
          %Node{id: 5},
          %Node{id: 6},
          %Node{id: 7},
          %Node{id: 8, type: :join},
          %Node{id: 9},
          %Node{id: 10},
          %Node{id: 11, type: :join},
          %Node{id: 12, type: :final},
        ],
        edges: [
          %Edge{id: 1, next: 2},
          %Edge{id: 2, next: 3},
          %Edge{id: 3, next: 4},
          %Edge{id: 4, next: 8},
          %Edge{id: 3, next: 5},
          %Edge{id: 5, next: 6},
          %Edge{id: 6, next: 8},
          %Edge{id: 3, next: 7},
          %Edge{id: 7, next: 8},
          %Edge{id: 8, next: 11},
          %Edge{id: 2, next: 9},
          %Edge{id: 9, next: 10},
          %Edge{id: 10, next: 11},
          %Edge{id: 11, next: 12},
        ],
      },
      states: [
        %State{id: 1},
      ],
    }

    workflow = Workflow.transition(workflow, %Edge{id: 1, next: 2})
    assert workflow.states == [
      %State{id: 9, tokens: [%Token{id: 2, token: 9}]},
      %State{id: 7, tokens: [%Token{id: 3, token: 7}, %Token{id: 2, token: 3}]},
      %State{id: 5, tokens: [%Token{id: 3, token: 5}, %Token{id: 2, token: 3}]},
      %State{id: 4, tokens: [%Token{id: 3, token: 4}, %Token{id: 2, token: 3}]},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 4, next: 8})
    workflow = Workflow.transition(workflow, %Edge{id: 5, next: 6})
    workflow = Workflow.transition(workflow, %Edge{id: 9, next: 10})
    assert workflow.states == [
      %State{id: 10, tokens: [%Token{id: 2, token: 9}]},
      %State{id: 6, tokens: [%Token{id: 3, token: 5}, %Token{id: 2, token: 3}]},
      %State{id: 8, tokens: [%Token{id: 3, token: 4}, %Token{id: 2, token: 3}]},
      %State{id: 7, tokens: [%Token{id: 3, token: 7}, %Token{id: 2, token: 3}]},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 6, next: 8})
    assert workflow.states == [
      %State{id: 8, tokens: [%Token{id: 3, token: 5}, %Token{id: 2, token: 3}]},
      %State{id: 10, tokens: [%Token{id: 2, token: 9}]},
      %State{id: 8, tokens: [%Token{id: 3, token: 4}, %Token{id: 2, token: 3}]},
      %State{id: 7, tokens: [%Token{id: 3, token: 7}, %Token{id: 2, token: 3}]},
    ]
    assert Workflow.out_edges(workflow) == [
      %OutEdge{edge: %Edge{id: 7, next: 8}},
      %OutEdge{edge: %Edge{id: 8, next: 11}, disabled: true},
      %OutEdge{edge: %Edge{id: 10, next: 11}},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 7, next: 8})
    assert workflow.states == [
      %State{id: 11, tokens: [%Token{id: 2, token: 3}]},
      %State{id: 10, tokens: [%Token{id: 2, token: 9}]},
    ]

    workflow = Workflow.transition(workflow, %Edge{id: 10, next: 11})
    assert workflow.states == [
      %State{id: 12},
    ]

    Graph.graph(workflow)
    |> Graphvix.Graph.compile("test3")
  end
end
