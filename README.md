
**NOTICE: VERSION 0.1 to VERSION 1.0 UPGRADE HAS BREAKING API CHANGES**

----

# Fountainedge

**Fountainedge** is a simple workflow engine written in [Elixir](https://elixir-lang.org/) that roughly models forks and joins as described in the paper [Process Modeling Notations and
Workflow Patterns](https://github.com/emden-norfolk/fountainedge/raw/master/BPMN_wfh.pdf) by Stephen A. White, IBM Corporation. 
Uses [Graphviz](https://graphviz.org/) for graphical representations as UML Activity Diagrams.

 * [Hex Package](https://hex.pm/packages/fountainedge)
 * [Documentation](https://hexdocs.pm/fountainedge)

The workflow is modelled as graphs consisting of nodes and edges. Parallel forks and joins are tracked using tokens.

This API is currently experimental (version 0.) A stable API will be released under version 1.

## Installation

This package can be installed by adding `fountainedge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fountainedge, "~> 1.0.0"}
  ]
end
```


