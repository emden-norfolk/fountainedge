defmodule Fountainedge.Node do
  @moduledoc """
  Documentation for Fountainedge.Node.
  """

  @enforce_keys [:id]

  defstruct id: nil, type: :normal, join: nil
end
