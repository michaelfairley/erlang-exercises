-module(mathStuff).
-include_lib("eunit/include/eunit.hrl").
-export([perimeter/1]).

perimeter({square, Side}) -> Side * 4;
perimeter({circle, Radius}) -> Radius * 2 * 3.14;
perimeter({triangle, A, B, C}) -> A + B + C.
perimeter_test() ->
    ?assertEqual(8, perimeter({square, 2})),
    ?assertEqual(12.56, perimeter({circle, 2})),
    ?assertEqual(6, perimeter({triangle, 1, 2, 3})).
