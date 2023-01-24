defmodule Fountainedge.Node do
  @moduledoc """
  A graph node (also known as a vertex.)

  [Graphviz](https://graphviz.org/)
  is used for presentation and ranking of graph nodes.
  See `Graphvix.Graph.add_vertex/3`.

  ## Forking and Synchronisation

  To create a paralell process, create a node of type `:fork`.

  The fork node must be associated with a join node.

  The forking node will create tokens for each out edge.
  The join node will synchronise the parallel processes by preventing the workflow
  from proceeding beyond until all of these tokens are collected.

  Here is an example where a fork creates three tokens for each separate
  branch.

  Nodes:

      [
        ...
        %Node{id: 5, type: :fork, join: 9},
        %Node{id: 6, label: "Parallel 1"},
        %Node{id: 7, label: "Parallel 2"},
        %Node{id: 8, label: "Parallel 3"},
        %Node{id: 9, type: :join},
        ...
      ]

  Edges:

      [
        ...
        %Edge{id: 5, next: 6},
        %Edge{id: 5, next: 7},
        %Edge{id: 5, next: 8},
        %Edge{id: 6, next: 9},
        %Edge{id: 7, next: 9},
        %Edge{id: 8, next: 9},
        ...
      ]

  """

  @enforce_keys [:id]

  defstruct id: nil,
    type: :normal,
    join: nil,
    label: nil,
    rank: nil,
    attributes: []

  @typedoc """
  Node structure.
  * `:id` - Identifier of the node.
  * `:type` - Node type, one of:
  * `:normal` - Normal node (*default*.)
    * `:initial` - Start node.
    * `:final` - End node.
    * `:fork` - Fork into a parallel process. The joining node must be specified.
    * `:join` - Synchronise (join) a parallel process. The workflow will stop here until all tokens
    (`Fountainedge.Token`) generated by the fork are collected.
  * `:join` - Used when forking with type `:fork`. Specifies the node identifier of the associated
    joining node where the parallel workflow will eventually synchronise. The joining node must be of
    type `:join`.
  * `:label` - Optional label.
  * `:rank` - Hierarchical rank of the node. The rank is used for determining backward and forward directions
    from the initial to final node when navigating through the workflow.
    The rankingis are defined by calling `Fountainedge.Graph.rank/2` on the schema.
  * `:attributes` Optional list of [edge attributes](https://graphviz.org/docs/edges/)
    passed to `Graphvix.Graph.add_edge/4`.
  """

  @type t :: %__MODULE__{
    id: integer,
    type: :normal | :initial | :final | :fork | :join,
    join: integer | nil,
    label: String.t | nil,
    rank: integer | nil,
    attributes: list()
  }

  @doc """
  Find a matching node in a list (used internally.)
  """
  @spec find(list(Fountainedge.Node.t()), integer) :: Fountainedge.Node.t() | nil
  def find(nodes, id) do
    Enum.find(nodes, fn n -> n.id == id end)
  end
end
