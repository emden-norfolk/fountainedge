defmodule Fountainedge.Edge do
  @moduledoc """
  Documentation for Fountainedge.Edge.
  """

  @enforce_keys [:id, :next]

  defstruct id: nil, next: nil
end
