defmodule Fountainedge.Graph.GVPR do
  use GenServer
  require Logger

  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(_args \\ []) do
    filename = to_string(:code.priv_dir(:fountainedge)) <> "/rank.gvpr"
    command = "gvpr -f #{filename}"
    command = "cat"
    port = Port.open({:spawn, command}, [:binary, :exit_status])

    {:ok, %{
      port: port,
      latest_output: nil,
      exit_status: nil,
    }}
  end

  def handle_call({:send, line}, _from, state) do
    Logger.info "Calling GVPR port."
    #Port.command(state.port, line)
    Port.command(state.port, "hi\n")
    #send state.port, {self(), {:command, line}}

    {:noreply, state}
  end

  def handle_info({_port, {:data, line}}, state) do
    Logger.info "GVPR output."
    Logger.info line
    {:noreply, %{state | latest_output: line}}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    Logger.info "GVPR Stopped"
    {:stop, :normal, %{state | exit_status: status}}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
