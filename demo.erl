-module(demo).
-include_lib("eunit/include/eunit.hrl").
-export([double/1]).

double(N) ->
    N * 2.

double_test() ->
    ?assertEqual(12, double(6)),
    ?assertEqual(1234, double(617)),
    ?assertEqual(0, double(0)),
    ?assertEqual(-10, double(-5)).
