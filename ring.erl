-module(ring).
-include_lib("eunit/include/eunit.hrl").
-export([run/2, secondary/1, primary/2]).

run(N, M) ->
    Primary = spawn_link(?MODULE, primary, [N, self()]),
    Primary ! {M, 0},
    receive
	{Total, Pids} -> {Total, Pids}
    end.

grow_ring(N) ->
    grow_ring(N-1, [self()]).
grow_ring(0, Pids) ->
    Pids;
grow_ring(N, [Next|Pids]) ->
    Current = spawn_link(?MODULE, secondary, [Next]),
    grow_ring(N - 1, [Current,Next|Pids]).

primary(N, Parent) ->
    Pids = grow_ring(N),
    [Next|_] = Pids,
    Total = primary_participate(Next),
    Parent ! {Total, Pids}.

primary_participate(Next) ->
    receive
	{0, Current} ->
	    Current;
	{M, Current} ->
	    Next ! {M-1, Current + 1},
	    primary_participate(Next)
    end.

secondary(Next) ->
    receive
	{0, Current} ->
	    Next ! {0, Current + 1};
	{M, Current} ->
	    Next ! {M, Current + 1},
	    secondary(Next)
    end.

processes_stopped([H|T]) ->
    undefined = process_info(H),
    processes_stopped(T);
processes_stopped([]) ->
    true.

ring_test() ->
    {Total, Pids} = run(10, 20),
    ?assertEqual(200, Total),
    ?assert(processes_stopped(Pids)).
