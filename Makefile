test:
	dune exec examples/parquet/gen/gen.exe
	LD_LIBRARY_PATH=_build/default/examples/parquet/src:${LD_LIBRARY_PATH} dune exec examples/parquet/test/test.exe

clean:
	dune clean
