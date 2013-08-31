SOURCES := $(wildcard *.erl)

compile:
	erlc ${SOURCES}
test: compile
	erl -noshell -eval "eunit:test({dir, \".\"})" -s init stop
