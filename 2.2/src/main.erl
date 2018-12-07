-module(main).
-export([run/0]).


run() ->
    {ok, IODev} = file:open("../data/input", [read] ),
    Values = lists:reverse(handle_input(IODev)),
    find_one_off(Values,[]).

handle_input(IODev) ->
    handle_input(IODev, []).
handle_input(IODev, Vals) ->
    case file:read_line(IODev) of
	 eof ->
	    Vals;
	 {ok, Val} ->
	    TrimVal = string:trim(Val),
	    handle_input(IODev,[list_to_binary(TrimVal) | Vals]);
	_ ->
	    {error, unexpected_value}
    end.

find_one_off([], Acc) -> lists:flatten(Acc);
find_one_off([String | Vals], Acc) ->
    Res = lists:foldl(fun(Compare, AccIn) ->
		    [compare_strings(String, Compare, 0, <<>>) | AccIn]
		end, [], Vals),
    find_one_off(Vals, [Res | Acc]).


%%Have a common
compare_strings(<<A:1/binary, AR/binary>>, <<A:1/binary, BR/binary>>, Diff, Res) when Diff < 2 ->
    compare_strings(AR, BR, Diff, <<Res/binary, A/binary>> );
compare_strings(<<A:1/binary, AR/binary>>, <<B:1/binary, BR/binary>>, Diff, Res) when Diff < 2 ->
    compare_strings(AR, BR, Diff+1, Res);
compare_strings(<<>>,_, Diff, Res) when Diff < 2 -> Res;
compare_strings(_,_,_,_) -> [].
