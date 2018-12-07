-module(main).
-export([run/0]).


run() ->
    {ok, IODev} = file:open("../data/input", [read] ),
    handle_input(IODev).

handle_input(IODev) ->
    handle_input(IODev, 0).
handle_input(IODev, Sum) ->
    case file:read_line(IODev) of
	 eof ->
	    Sum;
	 {ok, Val} ->
	    TrimVal = string:trim(Val),
	    handle_input(IODev, Sum + list_to_integer(TrimVal));
	_ ->
	    {error, unexpected_value}
    end.
