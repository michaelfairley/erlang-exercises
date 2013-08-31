compile:
	erlc temp.erl
test: compile
	erl -noshell -eval "eunit:test(temp)" -s init stop
