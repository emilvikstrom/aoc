-module(main).
-export([run/0]).


run() ->
    {ok, IODev} = file:open("../data/input", [read] ),
    Values = lists:reverse(handle_input(IODev)),
    find(Values, [], Values).

handle_input(IODev) ->
    handle_input(IODev, []).
handle_input(IODev, Vals) ->
    case file:read_line(IODev) of
	 eof ->
	    Vals;
	 {ok, Val} ->
	    TrimVal = string:trim(Val),
	    handle_input(IODev,[list_to_integer(TrimVal) | Vals]);
	_ ->
	    {error, unexpected_value}
    end.

%%If we haven't found the duplicate in first loop, reloop
find([], Delta, Original) ->
    find(Original, Delta, Original);
%%First iteration
find([Val | Next], [], Original) ->
    find(Next, [Val], Original);
find([Val | Next], [Sum|_] =  Delta, Original) ->
    NewSum = Val + Sum,
    case lists:member(NewSum, Delta) of
	true ->
	    NewSum;
	false ->
	    find(Next, [NewSum | Delta], Original)
    end.
	
    
    
