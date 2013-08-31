-module(temp).
-include_lib("eunit/include/eunit.hrl").
-export([f2c/1, c2f/1, convert/1]).

f2c(F) ->
    (F-32)*5/9.

c2f(C) ->
    C*9/5+32.

convert({c, C}) -> {f, c2f(C)};
convert({f, F}) -> {c, f2c(F)}.

f2c_test() ->
    ?assertEqual(0.0, f2c(32)),
    ?assertEqual(100.0, f2c(212)),
    ?assertEqual(24.444444444444443, f2c(76)).

c2f_test() ->
    ?assertEqual(32.0, c2f(0)),
    ?assertEqual(212.0, c2f(100)),
    ?assertEqual(76.0, c2f(24.444444444444443)).

convert_test() ->
    ?assertEqual({c, 0.0}, convert({f, 32})),
    ?assertEqual({c, 100.0}, convert({f, 212})),
    ?assertEqual({c, 24.444444444444443}, convert({f, 76})),
    ?assertEqual({f, 32.0}, convert({c, 0})),
    ?assertEqual({f, 212.0}, convert({c, 100})),
    ?assertEqual({f, 76.0}, convert({c, 24.444444444444443})).
