# Prolog code to operate on EF-Graphs [![Build Status](https://travis-ci.com/styczynski/jpp-prolog.svg?branch=master)](https://travis-ci.com/styczynski/jpp-prolog)

## About

This code was written as an assignment during course on Warsaw University.

## Building

The code is bundled using `PHP` so it should be available from terminal as well as `swipl` utility.
To build the project run `make all`. The bundled Prolog file will be present in `build/` folder.

## Testing

To run tests with `swipl` command line please call `make test` command from your shell.

## Abstract

### EF-Graphs definition

EF-Graph is a triplet `<V, E, F>` where:
* `V` is a vertex set
* `E ⊆ V^2` is a set of directed edges
* `F ⊆ {{v1, v2} | v1, v2 ∈ V }` is a set of undirected edges

### Routes definition

The ordered sequence of vertices `v1, . . . , vn` is a valid E-route iff for each `i = 1, . . . , n − 1` the condition `<vi, vi+1> ∈ E` is met.

The ordered sequence of vertices `v1, . . . , vn` is a valid F-route iff for each `i = 1, . . . , n − 1` the condition `{vi, vi+1} ∈ F` is met.

### Well-layouted graphs

The EF-graph `G` is well-layouted iff the following conditions are met:
* There is exactly one pair of vertices `Vs`, `Ve` such that there is no `(v, Vs)` E-edges and no `(Ve, v')` E-edges.
* There exists a Hamiltonian path from `Vs` to `Ve` using only E-edges.
* For each vertex `v ∈ V` there is at most 3 F-edges that have endings in that vertex.

For a given EF-Graph the `Vs` will be called graph source and `Ve` graph drain.

### Well-permuting graphs

The EF-graph `G` is well-permuting iff the following conditions are met:
* For each vertex `v` if there exist vertices `v1`, `w1` such that `(v, v1) ∈ E` and `v1` is not equal to `Ve` and `{v, w1} ∈ F`, then there also exists a vertex `u` such that `(w1, u) ∈ E` and `{v1, u} ∈ F`.
* For each vertex `v` if there exist vertices `v1`, `w1` such that `(v1, v) ∈ E` and `w1` is not equal to `Vs` and `{v, w1} ∈ F`, then there also exists a vertex `u` such that `(u, w1) ∈ E` and `{v1, u} ∈ F`.

### F-routes ordering

Let `v1, . . . , vn` and `w1, . . . , wm` be F-routes.
We say that `v1, . . . , vn` is an succesor of `w1, . . . , wm` iff the following conditions are met:
* `m ≤ n`
* for each `i ∈ {1, . . . , m}`, `(wi, vi) ∈ E`.

## Implementation

The EF-Graphs are represented inside the program as incidention lists, where each node is a tuple consiting of node's label, its E-neighbours and F-neighbours.

For example, for EF-Graph:
* `V = {v0, v1, v2, v3}`
* `E = {(v0, v1),(v1, v2),(v2, v3)}`
* `F = {{v0, v2}, {v1, v3}}`

We represent node `v0` as term `node(v0, [v1], [v2])` and the entire graph is represented using the following list:
```
  [
    node(v0, [v1], [v2]),
    node(v1, [v2], [v3]),
    node(v2, [v3], [v0]),
    node(v3, [], [v1])
  ]
```
This gaph is well-layouted and well-permuting.

The program defines its main predicates:
* `jestEFGrafem(+Term)` - checks if the term is a well-specified EF-Graph
* `jestDobrzeUlozony(+EFgraf)` - checks if the given EF-Graph is well-layouted
* `jestDobrzePermutujacy(+EFGraf)` - checks if the given EF-Graph is well-permuting
* `jestSucc(+EFgraf, -Lista1, -Lista2)` - checks if F-route represented by the list of node labels `Lista2` represents a successor of the F-route represented by the list of node labels `Lista1` in the EF-Graph `EFgraf`  

