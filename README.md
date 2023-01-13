# Fountainedge

Fountainedge is a simple workflow engine that roughly models forks and joins as described in the paper [Process Modeling Notations and
Workflow Patterns, Stephen A. White, IBM Corporation](http://www.workflowpatterns.com/vendors/documentation/BPMN_wfh.pdf).

Nodes (vertices) and edges (links.) Uses tokens.

This API is currently experimental (version 0.) A stable API will be released under version 1.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fountainedge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fountainedge, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fountainedge](https://hexdocs.pm/fountainedge).

