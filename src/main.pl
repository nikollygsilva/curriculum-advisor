% ============================================================
% ARQUIVO PRINCIPAL - DEMONSTRACAO (main.pl)
% ============================================================
% Inclui as tres camadas e oferece predicados de demonstracao.
%
% Consultas:
%   demo.            -> as tres camadas com o aluno bruno
%   demo(carla).     -> mesma demonstracao para outro aluno
%   resumo_base.     -> confere os minimos exigidos da Camada 1
% ============================================================

% SWI-Prolog (padrao):
:- ensure_loaded('trilhas.pl').
% SWISH: comente a linha acima e descomente a de baixo.
% :- include('nnl-trilhas').

% Limite de creditos por semestre usado na demonstracao
% (a matriz oficial tem semestres de 24 a 26 creditos).
creditos_demo(26).


% ------------------------------------------------------------
% demo/0 e demo/1: exercitam as tres camadas em sequencia.
% ------------------------------------------------------------
demo :-
    demo(bruno).

demo(Aluno) :-
    (   aluno(Aluno)
    ->  creditos_demo(Max),
        demo_camada1,
        demo_camada2(Aluno),
        demo_camada3(Aluno, Max)
    ;   format("Aluno inexistente: ~w~n", [Aluno])
    ).


% ---------------- Camada 1 ----------------
demo_camada1 :-
    titulo('CAMADA 1 - Base de fatos'),
    resumo_base,
    disciplinas_do_semestre(1, L1),
    format("Disciplinas do 1o periodo: ~w~n", [L1]).

% resumo_base: mostra que a Camada 1 cumpre os minimos do enunciado
% (20+ disciplinas, 6+ semestres, 3+ eletivas, 3+ alunos).
% setof com ^ : queremos os periodos DISTINTOS, sem agrupar pelas
% outras variaveis (D, T, C).
resumo_base :-
    findall(D, disciplina(D, _, _, _), Ds),         length(Ds, ND),
    findall(E, disciplina(E, eletiva, _, _), Es),   length(Es, NE),
    setof(P, D^T^C^disciplina(D, T, C, P), Ps),     length(Ps, NP),
    findall(A, aluno(A), As),                        length(As, NA),
    format("~w disciplinas (~w eletivas), ~w periodos ~w~n", [ND, NE, NP, Ps]),
    format("~w alunos de teste: ~w~n", [NA, As]).


% ---------------- Camada 2 ----------------
demo_camada2(Aluno) :-
    titulo('CAMADA 2 - Elegibilidade'),
    format("Aluno: ~w~n", [Aluno]),
    creditos_cursados(Aluno, Cred),
    format("Creditos cursados: ~w~n", [Cred]),
    disciplinas_liberadas(Aluno, Lib),
    format("Liberadas agora: ~w~n", [Lib]),
    disciplinas_pendentes(Aluno, Pend),
    length(Pend, NP),
    format("Obrigatorias pendentes: ~w~n", [NP]).


% ---------------- Camada 3 ----------------
demo_camada3(Aluno, Max) :-
    titulo('CAMADA 3 - Fecho transitivo e trilhas'),
    ancestrais(devops, AncD),
    format("Pre-requisitos diretos e indiretos de devops:~n  ~w~n", [AncD]),
    (   base_sem_ciclos
    ->  format("Ciclos na base: nenhum~n", [])
    ;   disciplinas_em_ciclo(Cic),
        format("Ciclos na base: ~w~n", [Cic])
    ),

    format("~nTrilha com o MENOR numero de semestres (max ~w creditos):~n", [Max]),
    (   trilha_minima(Aluno, Max, TMin)
    ->  imprimir_trilha(TMin),
        (   verificar_trilha(Aluno, Max, TMin)
        ->  format("(conferida com o fecho transitivo: OK)~n", [])
        ;   format("(conferencia FALHOU)~n", [])
        )
    ;   format("Nenhuma trilha dentro do limite de semestres~n", [])
    ),

    % Varias trilhas do MESMO aluno. Pedir TODAS trava (explosao
    % combinatoria), entao limitamos a quantidade com limit/2.
    findall(T, limit(20, trilha_valida(Aluno, Max, T)), Varias),
    length(Varias, NV),
    format("~nPrimeiras ~w trilhas validas de ~w (findall + limit):~n", [NV, Aluno]),
    % bagof agrupa essas trilhas pela duracao (variavel D, livre
    % fora do template): uma resposta por duracao.
    forall(bagof(T2, limit(20, (trilha_valida(Aluno, Max, T2), length(T2, D))), Ts),
           ( length(Ts, NT),
             format("  ~w trilhas com ~w semestres (bagof)~n", [NT, D]) )).


titulo(Texto) :-
    format("~n==== ~w ====~n", [Texto]).