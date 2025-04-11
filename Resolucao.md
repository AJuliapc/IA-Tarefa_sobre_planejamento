# RESOLUÇÃO DA ATIVIDADE 

Análise o código em Prolog para planejamento, que não está funcionando, e responda as questões:

```prolog

%%%%%%%%%%%%%%%%%%%%%%%%%%%¢
% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Main planning predicate
plan(InitialState, FinalState, Plan) :-
% Copy InitialState to work on it
copy_term(InitialState, CurrentState),
% Generate the plan by filling empty cells
plan_step(CurrentState, FinalState, [], Plan).

% Base case: If CurrentState matches FinalState, stop.
plan_step(FinalState, FinalState, Plan, Plan).

% Recursive case: Find an empty cell, fill it, and continue.
plan_step(CurrentState, FinalState, PartialPlan, Plan) :-
% Find an empty cell (0) at (Row, Col)
nth1(Row, CurrentState, RowList),
nth1(Col, RowList, 0),
% Try filling it with Num (1-4)
num(Num),
% Check if Num is valid (no conflicts)
is_valid(CurrentState, Row, Col, Num),
% Fill the cell
fill_cell(CurrentState, Row, Col, Num, NewState),
% Record the action
Action = fill(Row, Col, Num),
% Continue planning
plan_step(NewState, FinalState, [Action | PartialPlan], Plan).

% Check if Num can be placed at (Row, Col) without conflicts
is_valid(State, Row, Col, Num) :-
% Check Row
nth1(Row, State, RowList),
\+ member(Num, RowList),
% Check Column
column(State, Col, ColumnList),
\+ member(Num, ColumnList),
% Check 2x2 sub-square
subgrid(State, Row, Col, Subgrid),
\+ member(Num, Subgrid).

% Extract a column from the grid
column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
nth1(Col, Row, Value),
column(Rest, Col, Values).

% Extract the 2x2 subgrid containing (Row, Col)
subgrid(State, Row, Col, Subgrid) :-
% Determine top-left corner of the subgrid
SubRow is ((Row
1) // 2) * 2 + 1,
SubCol is ((Col
1) // 2) * 2 + 1,
% Extract 4 cells
nth1(SubRow, State, Row1),
nth1(SubRow + 1, State, Row2),
nth1(SubCol, Row1, A), nth1(SubCol + 1, Row1, B),
nth1(SubCol, Row2, C), nth1(SubCol + 1, Row2, D),
Subgrid = [A, B, C, D].
% Fill cell (Row, Col) with Num
fill_cell(State, Row, Col, Num, NewState) :-
nth1(Row, State, RowList),
replace(RowList, Col, Num, NewRowList),
replace(State, Row, NewRowList, NewState).

% Helper: Replace element at position in a list
replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
Pos > 1,
NextPos is Pos
1,
replace(T, NextPos, X, NewT).
%#### **Query**
?plan(InitialState, FinalState, Plan).

% #### **Output (One Possible Solution)**

FinalState = [
[1, 3, 4, 2],
[4, 2, 1, 3],
[2, 4, 3, 1],
[3, 1, 2, 4]
],
Plan = [
fill(1, 2, 3), fill(1, 3, 4), fill(1, 4, 2),
fill(2, 1, 4), fill(2, 3, 1), fill(2, 4, 3),
fill(3, 1, 2), fill(3, 2, 4), fill(3, 4, 1),
fill(4, 1, 3), fill(4, 2, 1), fill(4, 3, 2)
].

```

___

# **1. Explique o porquê não funciona**

Para fazer essa verificação o código foi compilado através do SWISH com o seguinte comando:

```prolog
plan(InitialState, FinalState, Plan).
```

Esse código compilado mostra que há múltiplos erros de sintaxe, impedindo qualquer execução e, mais especificamente, sua saída na compilação data os seguintes erros:
* Syntax error: Operator expected
* Syntax error: Operator expected
* Syntax error: Operator expected
* Syntax error: End of file in quoted codes
procedure `subgrid(A,B,C,D)' does not exist
Reachable from:
	  is_valid(A,B,C,D)
	  plan_step(A,B,C,D)
	  plan(A,B,C)

Detalhando esses erros há o seguinte levantamento:
1. Syntax error: Operator expected: Este erro aparece múltiplas vezes, sendo explicitamente apontado na linha 72 (NextPos is Pos) e implícito nos erros gerais listados à direita. Isso ocorre porque nas linhas onde se tenta fazer subtração (SubRow is ((Row 1)..., SubCol is ((Col 1)..., NextPos is Pos 1), o operador de subtração (-) está ausente.
2. Syntax error: End of file in quoted codes: Este erro, apontado próximo à linha 77 (```) e listado no painel direito, ocorre porque o código contém texto que não é sintaxe válida de Prolog nem comentários padrão (% ou /* ... */). Especificamente, as linhas com #### **Query**, #### **Output...** e os delimitadores ``` são interpretados incorretamente pelo parser Prolog, que falha ao encontrar o fim do arquivo sem fechar alguma estrutura que ele pensou ter iniciado (como um átomo entre aspas).
3. procedure subgrid(A,B,C,D) does not exist: Este não é um erro primário, mas uma consequência dos erros de sintaxe. Como a definição do predicado subgrid/4 contém erros de sintaxe (a falta do operador -), o Prolog não consegue carregar/compilar essa regra corretamente. Portanto, quando o predicado is_valid/4 tenta chamar subgrid/4, o sistema informa que ele não existe, pois sua definição falhou durante a compilação devido aos erros de sintaxe. 

# **2. Indique como pode ser alterado para funcionar**

Para corrigir os erros enumerados e permitir que o código seja compilado e executado:

1.  **Corrigir Operadores de Subtração:** Adicione o operador `-` onde a subtração é pretendida:
    *   Dentro de `subgrid/4`:
        ```prolog
        SubRow is ((Row - 1) // 2) * 2 + 1,  % Adicionar '-'
        SubCol is ((Col - 1) // 2) * 2 + 1,  % Adicionar '-'
        ```
    *   Dentro de `replace/4`:
        ```prolog
        NextPos is Pos - 1, % Adicionar '-'
        ```

2.  **Remover/Corrigir Texto Não-Prolog:** Remova ou comente corretamente todo o texto que não faz parte do código Prolog válido. Isso inclui:
    *   Remover as linhas com `#### **Query**` e `#### **Output (One Possible Solution)**`.
    *   Remover as linhas com ` ``` `.
    *   Remover a seção de exemplo de `FinalState` e `Plan` do arquivo de código. Comentários em Prolog devem começar com `%` ou estar entre `/*` e `*/`. A query `?- plan(InitialState, FinalState, Plan).` deve ser inserida na área de consulta do SWISH, não no corpo do código principal.

# **3. Implemente a mudança e mostre funcionando**

Comnado para rodar a codificação

```prolog 
InitialState = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]],
   FinalState = [[1, 3, 4, 2], [4, 2, 1, 3], [2, 4, 3, 1], [3, 1, 2, 4]],
   plan(InitialState, FinalState, Plan).
```

Codificação 

```prolog 
% Define numbers 1-4
num(1). num(2). num(3). num(4).

% Main planning predicate
plan(InitialState, FinalState, Plan) :-
    plan_step(InitialState, FinalState, [], RevPlan),
    reverse(RevPlan, Plan).

% Base case: If CurrentState matches FinalState, stop.
plan_step(FinalState, FinalState, Plan, Plan).

% Recursive case: Find an empty cell, fill it, and continue.
plan_step(CurrentState, FinalState, PartialPlan, Plan) :-
    nth1(Row, CurrentState, RowList),
    nth1(Col, RowList, 0),
    num(Num),
    is_valid(CurrentState, Row, Col, Num),
    fill_cell(CurrentState, Row, Col, Num, NewState),
    Action = fill(Row, Col, Num),
    plan_step(NewState, FinalState, [Action | PartialPlan], Plan).

% Check if Num can be placed at (Row, Col) without conflicts
is_valid(State, Row, Col, Num) :-
    nth1(Row, State, RowList),
    \+ memberchk(Num, RowList),
    column(State, Col, ColumnList),
    \+ memberchk(Num, ColumnList),
    subgrid(State, Row, Col, Subgrid),
    \+ memberchk(Num, Subgrid).

% Extract a column from the grid
column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
    nth1(Col, Row, Value),
    column(Rest, Col, Values).

% Extract the 2x2 subgrid containing (Row, Col)
subgrid(State, Row, Col, Subgrid) :-
    % Determine top-left corner indices
    SubRow1 is ((Row - 1) // 2) * 2 + 1,
    SubCol1 is ((Col - 1) // 2) * 2 + 1,
    % Calculate the next row/column indices explicitly
    SubRow2 is SubRow1 + 1, % << CORRIGIDO
    SubCol2 is SubCol1 + 1, % << CORRIGIDO
    % Extract 4 cells using integer indices
    nth1(SubRow1, State, Row1),
    nth1(SubRow2, State, Row2), % << CORRIGIDO
    nth1(SubCol1, Row1, A), nth1(SubCol2, Row1, B), % << CORRIGIDO
    nth1(SubCol1, Row2, C), nth1(SubCol2, Row2, D), % << CORRIGIDO
    Subgrid = [A, B, C, D].

% Fill cell (Row, Col) with Num
fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

% Helper: Replace element at position (1-based index) in a list
replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).
```

Saída retornada pelo SWISH

```prolog
Time limit exceeded
```

O erro "Time limit exceeded" no SWISH ao executar o código corrigido indica que a busca pela solução está demorando muito tempo, e o SWISH interrompeu a execução para evitar o uso excessivo de recursos. Isso acontece pelos seguintes motivos:

1.  **Estratégia de Busca Ineficiente (Força Bruta com Backtracking):** O código utiliza uma busca em profundidade (Depth-First Search - DFS) simples. Ele encontra a *primeira* célula vazia (da esquerda para a direita, de cima para baixo) e tenta preenchê-la com os números 1, 2, 3 e 4, em ordem. Se um número é válido (`is_valid`), ele avança recursivamente. Se chega a um beco sem saída (não consegue preencher uma célula ou o estado resultante não leva ao `FinalState`), o Prolog faz o *backtracking*: ele desfaz a última escolha (o último número tentado) e tenta o próximo.
2.  **Grande Espaço de Busca:** Mesmo para uma grade 4x4, o número de combinações possíveis é grande. A busca DFS, sem heurísticas mais inteligentes, pode explorar muitos ramos "ruins" da árvore de busca antes de encontrar o caminho correto que leva ao `FinalState` específico. Cada vez que ele preenche uma célula incorretamente, ele pode ter que fazer muitos passos recursivos e backtrackings subsequentes antes de corrigir essa escolha inicial.
3.  **Falta de Heurísticas:** O código não usa nenhuma heurística comum para resolver problemas de restrição como Sudoku. Por exemplo:
    *   **Variável Mais Restrita (Most Constrained Variable):** Não escolhe a célula vazia que tem o *menor* número de opções válidas restantes. Escolher a célula mais restrita primeiro geralmente poda a árvore de busca mais rapidamente.
    *   **Propagação de Restrições:** O `is_valid` apenas verifica o estado *atual*. Ele não propaga as consequências de colocar um número (por exemplo, se colocar '1' na célula (1,1), ele não remove imediatamente '1' como opção para as outras células na mesma linha/coluna/bloco *antes* de tentar preenchê-las).
4.  **Meta Específica (`FinalState`):** Como o objetivo é atingir um `FinalState` *exato*, a busca não pode parar na *primeira* solução completa que encontrar (como faria o Código B). Ela precisa continuar até encontrar o caminho que leva *precisamente* àquele `FinalState`, o que pode exigir a exploração de ainda mais ramos da árvore de busca se o caminho "correto" envolver escolhas que a busca simples só tenta mais tarde (por exemplo, precisar colocar um '4' numa célula, mas tentar '1', '2', '3' primeiro).

**Em Resumo:** O algoritmo implementado, embora logicamente correto para encontrar o plano, é computacionalmente ingênuo. Sua abordagem de força bruta com backtracking simples não é eficiente o suficiente para explorar o espaço de busca e encontrar a solução específica dentro do limite de tempo padrão do SWISH.

___

* Modificações feitas para que esse código funcione foram então implementadas

```prolog 
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
    replace(T, NextPos, X, NewT).
```

Este código Prolog funciona como um **planejador** que encontra a sequência de passos (`fill(Linha, Coluna, Numero)`) para preencher um tabuleiro 4x4 vazio (`InitialState`) até atingir um tabuleiro específico pré-definido (`FinalState`).

Ele usa **backtracking**, mas de forma **guiada pelo objetivo**:

1.  Em cada passo, ele encontra a **primeira célula vazia** disponível.
2.  Verifica qual número **deveria** estar naquela célula de acordo com o `FinalState` (o "número alvo").
3.  **Tenta colocar o número alvo primeiro.** Se for uma jogada válida (não viola as regras do Sudoku naquele momento), ele segue em frente.
4.  **Somente se** o número alvo não puder ser colocado validamente, ele tenta outros números (1 a 4) que sejam válidos para aquela célula.

Essa priorização do "número alvo" direciona a busca eficientemente para o `FinalState` desejado, ao invés de explorar muitas possibilidades irrelevantes.

Saída retornada 

```prolog
FinalState = [[1, 3, 4, 2], [4, 2, 1, 3], [2, 4, 3, 1], [3, 1, 2, 4]],
InitialState = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
Plan = [fill(1,1,1), fill(1,2,3), fill(1,3,4), fill(1,4,2), fill(2,1,4), fill(2,2,2), fill(2,3,1), fill(2,4,3), fill(3,1,2), fill(3,2,4), fill(3,3,3), fill(3,4,1), fill(4,1,3), fill(4,2,1), fill(4,3,2), fill(4,4,4)]
```

* Modificação com means-ends

```prolog
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
```

Saída retornada 

```prolog 
FinalState = [[1, 3, 4, 2], [4, 2, 1, 3], [2, 4, 3, 1], [3, 1, 2, 4]],
InitialState = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
Plan = [fill(1,1,1), fill(1,2,3), fill(1,3,4), fill(1,4,2), fill(2,1,4), fill(2,2,2), fill(2,3,1), fill(2,4,3), fill(3,1,2), fill(3,2,4), fill(3,3,3), fill(3,4,1), fill(4,1,3), fill(4,2,1), fill(4,3,2), fill(4,4,4)]
```

Um código alternativo, baseado no original corrigido foi pensado, que resolve um puzzle 4x4 tipo Sudoku, começando a partir de um `estado_inicial` parcialmente preenchido.

Ele utiliza **backtracking simples**:

1.  Encontra a **primeira célula vazia**.
2.  Tenta preenchê-la com números de 1 a 4, um por vez.
3.  Para cada número, verifica se ele é **válido** (não causa conflitos na linha, coluna ou bloco 2x2).
4.  Se for válido, preenche a célula e continua recursivamente para a próxima célula vazia.
5.  Se um número não for válido ou levar a um beco sem saída, ele **volta atrás (backtrack)** e tenta o próximo número ou a decisão anterior.

O processo para quando encontra a **primeira solução completa e válida**, retornando a sequência de ações (`fill`) que levou a essa solução. Ele não busca um `FinalState` específico pré-definido, mas sim qualquer solução válida.

Comando para compilar 

```prolog 
estado_inicial(Ini), plan(Ini, Final, Plano), print_state(Final), writeln(Plano).
```

Codificação 

```prolog 
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
```

Saída retornada 

```prolog 
[1, 2, 3, 4]
[4, 3, 2, 1]
[2, 1, 4, 3]
[3, 4, 1, 2]
[fill(1,2,2), fill(1,3,3), fill(2,1,4), fill(2,2,3), fill(2,3,2), fill(2,4,1), fill(3,1,2), fill(3,2,1), fill(3,3,4), fill(3,4,3), fill(4,2,4), fill(4,3,1)]
Final = [[1, 2, 3, 4], [4, 3, 2, 1], [2, 1, 4, 3], [3, 4, 1, 2]],
Ini = [[1, 0, 0, 4], [0, 0, 0, 0], [0, 0, 0, 0], [3, 0, 0, 2]],
Plano = [fill(1,2,2), fill(1,3,3), fill(2,1,4), fill(2,2,3), fill(2,3,2), fill(2,4,1), fill(3,1,2), fill(3,2,1), fill(3,3,4), fill(3,4,3), fill(4,2,4), fill(4,3,1)]
```

# **4. Estude o método Goal regression e explique sua diferença para means-ends**

Enquanto a Análise Meios-Fins (MEA) planeja **para frente**, partindo do estado inicial e focando em identificar **diferenças** com o objetivo para selecionar **ações (meios)** que as reduzam (criando **sub-objetivos** se as pré-condições da ação falharem), a Regressão de Objetivos (Goal Regression) trabalha **para trás**, partindo do estado final e buscando ações cujos **efeitos** satisfaçam o objetivo (ou sub-objetivo atual), usando as **pré-condições** dessas ações como o novo sub-objetivo a ser alcançado no passo anterior, construindo assim o plano na ordem inversa.

# **5. Implemente goal regression na sua implementação anterior**
