-module(main).
-export([run/0]).

run() ->
    {ok, IODev} = file:open("../data/input", [read] ),
    Values = lists:reverse(handle_input(IODev)),
    Matrix = build_matrix(),
    place_on_matrix(Values, Matrix) ->

handle_input(IODev) ->
    handle_input(IODev, []).
handle_input(IODev, Vals) ->
    case file:read_line(IODev) of
	 eof ->
	    Vals;
	 {ok, Val} ->
	    [Id, _, Pos, Size] = string:tokens(Val, " "),
	    [XSz,YSz] = string:tokens(Size, "x"),
	    [X,Y] = string:tokens(lists:flatten(string:tokens(Pos,":")),","),
	    TrimVal = string:trim(Val),
	    handle_input(IODev,[#{id => Id, 
				    pos => #{x => X, y => Y }, 
				    size => #{xsz => XSz, ysz => YSz} } | Vals]);
	_ ->
	    {error, unexpected_value}
    end.

build_matrix() ->
    Cols = lists:flatten(["." || _ <- lists:seq(1,1000)]),
    Matrix = [Cols || _ <- lists:seq(1,1000)].

place_on_matrix([#{id := Id, 
		    pos := #{x := X, y := Y}, 
		    size := #{ xsz := XSz, ysz := YSz}} | Rest], Matrix) ->
    
    
    

read_matrix({X, Y}, Matrix) ->
    Cols = lists:nth(Y, Matrix),
    lists:nth(X, Cols).

update_matrix(Rectangle, X, Y, Matrix) ->
   %%TODO 

get_rect({X,Y}, {XSz, YSz}, Matrix) ->
    Rows = lists:sublist(Matrix, Y, YSz),
    [lists:sublist(Row, X, XSz) || Row <- Rows].

fill_rect([], Acc) -> lists:reverse(Acc);
fill_rect([Row | Next], Acc) ->
    fill_rect(Next, [fill(Row,<<>>) | Acc]).

fill(<<"."/binary, Rest/binary>>, Acc) ->
    fill(Rest, <<Acc/binary, "U"/binary>>);
fill(<<"U"/binary, Rest/binary>>, Acc) ->
    fill(Rest, <<Acc/binary, "X"/binary>>);
fill(<<"X"/binary, Rest/binary, Acc) ->
    fill(Rest, <<Acc/binary, "X"/binary>>);
fill(<<>>, Acc) -> Acc.

    
    
