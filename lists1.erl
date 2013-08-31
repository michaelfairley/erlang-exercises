-module(lists1).
-include_lib("eunit/include/eunit.hrl").
-export([min/1, max/1, min_max/1]).

min([H|T]) -> mymin(T, H).
mymin([H|T], Min) -> mymin(T, min(H, Min));
mymin([], Min) -> Min.

max([H|T]) -> mymax(T, H).
mymax([H|T], Min) -> mymax(T, max(H, Min));
mymax([], Min) -> Min.

min_max([H|T]) -> min_max(T, {H, H}).
min_max([H|T], {Min, Max}) -> min_max(T, {min(H, Min), max(H, Max)});
min_max([], {Min, Max}) -> {Min, Max}.

min_test() ->
    ?assertEqual(1, min([1, 2, 3])),
    ?assertEqual(1, min([3, 2, 1])),
    ?assertEqual(1, min([2, 1, 3])).

max_test() ->
    ?assertEqual(3, max([1, 2, 3])),
    ?assertEqual(3, max([3, 2, 1])),
    ?assertEqual(3, max([2, 1, 3])).

min_max_test() ->
    ?assertEqual({1, 3}, min_max([1, 2, 3])),
    ?assertEqual({1, 3}, min_max([3, 2, 1])),
    ?assertEqual({1, 3}, min_max([2, 1, 3])).
