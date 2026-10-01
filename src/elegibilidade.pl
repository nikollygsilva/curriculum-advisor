% SWI-Prolog (padrao):
:- ensure_loaded('curriculum.pl').
% SWISH: comente a linha acima e descomente a de baixo.
% :- include('nnl-curriculum').

% ============================================
% CAMADA 2 - REGRAS DE ELEGIBILIDADE
% ============================================
prerequisitos_ok(Aluno, Disciplina) :-
    aluno(Aluno),
    disciplina(Disciplina, _, _, _),
    forall(prerequisito(Disciplina, Pre),
           cursou(Aluno, Pre)).

pode_cursar(Aluno, Disciplina) :-
    aluno(Aluno),
    disciplina(Disciplina, _, _, _),
    \+ cursou(Aluno, Disciplina),
    prerequisitos_ok(Aluno, Disciplina).

disciplinas_liberadas(Aluno, Lista) :-
    aluno(Aluno),
    findall(D, pode_cursar(Aluno, D), Lista).

disciplinas_pendentes(Aluno, Lista) :-
    aluno(Aluno),
    findall(D,
            ( disciplina(D, obrigatoria, _, _),
              \+ cursou(Aluno, D) ),
            Lista).

creditos_cursados(Aluno, Total) :-
    aluno(Aluno),
    findall(C, (cursou(Aluno, D), disciplina(D, _, C, _)), Creditos),
    soma_lista(Creditos, Total).

soma_lista([], 0).
soma_lista([X|Resto], Soma) :-
    soma_lista(Resto, SomaResto),
    Soma is X + SomaResto.

disciplinas_do_semestre(Periodo, Lista) :-
    findall(D, disciplina(D, _, _, Periodo), Lista).

