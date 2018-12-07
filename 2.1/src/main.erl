-module(main).
-export([run/0]).


run() ->
    {ok, IODev} = file:open("../data/input", [read] ),
    Values = lists:reverse(handle_input(IODev)),
    count_commons(Values).

handle_input(IODev) ->
    handle_input(IODev, []).
handle_input(IODev, Vals) ->
    case file:read_line(IODev) of
	 eof ->
	    Vals;
	 {ok, Val} ->
	    TrimVal = string:trim(Val),
	    handle_input(IODev,[TrimVal | Vals]);
	_ ->
	    {error, unexpected_value}
    end.

%%Init loop
count_commons(Vals) -> count_commons(Vals, #{doubles => 0, triples => 0}).
%%End loop, calculate checksum
count_commons([], #{doubles := D, triples := T}) -> 
    D*T;
count_commons([String | Rest], #{doubles := Dou, triples := Tri} = Res) ->
    %%Sort String and make it binary
    Sorted = lists:sort(String),
    BinSortStr = list_to_binary(Sorted),
    case find_commons(BinSortStr, {0,0}) of
	{0,0} -> count_commons(Rest, Res);
	{_,0} -> count_commons(Rest, Res#{doubles => Dou+1});
	{0,_} -> count_commons(Rest, Res#{triples => Tri+1});
	{_,_} -> count_commons(Rest, #{doubles => Dou+1, triples => Tri+1})
    end. 

%%Find commons take a sorted binarylist as argument

%%Case first three bytes are the same, we have a triple
find_commons(<<A:1/binary, A:1/binary, A:1/binary, Rest/binary>>, {Doubles, Triples}) ->
    find_commons(Rest, {Doubles, Triples+1});
%%Case first two
find_commons(<<A:1/binary, A:1/binary, Rest/binary>>, {Doubles, Triples}) ->
    find_commons(Rest, {Doubles+1, Triples});

%%No commons
find_commons(<<_:1/binary, Rest/binary>>, Acc) ->
    find_commons(Rest, Acc);

%%End case
find_commons(<<>>, Acc) -> Acc.


