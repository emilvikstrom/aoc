-module(main).
-export([run/0]).

run() ->
    {ok, IODev} = file:open("../data/input", [read] ),
    Values = lists:reverse(handle_input(IODev)),
    Matrix = build_matrix().

handle_input(IODev) ->
    handle_input(IODev, []).
handle_input(IODev, Vals) ->
    case file:read_line(IODev) of
	 eof ->
	    Vals;
	 {ok, Val} ->
	    [Id, _, Pos, Size] = string:tokens(Val, " "),
	    TrimVal = string:trim(Val),
	    handle_input(IODev,[#{id => Id, pos => Pos, size => Size} | Vals]);
	_ ->
	    {error, unexpected_value}
    end.

build_matrix() ->
    Cols = lists:flatten(["." || _ <- lists:seq(1,1000)]),
    Matrix = [Cols || _ <- lists:seq(1,1000)].


