defmodule Fountainedge.Edge do
  @moduledoc """
  Documentation for Fountainedge.Node.
  """

  @enforce_keys [:id, :next]

  defstruct id: nil, next: nil
end
