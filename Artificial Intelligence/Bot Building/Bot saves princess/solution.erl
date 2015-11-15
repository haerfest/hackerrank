-module(solution).
-export([main/0]).

-define(NO_PROMPT, "").

main() ->
    {ok, [N]} = io:fread(?NO_PROMPT, "~d"),
    {Bot, Princess} = read_grid(N),
    Steps = path(Bot, Princess),
    print(Steps).

read_grid(N) ->
    read_grid(0, N, undefined, undefined).

read_grid(_MaxRow, _MaxRow, Bot, Princess) ->
    {Bot, Princess};
read_grid(Row, MaxRow, Bot, Princess) ->
    {ok, [String]} = io:fread(?NO_PROMPT, "~s"),
    NewBot = find($m, String, Row, Bot),
    NewPrincess = find($p, String, Row, Princess),
    read_grid(Row + 1, MaxRow, NewBot, NewPrincess).

find(Character, String, Row, Pos) ->
    case string:chr(String, Character) of
        0 -> Pos;
        N -> {Row, N - 1}   % index starts at one
    end.

path(From, To) ->
    path(From, To, []).

path(_To, _To, Steps) ->
    lists:reverse(Steps);
path({SameRow, FromCol}, {SameRow, ToCol} = To, Steps) ->
    case ToCol > FromCol of
        true ->
            path({SameRow, FromCol + 1}, To, ['RIGHT' | Steps]);
        false ->
            path({SameRow, FromCol - 1}, To, ['LEFT' | Steps])
    end;
path({FromRow, Col}, {ToRow, _} = To, Steps) ->
    case ToRow > FromRow of
        true ->
            path({FromRow + 1, Col}, To, ['DOWN' | Steps]);
        false ->
            path({FromRow - 1, Col}, To, ['UP' | Steps])
    end.

print(Steps) ->
    F = fun(Step) ->
        io:format("~s~n", [Step])
    end,
    lists:foreach(F, Steps).
