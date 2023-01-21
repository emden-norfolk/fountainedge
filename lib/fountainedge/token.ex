defmodule Fountainedge.Token do
  @moduledoc """
  Tokens track parallel progression from a fork
  to a join.
  """

  @enforce_keys [:id, :token]

  defstruct id: nil, token: nil
end
