# Todo

## Validation

Validation will be a future feature when the package is proven to be popular (i.e., 10 or more stars, or bugs reported in the Issue Tracker.
It will have functionality changes but largely remain backwards-compatible, so therefore it will be a minor release version.

Even though validation is not implemented yet, it would be a good idea to use this list as a guide for best practice.

Pass extra option into `initialise/2`.

Raises exception?

`validation/1` gives a list of errors. Default to `:enforcing`.

Three error levels:

 * `:none`: No validation (use with care.)
 * `:enforcing`: Check for conditions that will break functionality, or are bad practice or against the original intention of the design.
 * `:strict`: Things that aren't nice or will just break rendering of the graph.

### Enforcing

 * 

### Strict

 * 
