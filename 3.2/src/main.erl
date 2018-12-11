-module(main).
-export([run/0, place_rectangle/2]).
-define(dbg(F,A), io:format("[~p:~p] "++F++"\n", [?MODULE, ?LINE | A])).
-define(MAPSIZE, 1000).
-define(SINGLE, <<"S">>).
-define(MULTI, <<"M">>).
-define(INPUT, "../data/input").


run() ->
    {ok, IODev} = file:open(?INPUT, [read] ),
    Values = lists:reverse(handle_input(IODev)),
    Canvas = canvas:build(?MAPSIZE),
    Placed = lists:foldl(fun(Val, AccIn) ->
		    place_rectangle(Val, AccIn)
		end, Canvas, Values),
    scan_canvas_single(Values, Placed). 
    %count_multi(Placed).

handle_input(IODev) ->
    handle_input(IODev, []).
handle_input(IODev, Vals) ->
    case file:read_line(IODev) of
	 eof ->
	    Vals;
	 {ok, Val} ->
	    TrimVal = string:trim(Val),
	    [Id, _, Pos, Size] = string:tokens(TrimVal, " "),
	    [XSz,YSz] = string:tokens(Size, "x"),
	    [X,Y] = string:tokens(lists:flatten(string:tokens(Pos,":")),","),
	    handle_input(IODev,[#{id => Id, 
				    pos => #{x => list_to_integer(X), y => list_to_integer(Y) }, 
				    size => #{xsz => list_to_integer(XSz), ysz => list_to_integer(YSz)} } | Vals]);
	_ ->
	    {error, unexpected_value}
    end.

place_rectangle(#{id := Id, pos := #{x := X, y := Y}, size := #{xsz := Xsz, ysz := Ysz}}, Canvas) ->
    lists:foldl(fun(YVal, AccY) ->
		    lists:foldl(fun(XVal, AccX) ->
				    canvas:insert(Id, XVal, YVal, AccX)
				end, AccY, lists:seq(X, X+Xsz-1))
		end, Canvas, lists:seq(Y, Y+Ysz-1)).

count_multi(Canvas) ->
    lists:foldl(fun(Y, Acc1) ->
		    Acc1 + lists:foldl(fun(X, Acc2) ->
			case canvas:read(X, Y, Canvas) of
			    multi -> Acc2 + 1;
			    _ -> Acc2
			end
		    end, 0, lists:seq(0, ?MAPSIZE-1))
		end,0, lists:seq(0, ?MAPSIZE-1)).


scan_canvas_single(Values, Canvas) ->
    scan_canvas_single(Values, Canvas, []).

scan_canvas_single([], _, NonDisrupted) -> NonDisrupted;
scan_canvas_single([
		    #{id := Id, 
		      pos := #{x := X, y := Y}, 
		      size := #{xsz := Xsz, ysz := Ysz}} = Value| Next], 
		      Canvas, NonDisrupted) ->
    Rectangle = read_rectangle(Value, Canvas),
    case check_single_value(Rectangle) of
	true ->
	    io:format("true~n"),
	    scan_canvas_single(Next, Canvas, [Id | NonDisrupted]);
	false ->
	    scan_canvas_single(Next, Canvas, NonDisrupted)
    end.

read_rectangle(#{ pos := #{x := X, y := Y}, size := #{xsz := Xsz, ysz := Ysz}}, Canvas) ->
    RowKeys = lists:seq(Y, Y+Ysz-1),
    EntryKeys = lists:seq(X, X+Xsz-1),
    Rows = maps:with(RowKeys,Canvas),
    lists:foldl(fun(YVal, AccIn) ->
		    Row = maps:get(YVal, AccIn),
		    maps:update(YVal, maps:with(EntryKeys,Row), AccIn)
		end, Rows, RowKeys).

check_single_value(Rectangle) ->
   Tmp = lists:usort(lists:foldl(fun(Y, Acc1) -> 
		    Row = maps:get(Y, Rectangle),
		    lists:flatten([lists:foldl(fun(X, Acc2) ->
				    [canvas:read(X,Y, Rectangle) | Acc2]
				end,[], maps:keys(Row)) | Acc1])
	       end, [], maps:keys(Rectangle))),
    io:format("~p~n",[Tmp]),
    not lists:member(multi, Tmp).
