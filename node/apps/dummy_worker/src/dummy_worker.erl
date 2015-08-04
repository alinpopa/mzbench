-module(dummy_worker).

-export([initial_state/0, metrics/0,
         print/3, test_method/3, do_stuff/2, do_stuff2/2]).

-type state() :: string().

-spec initial_state() -> state().
initial_state() -> "".

metrics() -> [[{"print", counter}, {"print_2", counter}], {"dummy", histogram}, {"stuff", counter}].

print(State, Meta, Text) ->
    _ = mzb_metrics:notify("print", 1),
    _ = mzb_metrics:notify("print_2", 2),
    N = random:uniform(1000000000),
    _ = mzb_metrics:notify({"dummy", histogram}, N/7),
    lager:info("Appending ~p, Meta: ~p~n", [Text, Meta]),
    {nil, State}.

% just load cpu with smth
do_stuff(State, _Meta) ->
    N = random:uniform(1000000),
    _ = mzb_metrics:notify({"stuff", counter}, 1),
    _ = mzb_metrics:notify({"dummy", histogram}, N),
    case State of
        [_|Tail] when length(State) > 10000 -> {nil, Tail ++ [N]};
        _ -> {nil, [N|State]}
    end.

do_stuff2(State, _Meta) ->
    N = random:uniform(1000000),
    case State of
        [_|Tail] when length(State) > 10000 -> {nil, Tail ++ [N]};
        _ -> {nil, [N|State]}
    end.

test_method(State, _Meta, Text) ->
    {nil, Text ++ State}.
