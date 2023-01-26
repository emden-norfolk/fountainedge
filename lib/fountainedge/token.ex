defmodule Fountainedge.Token do
  @moduledoc """
  Tokens track parallel progression from a fork to a join.

  They belong to a `Fountainedge.State`.
  """

  @enforce_keys [:id, :token]

  defstruct id: nil,
    token: nil

  @typedoc """
  Token structure.
  * `:id` - Identifier of the `Fountainedge.Node` from where the fork originated (type `:fork`.)
  * `:token` - Identifier of the `Fountainedge.Node` where the out edge points to.
    Thereby, this is unique; one token is created per each out edge from the fork.
  """

  @type t :: %__MODULE__{
    id: integer,
    token: integer
  }
end
