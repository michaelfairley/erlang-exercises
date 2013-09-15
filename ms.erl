-module(ms).
-include_lib("eunit/include/eunit.hrl").
-export([start/1, to_slave/2, master/1, slave/0]).

start(N) ->
    MasterPid = spawn_link(?MODULE, master, [N]),
    register(master, MasterPid).

to_slave(Message, M) ->
    master ! {Message, M, self()}.

master(N) ->
    SlaveDict = spawn_slaves(N),
    process_flag(trap_exit, true),
    master_loop(SlaveDict).

master_loop(SlaveDict) ->
    receive
	{'EXIT', Pid, {killed, To}} ->
	    SlaveNo = find_slave_number(Pid, SlaveDict),
	    To ! {SlaveNo, died, self()},
	    master_loop(spawn_slave(SlaveNo, SlaveDict));
	{Message, M, From} ->
	    case dict:find(M, SlaveDict) of
		error ->
		    From ! {unknown_slave, M};
		{ok, Pid} ->
		    Pid ! {Message, From},
		    master_loop(SlaveDict)
	    end
    end.

find_slave_number(Pid, SlaveDict) ->
    find_slave_number(Pid, SlaveDict, dict:fetch_keys(SlaveDict)).
find_slave_number(Pid, SlaveDict, [Number|Rest]) ->
    case dict:fetch(Number, SlaveDict) of
	Pid ->
	    Number;
	_Else ->
	    find_slave_number(Pid, SlaveDict, Rest)
    end.

spawn_slaves(N) ->
    spawn_slaves(N, dict:new()).
spawn_slaves(0, SlaveDict) ->
    SlaveDict;
spawn_slaves(N, SlaveDict) ->
    spawn_slaves(N - 1, spawn_slave(N, SlaveDict)).

spawn_slave(N, SlaveDict) ->
    Pid = spawn_link(?MODULE, slave, []),
    dict:store(N, Pid, SlaveDict).


slave() ->
    receive
	{die, To} ->
	    exit({killed, To});
	{Message, To} ->
	    To ! {Message, self()},
	    slave()
    end.


% Tests + helpers
next_message() ->
    receive
	X -> X
    end.

setup() ->
    ms:start(10).
cleanup(_) ->
    case whereis(master) of
	undefined ->
	    nothing_to_do;
	Pid ->
	    exit(Pid, kill)
    end.

test_echo() ->
    ms:to_slave(hello, 1),
    {hello, _Pid} = next_message().

test_same_slave() ->
    ms:to_slave(hello, 1),
    {hello, Pid} = next_message(),
    ms:to_slave(goodbye, 1),
    {goodbye, Pid} = next_message().

test_different_slave() ->
    ms:to_slave(hello, 1),
    {hello, Pid1} = next_message(),
    ms:to_slave(goodbye, 2),
    {goodbye, Pid2} = next_message(),
    ?assert(Pid1 =/= Pid2).

test_kill_slave() ->
    ms:to_slave(hello, 1),
    {hello, Pid1} = next_message(),
    ms:to_slave(die, 1),
    ?assertEqual({1, died, whereis(master)}, next_message()),
    ms:to_slave(goodbye, 1),
    {goodbye, Pid2} = next_message(),
    ?assert(Pid1 =/= Pid2).

test_unknown_slave() ->
    ms:to_slave(hello, 11),
    ?assertEqual({unknown_slave, 11}, next_message()).

ms_test_() ->
    {spawn,
     {setup,
      fun setup/0,
      fun cleanup/1,
      [
       fun test_echo/0,
       fun test_same_slave/0,
       fun test_different_slave/0,
       fun test_kill_slave/0,
       fun test_unknown_slave/0
       ]
      }
    }.
