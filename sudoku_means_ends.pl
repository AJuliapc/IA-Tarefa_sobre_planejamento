% --- TENTATIVA DE IMPLEMENTAÇÃO MEA (Simplificada e Experimental) ---

% NOTA: Este código é conceitual, pode ser ineficiente e propenso a loops.
% A versão anterior (Backtracking Guiado) é provavelmente mais robusta.

% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Dimensões
max_row(4).
max_col(4).

% Main planning predicate
plan(InitialState, FinalState, Plan) :-
    plan_mea(InitialState, FinalState, [], RevPlan), % Chama o planejador MEA
    reverse(RevPlan, Plan).

% MEA Planner - Caso Base
plan_mea(FinalState, FinalState, Plan, Plan) :- !. % Objetivo alcançado

% MEA Planner - Caso Recursivo
plan_mea(CurrentState, FinalState, PartialPlan, Plan) :-
    % 1. Encontrar UMA diferença principal (célula vazia com valor alvo diferente)
    %    (Estratégia simples: pega a primeira que encontrar)
    find_difference(CurrentState, FinalState, R, C, TargetN), !,
    % writef('MEA: Found difference at (%w, %w), target: %w\n', [R, C, TargetN]),

    % 2. Operador desejado para esta diferença
    Operator = fill(R, C, TargetN),

    % 3. Verificar pré-condições (is_valid)
    ( is_valid(CurrentState, R, C, TargetN) ->
        % 3a. PRÉ-CONDIÇÕES OK: Aplica o operador e continua MEA
        % writef('  Operator %w is valid. Applying.\n', [Operator]),
        fill_cell(CurrentState, R, C, TargetN, NextState),
        plan_mea(NextState, FinalState, [Operator | PartialPlan], Plan)

    ; % 3b. PRÉ-CONDIÇÕES FALHARAM: Tentar resolver o bloqueio (Parte MEA Simplificada)
        % writef('  Operator %w is NOT valid.\n', [Operator]),
        % i. Identificar o bloqueador (simplificado: encontra a primeira célula conflitante)
        find_blocker(CurrentState, R, C, TargetN, BR, BC), % Encontra célula (BR, BC) que causa o conflito
        % writef('    Blocker found at (%w, %w).\n', [BR, BC]),

        % ii. Mudar o foco: Tentar resolver o bloqueador PRIMEIRO.
        %     Obter o valor alvo do bloqueador.
        get_cell(FinalState, BR, BC, BlockerTargetN),
        % writef('    Shifting focus to blocker. Target: %w\n', [BlockerTargetN]),

        % iii. Tentar aplicar o operador para o BLOQUEADOR
        BlockerOperator = fill(BR, BC, BlockerTargetN),
        ( is_valid(CurrentState, BR, BC, BlockerTargetN) ->
            % Se o operador do bloqueador for válido AGORA, aplica-o e continua MEA
            % writef('      Blocker operator %w is valid. Applying.\n', [BlockerOperator]),
            fill_cell(CurrentState, BR, BC, BlockerTargetN, NextStateFromBlocker),
            plan_mea(NextStateFromBlocker, FinalState, [BlockerOperator | PartialPlan], Plan)
        ;
            % Se NEM o operador do bloqueador for válido, a situação é complexa.
            % MEA pura exigiria sub-objetivo para o bloqueador do bloqueador...
            % Esta versão simplificada simplesmente FALHA aqui, forçando o backtracking
            % a encontrar OUTRA diferença inicial em find_difference (se houver).
            % writef('      Blocker operator %w is ALSO not valid. Failing this path.\n', [BlockerOperator]),
            fail
        )
    ).


% --- Predicados Auxiliares para MEA ---

% find_difference(+Current, +Final, -R, -C, -N)
% Encontra a primeira célula (R,C) que é 0 em Current e N em Final.
find_difference(Current, Final, R, C, N) :-
    nth1(R, Current, CurrentRow),
    nth1(C, CurrentRow, 0), % Encontra célula vazia em Current
    nth1(R, Final, FinalRow),
    nth1(C, FinalRow, N),   % Obtém o valor N que deveria estar lá
    N \= 0.                 % Garante que o alvo não seja 0 (embora não deva ser no Sudoku)

% find_blocker(+State, +R, +C, +N, -BR, -BC)
% Encontra as coordenadas (BR, BC) de UMA célula que impede N de ser colocado em (R, C).
% Simplificado: retorna a primeira encontrada.
find_blocker(State, R, C, N, BR, BC) :-
    % Verifica linha
    nth1(R, State, RowList),
    nth1(BC, RowList, N), % Encontra N na coluna BC da mesma linha R
    BC \= C, BR = R, !.   % Garante que não é a própria célula e corta
find_blocker(State, R, C, N, BR, BC) :-
    % Verifica coluna
    column(State, C, ColList),
    nth1(BR, ColList, N), % Encontra N na linha BR da mesma coluna C
    BR \= R, BC = C, !.   % Garante que não é a própria célula e corta
find_blocker(State, R, C, N, BR, BC) :-
    % Verifica bloco
    subgrid_coords(R, C, SubRow1, SubCol1, SubRow2, SubCol2), % Obtém limites do bloco
    between(SubRow1, SubRow2, BR), % Itera linhas do bloco
    between(SubCol1, SubCol2, BC), % Itera colunas do bloco
    (BR \= R ; BC \= C),           % Garante que não é a célula original (R,C)
    get_cell(State, BR, BC, N),    % Verifica se a célula (BR, BC) contém N
    !.                             % Corta na primeira encontrada

% --- Predicados Comuns (Validação, Manipulação, etc.) ---

get_cell(State, R, C, Value) :-
    nth1(R, State, RowList),
    nth1(C, RowList, Value).

is_valid(State, Row, Col, Num) :-
    % Verifica se a célula está vazia (necessário para MEA, pois podemos tentar preencher não-vazias)
    get_cell(State, Row, Col, CurrentVal),
    (CurrentVal == 0 -> true ; fail), % Falha se a célula não estiver vazia
    % Verifica conflitos
    nth1(Row, State, RowList), \+ memberchk(Num, RowList),
    column(State, Col, ColumnList), \+ memberchk(Num, ColumnList),
    subgrid(State, Row, Col, Subgrid), \+ memberchk(Num, Subgrid).

column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
    nth1(Col, Row, Value),
    column(Rest, Col, Values).

% Helper para obter coordenadas do subgrid
subgrid_coords(Row, Col, R1, C1, R2, C2) :-
    R1 is ((Row - 1) // 2) * 2 + 1,
    C1 is ((Col - 1) // 2) * 2 + 1,
    R2 is R1 + 1,
    C2 is C1 + 1.

subgrid(State, Row, Col, Subgrid) :-
    subgrid_coords(Row, Col, R1, C1, R2, C2),
    nth1(R1, State, Row1), nth1(R2, State, Row2),
    nth1(C1, Row1, A), nth1(C2, Row1, B),
    nth1(C1, Row2, C), nth1(C2, Row2, D),
    Subgrid = [A, B, C, D].

fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).