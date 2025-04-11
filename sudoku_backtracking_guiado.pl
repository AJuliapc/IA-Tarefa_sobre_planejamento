% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Dimensões
max_row(4).
max_col(4).

% Main planning predicate
plan(InitialState, FinalState, Plan) :-
    plan_step(InitialState, FinalState, [], RevPlan),
    reverse(RevPlan, Plan).

% Base case: If CurrentState matches FinalState, stop.
plan_step(FinalState, FinalState, Plan, Plan).

% --- Recursive case MODIFICADO: Backtracking Simples + Prioridade no Valor Alvo ---
plan_step(CurrentState, FinalState, PartialPlan, Plan) :-
    % 1. Encontra a PRIMEIRA célula vazia (Row, Col)
    nth1(Row, CurrentState, RowList),
    nth1(Col, RowList, 0), !, % Encontra a primeira e corta (não busca outras células neste nível)

    % 2. Obtém o número N que esta célula DEVERIA ter no FinalState
    get_cell(FinalState, Row, Col, TargetNum),

    % 3. TENTA preencher com o TargetNum PRIMEIRO
    ( is_valid(CurrentState, Row, Col, TargetNum) ->
        % 3a. SE TargetNum é válido AGORA: Usa-o!
        fill_cell(CurrentState, Row, Col, TargetNum, NewState),
        Action = fill(Row, Col, TargetNum),
        plan_step(NewState, FinalState, [Action | PartialPlan], Plan)

    ; % 3b. SE TargetNum NÃO é válido agora:
      %     Tenta OUTROS números válidos (N \= TargetNum)
        num(OtherNum),
        OtherNum \= TargetNum, % Garante que não é o número alvo (já tentado implicitamente)
        is_valid(CurrentState, Row, Col, OtherNum), % Verifica se o outro número é válido
        fill_cell(CurrentState, Row, Col, OtherNum, NewStateOther),
        ActionOther = fill(Row, Col, OtherNum),
        plan_step(NewStateOther, FinalState, [ActionOther | PartialPlan], Plan)
    ).


% --- Predicados Auxiliares ---

get_cell(State, R, C, Value) :-
    nth1(R, State, RowList),
    nth1(C, RowList, Value).

is_empty(State, R, C) :-
    nth1(R, State, RowList),
    nth1(C, RowList, 0).

% --- Predicados Comuns (Validação, Manipulação) ---

is_valid(State, Row, Col, Num) :-
    nth1(Row, State, RowList), \+ memberchk(Num, RowList),
    column(State, Col, ColumnList), \+ memberchk(Num, ColumnList),
    subgrid(State, Row, Col, Subgrid), \+ memberchk(Num, Subgrid).

column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
    nth1(Col, Row, Value),
    column(Rest, Col, Values).

subgrid(State, Row, Col, Subgrid) :-
    SubRow1 is ((Row - 1) // 2) * 2 + 1,
    SubCol1 is ((Col - 1) // 2) * 2 + 1,
    SubRow2 is SubRow1 + 1,
    SubCol2 is SubCol1 + 1,
    nth1(SubRow1, State, Row1), nth1(SubRow2, State, Row2),
    nth1(SubCol1, Row1, A), nth1(SubCol2, Row1, B),
    nth1(SubCol1, Row2, C), nth1(SubCol2, Row2, D),
    Subgrid = [A, B, C, D].

fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).