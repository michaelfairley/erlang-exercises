-module(time).
-include_lib("eunit/include/eunit.hrl").
-export([swedish_date/0]).

swedish_date() -> swedish_date(date()).
swedish_date({Year, Month, Day}) ->
    lists:flatten(io_lib:format("~s~2..0B~2..0B", [last2(integer_to_list(Year)), Month, Day])).

last2(L) ->
    TwoFromEnd = length(L) - 2,
    lists:nthtail(TwoFromEnd, L).

swedish_date_test() ->
    ?assertEqual("080901", swedish_date({2008, 9, 1})),
    ?assertEqual("081011", swedish_date({2008, 10, 11})).
