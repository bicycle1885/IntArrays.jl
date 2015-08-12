JULIA=julia

all: baseline.tsv intvector.tsv

baseline.tsv:
	$(JULIA) bench.jl --baseline > $@

intvector.tsv:
	$(JULIA) bench.jl > $@

clean:
	rm *.tsv
