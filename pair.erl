-module(pair).
-include_lib("eunit/include/eunit.hrl").
-export([second/0, first/1]).

run(M) ->
    Second = spawn_link(?MODULE, second, []),
    First = spawn_link(?MODULE, first, [self()]),
    First ! {M, 0, Second},
    receive
	N ->
	    {N, [First, Second]}
    end.

% I'm not super happy with the duplication in these next two
% functions, but I'm also not sure what to do about it.
second() ->
    receive
	{0, Current, Other} ->
	    Other ! {0, Current + 1, self()};
	{M, Current, Other} ->
	    Other ! {M, Current + 1, self()},
	    second()
    end.

first(Parent) ->
    receive
	{0, Current, _Other} ->
	    Parent ! Current;
	{M, Current, Other} ->
	    Other ! {M - 1, Current + 1, self()},
	    first(Parent)
    end.

processes_stopped([H|T]) ->
    undefined = process_info(H),
    processes_stopped(T);
processes_stopped([]) ->
    true.

pair_test() ->
    {Total, Pids} = run(10),
    ?assertEqual(20, Total),
    ?assert(processes_stopped(Pids)).
