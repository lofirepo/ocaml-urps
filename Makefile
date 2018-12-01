.PHONY: all build doc test clean

all: build doc test

build:
	dune build

doc:
	dune build @doc

test:
	dune runtest -f -j1 --no-buffer --verbose

n=100
testn: test
	for i in {1..$(n)}; do \
	  ./_build/default/test/test_urps.exe | grep 'max\|FAIL'; \
	done

clean:
	dune clean
