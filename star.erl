-module(star).
-include_lib("eunit/include/eunit.hrl").
-export([run/2, child_loop/0]).

run(N, M) ->
    Pids = start_children(N),
    send_first_messages(Pids, M),
    Total = participate(N),
    {Total, Pids}.

start_children(N) ->
    start_children(N, []).
start_children(0, Pids) ->
    Pids;
start_children(N, Pids) ->
    Pid = spawn_link(?MODULE, child_loop, []),
    start_children(N - 1, [Pid|Pids]).

child_loop() ->
    receive
	{0, From} ->
	    From ! {0, self()};
	{M, From} ->
	    From ! {M, self()},
	    child_loop()
    end.

send_first_messages([], _M) ->
    {};
send_first_messages([H|T], M) ->
    H ! {M - 1, self()},
    send_first_messages(T, M).

participate(N) ->
    participate(N, 0).
participate(0, Total) ->
    Total;
participate(N, Total) ->
    receive
	{0, _From} ->
	    participate(N - 1, Total + 1);
	{M, From} ->
	    From ! {M - 1, self()},
	    participate(N, Total + 1)
    end.

processes_stopped([H|T]) ->
    undefined = process_info(H),
    processes_stopped(T);
processes_stopped([]) ->
    true.

star_test() ->
    {Total, Pids} = run(10, 20),
    ?assertEqual(200, Total),
    ?assert(processes_stopped(Pids)).
