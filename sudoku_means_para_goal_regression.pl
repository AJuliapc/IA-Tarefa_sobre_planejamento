% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Dimensões
max_row(4).
max_col(4).

% --- PREDICADO PRINCIPAL COM GOAL REGRESSION ---
plan(InitialState, FinalState, Plan) :-
    plan_regression(InitialState, FinalState, RevPlan), % Chama o planejador GR
    reverse(RevPlan, Plan). % Reverte o plano encontrado

% --- PLANEJADOR GOAL REGRESSION ---

% Base case: O estado objetivo atual (CurrentGoal) é o mesmo que o InitialState.
% O plano (reverso) para chegar aqui a partir do InitialState é vazio.
plan_regression(InitialState, InitialState, []) :- !.

% Recursive step: Regride do CurrentGoal para um estado anterior (RegressedGoal)
plan_regression(InitialState, CurrentGoal, [Action | RestRevPlan]) :-
    % 1. Encontra uma célula (R, C) com valor N no CurrentGoal,
    %    que era 0 no InitialState. Backtrack aqui tentará outras células se necessário.
    find_filled_difference(CurrentGoal, InitialState, R, C, N),

    % 2. Esta é a ação que assumimos ter sido a última para alcançar CurrentGoal
    Action = fill(R, C, N),

    % 3. Calcula o estado anterior (RegressedGoal) "desfazendo" a ação
    %    (Colocando 0 de volta onde N estava no CurrentGoal)
    fill_cell(CurrentGoal, R, C, 0, RegressedGoal),

    % 4. Recursivamente encontra o plano (reverso) do InitialState até o RegressedGoal
    plan_regression(InitialState, RegressedGoal, RestRevPlan).


% --- Predicados Auxiliares para Goal Regression ---

% find_filled_difference(+CurrentGoal, +InitialState, -R, -C, -N)
% Encontra as coordenadas (R, C) e valor N de uma célula tal que
% CurrentGoal tem N (\= 0) em (R, C) e InitialState tem 0 em (R, C).
% Permite backtracking para encontrar outras diferenças.
find_filled_difference(CurrentGoal, InitialState, R, C, N) :-
    max_row(MaxR), max_col(MaxC),
    between(1, MaxR, R),          % Gera linhas
    between(1, MaxC, C),          % Gera colunas
    get_cell(CurrentGoal, R, C, N), % Obtém valor N do CurrentGoal
    N \= 0,                       % Deve ser um valor preenchido
    get_cell(InitialState, R, C, 0). % Deve ter sido 0 inicialmente

% --- Predicados Comuns Necessários ---
% (Mantidos pois são usados pela lógica de regressão ou seus auxiliares)

get_cell(State, R, C, Value) :-
    nth1(R, State, RowList),
    nth1(C, RowList, Value).

fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).

% --- Predicados NÃO UTILIZADOS pela Goal Regression (removidos/ignorados) ---
% find_difference/5 (MEA)
% find_blocker/6 (MEA)
% is_valid/4 (Usado por MEA e Backtracking, não pela regressão pura)
% column/3 (Usado por is_valid)
% subgrid_coords/6 (Usado por find_blocker e subgrid)
% subgrid/4 (Usado por is_valid)
% plan_mea/4 (Lógica MEA substituída)