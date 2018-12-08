-module(main).
-export([run/0]).


-define(dbg(F,A), io:format("[~p:~p] "++F++"\n", [?MODULE, ?LINE | A])).

run() ->
    {ok, IODev} = file:open("../data/input", [read] ),
    Values = lists:reverse(handle_input(IODev)),
    Canvas = build_canvas(),
    Updated = place_on_canvas(Values, Canvas),
    count_multi(Updated).

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



build_canvas() ->
   build_columns().
build_columns() ->
    lists:foldl(fun(X, AccIn) ->
		    maps:put(X, build_rows(), AccIn)
		end, #{},lists:seq(0,999)).
build_rows() ->
    lists:foldl(fun(Y, AccIn) ->
		    maps:put(Y, 0, AccIn)
		end, #{}, lists:seq(0,999)).



place_on_canvas([], Canvas) -> Canvas;
place_on_canvas([ Val | Next], Canvas) ->
    UpdatedCanvas = update_canvas(Val, Canvas),
    #{ pos := Pos, size := Size} =  Val,
    place_on_canvas(Next, UpdatedCanvas).

    

update_canvas(Val, Canvas) ->
    update_row(Val, Canvas).
update_row(#{ pos := #{y := Y}, 
	      size := #{ysz := YSz}
	    } = Val, Canvas) ->
    lists:foldl(fun(Key, AccIn) ->
		    Row = maps:get(Key, Canvas),
		    UpdCol = update_columns(Val, Row),
		    maps:update(Key, UpdCol, AccIn)
		end, Canvas, lists:seq(Y, Y+YSz-1)).
update_columns(#{id := Id, pos := #{x := X}, size := #{xsz := XSz}}, Row) ->
    lists:foldl(fun(Key, AccIn) ->
		    Field = maps:get(Key, AccIn),
		    UpdField = update_field(Field, Id),
		    maps:update(Key, UpdField,AccIn)
		end, Row, lists:seq(X, X+XSz-1)).

update_field(0, Id) -> Id;
update_field(multi, _) -> multi;
update_field(Field, _) when is_list(Field)-> multi.

count_multi(Canvas) ->
    lists:foldl(fun(Key, AccIn) ->
		   AccIn + count_fields(maps:get(Key, Canvas)) 
		end, 0, maps:keys(Canvas)).

count_fields(Row) ->
    lists:foldl(fun(Key, AccIn) ->
		    case maps:get(Key, Row) of
			multi ->
			    AccIn + 1;
			_ -> AccIn
		    end
		end, 0, maps:keys(Row)).

