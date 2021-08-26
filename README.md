[![Build Status](https://travis-ci.org/p2pcollab/ocaml-urps.svg?branch=master)](https://travis-ci.org/p2pcollab/ocaml-urps)

# URPS: Uniform Random Peer Sampler

URPS is an OCaml implementation of the stream sampler
as specified in the paper
[Uniform Node Sampling Service Robust against Collusions of Malicious Nodes](https://hal.archives-ouvertes.fr/hal-00804430).

It processes on the fly an unbounded and arbitrarily biased input stream
made of node identifiers exchanged within the system,
and outputs a stream that preserves Uniformity and Freshness properties.

URPS is distributed under the AGPL-3.0-only license.

## Installation

``urps`` can be installed via `opam`:

    opam install urps

## Building with Nix

Set up Nix Flakes, then run:

    nix build

## Developing with Nix

To get a development shell with all dependencies and build tools installed, run:

    nix develop

## Building

To build from source, generate documentation, and run tests, use `dune`:

    dune build
    dune build @doc
    dune runtest -f -j1 --no-buffer

In addition, the following `Makefile` targets are available
 as a shorthand for the above:

    make all
    make build
    make doc
    make test
    make testn
    make testn n=10

## Documentation

The documentation and API reference is generated from the source interfaces.
It can be consulted [online][doc] or via `odig`:

    odig doc urps

[doc]: https://p2pcollab.net/doc/ocaml/urps/
