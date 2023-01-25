defmodule FountainedgeTest do
  use ExUnit.Case
  doctest Fountainedge

  alias Fountainedge.{Workflow, Schema, Node, Edge, State, Token, Graph}

  test "can compute ranks" do
    # TODO Separate schema from workflow.
  end

  test "can compute transitions" do
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
    assert Fountainedge.out_edge_nodes(workflow) == [
      {
        %Edge{id: 1, next: 2},
        %Node{id: 1, label: "First", type: :initial},
        %Node{id: 2, label: "Second"}
      }
    ]
    Graph.graph(workflow)
    |> Graphvix.Graph.compile("examples/test1_1", :svg)

    # First transition. (1 -> 2)
    workflow = Fountainedge.transition(workflow, %Edge{id: 1, next: 2})
    assert workflow.states == [%State{id: 2}]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 2, next: 1},
      %Edge{id: 2, next: 3}
    ]
    Graph.graph(workflow)
    |> Graphvix.Graph.compile("examples/test1_2", :svg)

    # Go back to first. (2 -> 1)
    workflow = Fountainedge.transition(workflow, %Edge{id: 2, next: 1})
    assert workflow.states == [%State{id: 1}]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 1, next: 2},
    ]

    # First transition again. (1 -> 2)
    workflow = Fountainedge.transition(workflow, %Edge{id: 1, next: 2})
    assert workflow.states == [%State{id: 2}]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 2, next: 1},
      %Edge{id: 2, next: 3}
    ]

    # Second transition (last.) (2 -> 3)
    workflow = Fountainedge.transition(workflow, %Edge{id: 2, next: 3})
    assert workflow.states == [%State{id: 3}]
    assert Fountainedge.out_edges(workflow) == []
    Graph.graph(workflow)
    |> Graphvix.Graph.compile("examples/test1_3", :svg)

    # Ranking.
    schema = Graph.rank(workflow.schema, "test1")
    assert schema.nodes == [
      %Node{id: 1, label: "First", rank: 1, type: :initial},
      %Node{id: 2, label: "Second", rank: 2},
      %Node{id: 3, label: "Third", rank: 3, type: :final}
    ]
  end

  test "can compute forks and joins" do
    # Initial state.
    schema = %Schema{
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
    }
    workflow = Workflow.initialize(schema)
    assert workflow.states == [%State{id: 1}]
    assert Fountainedge.out_edges(workflow) == [%Edge{id: 1, next: 2}]

    # 1 -> 2 (fork)
    workflow = Fountainedge.transition(workflow, %Edge{id: 1, next: 2})
    assert workflow.states == [
      %State{id: 5, tokens: [%Token{id: 2, token: 5}]},
      %State{id: 3, tokens: [%Token{id: 2, token: 3}]},
    ]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 3, next: 4},
      %Edge{id: 5, next: 6},
    ]

    # 3 -> 4
    workflow = Fountainedge.transition(workflow, %Edge{id: 3, next: 4})
    assert workflow.states == [
      %State{id: 4, tokens: [%Token{id: 2, token: 3}]},
      %State{id: 5, tokens: [%Token{id: 2, token: 5}]},
    ]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 5, next: 6},
      %Edge{id: 4, next: 7},
    ]

    # 5 -> 6
    workflow = Fountainedge.transition(workflow, %Edge{id: 5, next: 6})
    assert workflow.states == [
      %State{id: 6, tokens: [%Token{id: 2, token: 5}]},
      %State{id: 4, tokens: [%Token{id: 2, token: 3}]},
    ]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 4, next: 7},
      %Edge{id: 6, next: 7},
    ]

    # 4 -> 7 (join)
    workflow = Fountainedge.transition(workflow, %Edge{id: 4, next: 7})
    assert workflow.states == [
      %State{id: 7, tokens: [%Token{id: 2, token: 3}]},
      %State{id: 6, tokens: [%Token{id: 2, token: 5}]},
    ]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 6, next: 7},
    ]

    # Try something invalid, like going ahead too soon before the other token has joined.
    assert_raise RuntimeError, "Invalid out edge given for transition.", fn ->
      Fountainedge.transition(workflow, %Edge{id: 7, next: 8})
    end

    # 6 -> 7 (join)
    workflow = Fountainedge.transition(workflow, %Edge{id: 6, next: 7})
    assert workflow.states == [
      %State{id: 8},
    ]
    assert Fountainedge.out_edges(workflow) == []

    # Graphing.
    Graph.graph(workflow)
    |> Graphvix.Graph.compile("test2")
  end

  test "nested forks and joins" do
    schema = %Schema{
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
        %Edge{id: 6, next: 5},
        %Edge{id: 6, next: 8},
        %Edge{id: 3, next: 7},
        %Edge{id: 7, next: 8},
        %Edge{id: 8, next: 11},
        %Edge{id: 2, next: 9},
        %Edge{id: 9, next: 10},
        %Edge{id: 10, next: 9},
        %Edge{id: 10, next: 11},
        %Edge{id: 11, next: 12},
      ],
    }
    workflow = Workflow.initialize(schema)
    workflow = Fountainedge.transition(workflow, %Edge{id: 1, next: 2})
    assert workflow.states == [
      %State{id: 9, tokens: [%Token{id: 2, token: 9}]},
      %State{id: 7, tokens: [%Token{id: 3, token: 7}, %Token{id: 2, token: 3}]},
      %State{id: 5, tokens: [%Token{id: 3, token: 5}, %Token{id: 2, token: 3}]},
      %State{id: 4, tokens: [%Token{id: 3, token: 4}, %Token{id: 2, token: 3}]},
    ]

    workflow = Fountainedge.transition(workflow, %Edge{id: 4, next: 8})
    workflow = Fountainedge.transition(workflow, %Edge{id: 5, next: 6})
    workflow = Fountainedge.transition(workflow, %Edge{id: 9, next: 10})
    assert workflow.states == [
      %State{id: 10, tokens: [%Token{id: 2, token: 9}]},
      %State{id: 6, tokens: [%Token{id: 3, token: 5}, %Token{id: 2, token: 3}]},
      %State{id: 8, tokens: [%Token{id: 3, token: 4}, %Token{id: 2, token: 3}]},
      %State{id: 7, tokens: [%Token{id: 3, token: 7}, %Token{id: 2, token: 3}]},
    ]

    workflow = Fountainedge.transition(workflow, %Edge{id: 6, next: 8})
    assert workflow.states == [
      %State{id: 8, tokens: [%Token{id: 3, token: 5}, %Token{id: 2, token: 3}]},
      %State{id: 10, tokens: [%Token{id: 2, token: 9}]},
      %State{id: 8, tokens: [%Token{id: 3, token: 4}, %Token{id: 2, token: 3}]},
      %State{id: 7, tokens: [%Token{id: 3, token: 7}, %Token{id: 2, token: 3}]},
    ]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 7, next: 8},
      %Edge{id: 10, next: 11},
      %Edge{id: 10, next: 9},
    ]

    workflow = Fountainedge.transition(workflow, %Edge{id: 7, next: 8})
    assert workflow.states == [
      %State{id: 11, tokens: [%Token{id: 2, token: 3}]},
      %State{id: 10, tokens: [%Token{id: 2, token: 9}]},
    ]

    workflow = Fountainedge.transition(workflow, %Edge{id: 10, next: 11})
    assert workflow.states == [
      %State{id: 12},
    ]

    Graph.graph(workflow)
    |> Graphvix.Graph.compile("test3")
  end

  test "nested forks and joins with bypass of first fork" do
    schema = %Schema{
      edges: [
        %Edge{id: 4, next: 5},
        %Edge{id: 5, next: 6},
        %Edge{id: 6, next: 5, attributes: [constraint: false]},
        %Edge{id: 6, next: 7},
        %Edge{id: 7, next: 8},
        %Edge{id: 7, next: 10},
        %Edge{id: 7, next: 17},
        %Edge{id: 10, next: 7},
        %Edge{id: 10, next: 9},
        %Edge{id: 9, next: 26},
        %Edge{id: 9, next: 10},
        %Edge{id: 26, next: 15},
        %Edge{id: 26, next: 17},
        %Edge{id: 15, next: 11},
        %Edge{id: 11, next: 12},
        %Edge{id: 12, next: 22},
        %Edge{id: 23, next: 22},
        %Edge{id: 16, next: 23},
        %Edge{id: 21, next: 23},
        %Edge{id: 22, next: 18},
        %Edge{id: 20, next: 21},
        %Edge{id: 17, next: 25},
        %Edge{id: 25, next: 16},
        %Edge{id: 25, next: 20},
        %Edge{id: 18, next: 13},
        %Edge{id: 13, next: 14},
        %Edge{id: 14, next: 19},
        %Edge{id: 19, next: 24}
      ],
      nodes: [
        %Node{
          id: 13,
          join: nil,
          type: :normal
        },
        %Node{
          id: 14,
          join: nil,
          type: :normal
        },
        %Node{
          id: 15,
          join: nil,
          type: :normal
        },
        %Node{
          id: 16,
          join: nil,
          type: :normal
        },
        %Node{
          id: 17,
          join: nil,
          type: :normal
        },
        %Node{
          id: 18,
          join: nil,
          type: :normal
        },
        %Node{
          id: 19,
          join: nil,
          type: :normal
        },
        %Node{
          id: 20,
          join: nil,
          type: :normal
        },
        %Node{
          id: 21,
          join: nil,
          type: :normal
        },
        %Node{
          id: 22,
          join: nil,
          type: :join
        },
        %Node{
          id: 23,
          join: nil,
          type: :join
        },
        %Node{
          id: 24,
          join: nil,
          type: :final
        },
        %Node{
          id: 4,
          join: nil,
          type: :initial
        },
        %Node{
          id: 5,
          join: nil,
          type: :normal
        },
        %Node{
          id: 6,
          join: nil,
          type: :normal
        },
        %Node{
          id: 7,
          join: nil,
          type: :normal
        },
        %Node{
          id: 8,
          join: nil,
          type: :final
        },
        %Node{
          id: 9,
          join: nil,
          type: :normal
        },
        %Node{
          id: 10,
          join: nil,
          type: :normal
        },
        %Node{
          id: 11,
          join: nil,
          type: :normal
        },
        %Node{
          id: 12,
          join: nil,
          type: :normal
        },
        %Node{
          id: 25,
          join: 23,
          type: :fork
        },
        %Node{
          id: 26,
          join: 22,
          type: :fork
        }
      ]
    }
    workflow = Workflow.initialize(schema)

    Graph.graph(workflow)
    |> Graphvix.Graph.compile("test4")

    Graph.rank(schema, "test4")
  end

  test "can compute decision transitions" do
    schema = %Schema{
      nodes: [
        %Node{id: 1, label: "Initial", type: :initial},
        %Node{id: 2, label: "Choice 1"},
        %Node{id: 3, label: "Choice 2"},
        %Node{id: 4, label: "Final", type: :final},
      ],
      edges: [
        %Edge{id: 1, next: 2},
        %Edge{id: 1, next: 3},
        %Edge{id: 2, next: 1},
        %Edge{id: 2, next: 4},
        %Edge{id: 3, next: 1},
        %Edge{id: 3, next: 4},
      ],
    }

    # Graphing.
    Graph.graph(schema)
    |> Graphvix.Graph.compile("test5", :png)

    # Ranking.
    schema = Graph.rank(schema, "test5")
    assert schema.nodes == [
      %Node{id: 1, label: "Initial", rank: 1, type: :initial},
      %Node{id: 2, label: "Choice 1", rank: 2},
      %Node{id: 3, label: "Choice 2", rank: 2},
      %Node{id: 4, label: "Final", rank: 3, type: :final}
    ]

    # Initial state.
    workflow = Workflow.initialize(schema)
    assert workflow.states == [%State{id: 1}]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 1, next: 3},
      %Edge{id: 1, next: 2},
    ]

    # First transition. (1 -> 3)
    workflow = Fountainedge.transition(workflow, %Edge{id: 1, next: 3})
    assert workflow.states == [%State{id: 3}]
    assert Fountainedge.out_edges(workflow) == [
      %Edge{id: 3, next: 4},
      %Edge{id: 3, next: 1},
    ]

    # Last transition (3 -> 4)
    workflow = Fountainedge.transition(workflow, %Edge{id: 3, next: 4})
    assert workflow.states == [%State{id: 4}]
    assert Fountainedge.out_edges(workflow) == []
  end

  test "can do fun" do
    schema = %Schema{
      nodes: [
        %Node{id: 1, label: "Initial", type: :initial},
        %Node{id: 2, label: "Choice 1"},
        %Node{id: 3, label: "Choice 2"},
        %Node{id: 4, label: "Before Forking"},
        %Node{id: 5, type: :fork, join: 9},
        %Node{id: 6, label: "Parallel 1.1"},
        %Node{id: 7, label: "Parallel 1.2"},
        %Node{id: 8, label: "Parallel 2"},
        %Node{id: 9, type: :join},
        %Node{id: 10, label: "After Joining"},
        %Node{id: 11, label: "Final", type: :final},
      ],
      edges: [
        %Edge{id: 1, next: 2, attributes: [label: "Y"]},
        %Edge{id: 1, next: 3, attributes: [label: "N"]},
        %Edge{id: 2, next: 4},
        %Edge{id: 3, next: 4},
        %Edge{id: 4, next: 5},
        %Edge{id: 5, next: 6},
        %Edge{id: 5, next: 8},
        %Edge{id: 6, next: 7},
        %Edge{id: 7, next: 6},
        %Edge{id: 7, next: 9},
        %Edge{id: 8, next: 9},
        %Edge{id: 9, next: 10},
        %Edge{id: 10, next: 11},
      ],
    }

    # Graphing.
    Graph.graph(schema)
    |> Graphvix.Graph.compile("images/test6", :svg)
    Graph.graph(schema)
    |> Graphvix.Graph.compile("doc/images/test6", :svg)
  end
end
