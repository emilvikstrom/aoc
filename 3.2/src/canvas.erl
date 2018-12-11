-module(canvas).
-export([build/1, insert/4, read/3, print/1]).


build(Size)->
    lists:foldl(fun(Y,AccIn) ->
		    AccIn#{Y => build_row(Size)}
		end, #{}, lists:seq(0,Size-1)).

build_row(Size) ->
    lists:foldl(fun(X, AccIn) ->
		    AccIn#{X => 0}
	        end,#{},lists:seq(0, Size-1)).

read(X,Y, Canvas) ->
    Row = maps:get(Y, Canvas),
    read_row(X, Row).

read_row(X, Row) -> 
    maps:get(X, Row).
    
insert(Value, X, Y, Canvas) ->
    Row = maps:get(Y, Canvas),
    NewRow = edit_row(X, Value, Row),
    maps:update(Y, NewRow, Canvas).

edit_row(X, Val, Row) ->
    case maps:get(X, Row) of
	0 -> maps:update(X, Val, Row);
	A -> maps:update(X, multi, Row)
    end.

print(Canvas) ->
    lists:foreach(fun(Key) ->
		      Row = maps:get(Key, Canvas),
		      print_row(Row)
		  end, lists:sort(maps:keys(Canvas))).

print_row(Row) ->
    XString = lists:flatten([["~p" || _ <- lists:sort(maps:keys(Row))] ++ "\n"]),
    XVal = [
	    case maps:get(Key, Row) of
		multi -> 9;
		0 -> 0;
		_Id -> 1 
	    end || Key <- lists:sort(maps:keys(Row))],
    io:format(XString, XVal).
