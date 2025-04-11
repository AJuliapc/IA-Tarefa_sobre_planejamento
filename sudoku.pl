% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Main planning predicate
plan(InitialState, FinalState, Plan) :-
    plan_step(InitialState, FinalState, [], RevPlan),
    reverse(RevPlan, Plan).

% Base case - verifica se o estado atual é um estado final válido
plan_step(State, State, Plan, Plan) :-
    is_complete(State).

% Recursive case
plan_step(CurrentState, FinalState, PartialPlan, Plan) :-
    find_empty(CurrentState, Row, Col),
    num(Num),
    is_valid(CurrentState, Row, Col, Num),
    fill_cell(CurrentState, Row, Col, Num, NewState),
    Action = fill(Row, Col, Num),
    plan_step(NewState, FinalState, [Action|PartialPlan], Plan).

% Verifica se o tabuleiro está completo e válido
is_complete(State) :-
    length(State, 4),
    maplist(is_valid_row, State),
    transpose(State, Columns),
    maplist(is_valid_row, Columns).

is_valid_row(Row) :-
    length(Row, 4),
    sort(Row, [1,2,3,4]).

% Find first empty cell
find_empty(State, Row, Col) :-
    nth1(Row, State, RowList),
    nth1(Col, RowList, 0).

% Validity check
is_valid(State, Row, Col, Num) :-
    \+ conflicts_row(State, Row, Num),
    \+ conflicts_column(State, Col, Num),
    \+ conflicts_box(State, Row, Col, Num).

% Check row conflicts
conflicts_row(State, Row, Num) :-
    nth1(Row, State, RowList),
    member(Num, RowList).

% Check column conflicts
conflicts_column(State, Col, Num) :-
    transpose(State, Transposed),
    nth1(Col, Transposed, ColList),
    member(Num, ColList).

% Check box conflicts
conflicts_box(State, Row, Col, Num) :-
    BoxRow is ((Row - 1) // 2) * 2 + 1,
    BoxCol is ((Col - 1) // 2) * 2 + 1,
    subgrid(State, BoxRow, BoxCol, Subgrid),
    member(Num, Subgrid).

% Extract subgrid
subgrid(State, BoxRow, BoxCol, Subgrid) :-
    BoxRow1 is BoxRow + 1,
    BoxCol1 is BoxCol + 1,
    nth1(BoxRow, State, Row1),
    nth1(BoxRow1, State, Row2),
    nth1(BoxCol, Row1, V1),
    nth1(BoxCol1, Row1, V2),
    nth1(BoxCol, Row2, V3),
    nth1(BoxCol1, Row2, V4),
    Subgrid = [V1,V2,V3,V4].

% Fill a cell
fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

% Replace helper
replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).

% Transpose a matrix
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
    lists_firsts_rests(Ms, Ts, Ms1),
    transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
    lists_firsts_rests(Rest, Fs, Oss).

% Print the state
print_state([]).
print_state([Row|Rest]) :-
    writeln(Row),
    print_state(Rest).

% Estado inicial
estado_inicial([
    [1,0,0,4],
    [0,0,0,0],
    [0,0,0,0],
    [3,0,0,2]
]).
