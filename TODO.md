# Todo

* `:initial` [node shape](https://graphviz.org/doc/info/shapes.html) to `circle` and `:final`
    node shape to `doublecircle` respectively if label is nil.
* Decision node (node with more than one out edge) shape `diamond`.
* ~~Hash (#) notation for tokens at the join node.~~ ✓
* Neverending todo:
  * Document more examples.
  * Unit tests.
* Updating dependencies:
  * `graphvix` (requires Elixir version increase -- will be a minor release version therefore -- remember to set Elixir version in `mix.exs`.)
  * `decimal` (as above.)

## Validation

Validation will be a future feature when the package is proven to be popular (i.e., 10 or more stars, or bugs reported in the Issue Tracker.
It will have functionality changes but largely remain backwards-compatible, so therefore it will be a minor release version.

Even though validation is not implemented yet, it would be a good idea to use this list as a guide for best practice.

Pass extra option into `initialise/2`.

Raises exception?

`validation/1` gives a list of errors. Default to `:enforcing`.

Three error levels:

 * `:none` - No validation (use with care.)
 * `:enforcing` - Check for conditions that will break functionality, or are bad practice or against the original intention of the design.
 * `:strict` - Things that aren't nice or will just break rendering of the graph.

No intial node will always raise an exception, even with `:none`.

### Enforcing

 * Edges counts:
    * One edge into fork.
    * One edge out of join.
    * All nodes (other than initial and final) must have an in and out edge.
      *  Initial node at least one edge out.
      *  Final node at least one edge in.
    * Fork nodes must have at least two out edges.
    * Join nodes must have at least two in edges.
 * One initial node omly.
 * At least one final node.
 * Nodes must have a unique identifier.
 * Check that forking nodes point to a valid join node.
 * Check all edges point to a valid node identifier.
 * Check for duplicate edges.

### Strict

 * One edge only out of initial.
 * No edge out of final node.
 * No edge into intial node.
