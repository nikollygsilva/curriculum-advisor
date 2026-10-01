% ============================================================
% BATERIA DE TESTES (consultas_teste.pl)
% ============================================================
% Uso:  rodar_testes.
%
% Cada teste e um par: teste(Id, Descricao) + caso(Id) :- Corpo.
% O resultado esperado esta escrito dentro do proprio Corpo
% (ex.: L == [...]). Testes "negativos" usam \+ : passam quando a
% consulta FALHA de forma limpa. Mensagens [aviso] durante os
% testes de robustez sao esperadas.
% ============================================================

% SWI-Prolog (padrao):
:- ensure_loaded('../src/main.pl').
% SWISH: comente a linha acima e descomente a de baixo.
% :- include('nnl-trilhas').


% ============================================================
% EXECUTOR
% ============================================================
% Cada teste tem duas partes, uma embaixo da outra:
%   teste(Id, Descricao).   -> o nome e a descricao do teste
%   caso(Id) :- ...         -> o que precisa ser verdade para passar
% catch/3 captura excecoes: um erro num teste conta como FALHA, mas
% nao derruba a bateria inteira.

:- discontiguous teste/2, caso/1.

rodar_testes :-
    findall(Id-Desc, teste(Id, Desc), Testes),
    length(Testes, Total),
    executar_testes(Testes, 0, Ok),
    format("~n~w de ~w testes passaram.~n", [Ok, Total]).

executar_testes([], Ok, Ok).
executar_testes([Id-Desc|Resto], Acc, Ok) :-
    (   catch(once(caso(Id)), Erro,
              ( format("  excecao: ~q~n", [Erro]), fail ))
    ->  format("[ OK  ] ~w - ~w~n", [Id, Desc]),
        Acc1 is Acc + 1
    ;   format("[FALHA] ~w - ~w~n", [Id, Desc]),
        Acc1 = Acc
    ),
    executar_testes(Resto, Acc1, Ok).


% ============================================================
% CAMADA 1
% ============================================================
teste(c1_semestre1, 'disciplinas do 1o periodo (teste obrigatorio da Camada 1)').
caso(c1_semestre1) :-
    disciplinas_do_semestre(1, L),
    L == [ec_navegando_computacao, raciocinio_algoritmico,
          rp_logica_matematica, sc_fundamentos, filosofia].

teste(c1_minimos, 'base tem 20+ disciplinas, 6+ periodos, 3+ eletivas, 3+ alunos').
caso(c1_minimos) :-
    findall(D, disciplina(D,_,_,_), Ds), length(Ds, ND), ND >= 20,
    setof(P, D^T^C^disciplina(D,T,C,P), Ps), length(Ps, NP), NP >= 6,
    findall(E, disciplina(E,eletiva,_,_), Es), length(Es, NE), NE >= 3,
    findall(A, aluno(A), As), length(As, NA), NA >= 3.

teste(c1_eletivas, 'lista das eletivas').
caso(c1_eletivas) :-
    findall(E, disciplina(E, eletiva, _, _), L),
    L == [libras, empreendedorismo_tecnologia, computacao_quantica].

teste(c1_creditos_matriz, 'creditos do 1o periodo batem com a matriz oficial (24)').
caso(c1_creditos_matriz) :-
    findall(C, disciplina(_, obrigatoria, C, 1), Cs),
    soma_lista(Cs, 24).

teste(c1_atomos, 'nomes sao atomos: texto entre aspas duplas NAO unifica').
caso(c1_atomos) :-
    disciplina(filosofia, _, _, _),
    \+ disciplina("filosofia", _, _, _).

teste(c1_cadeia_profunda, 'existe cadeia de pre-requisitos com profundidade >= 3').
caso(c1_cadeia_profunda) :-
    prerequisito(devops, cloud_computing),
    prerequisito(cloud_computing, programacao_distribuida),
    prerequisito(programacao_distribuida, sc_sistemas_operacionais).


% ============================================================
% CAMADA 2
% ============================================================
teste(c2_liberadas_bruno, 'disciplinas_liberadas de bruno (ritmo normal)').
caso(c2_liberadas_bruno) :-
    disciplinas_liberadas(bruno, L),
    L == [ec_criando_solucoes, programacao_oo, modelagem_fenomenos_fisicos,
          seguranca_informacao, sc_performance, clinica_tic,
          programacao_logica_funcional, rp_estruturados, big_data,
          redes_convergentes, teologia_sociedade, metodos_quantitativos,
          libras, empreendedorismo_tecnologia, computacao_quantica].

teste(c2_liberadas_carla, 'disciplinas_liberadas de carla (atrasada)').
caso(c2_liberadas_carla) :-
    disciplinas_liberadas(carla, L),
    L == [rp_logica_matematica, programacao_web, arquitetura_banco_dados,
          sc_conectividade, ec_criando_solucoes, programacao_oo,
          clinica_tic, teologia_sociedade, libras,
          empreendedorismo_tecnologia, computacao_quantica].

teste(c2_liberadas_diego, 'disciplinas_liberadas do calouro: 1o periodo + eletivas').
caso(c2_liberadas_diego) :-
    disciplinas_liberadas(diego, L),
    L == [ec_navegando_computacao, raciocinio_algoritmico,
          rp_logica_matematica, sc_fundamentos, filosofia,
          libras, empreendedorismo_tecnologia, computacao_quantica].

teste(c2_liberadas_diferentes, 'alunos diferentes tem liberadas diferentes').
caso(c2_liberadas_diferentes) :-
    disciplinas_liberadas(bruno, B),
    disciplinas_liberadas(carla, C),
    B \== C.

teste(c2_pendentes_eva, 'disciplinas_pendentes da formanda eva').
caso(c2_pendentes_eva) :-
    disciplinas_pendentes(eva, L),
    L == [ec_transformador1, devops, ec_transformador2,
          avaliacao_desempenho, processamento_linguagem_natural,
          mundos_virtuais, visao_computacional].

teste(c2_pendentes_bruno, 'disciplinas_pendentes de bruno: 36 (inclui nao liberadas)').
caso(c2_pendentes_bruno) :-
    disciplinas_pendentes(bruno, L),
    length(L, 36),
    memberchk(programacao_distribuida, L),             % pendente...
    \+ pode_cursar(bruno, programacao_distribuida).    % ...mas nao liberada

teste(c2_creditos, 'creditos_cursados de todos os alunos').
caso(c2_creditos) :-
    creditos_cursados(ana, 110), creditos_cursados(bruno, 48),
    creditos_cursados(carla, 26), creditos_cursados(diego, 0),
    creditos_cursados(eva, 178).

teste(c2_multiplos_prereq, 'prerequisitos_ok com DOIS pre-requisitos').
% programacao_logica_funcional exige imperativa E rp_logica_matematica.
% carla tem so imperativa -> falso; bruno tem as duas -> verdadeiro.
caso(c2_multiplos_prereq) :-
    prerequisitos_ok(bruno, programacao_logica_funcional),
    \+ prerequisitos_ok(carla, programacao_logica_funcional).

teste(c2_negacao_decisiva, '\\+ cursou e decisivo em pode_cursar (Secao 8)').
% bruno e carla cumprem o pre-requisito de programacao_web;
% a UNICA diferenca e que bruno ja a cursou.
caso(c2_negacao_decisiva) :-
    prerequisitos_ok(bruno, programacao_web),
    prerequisitos_ok(carla, programacao_web),
    \+ pode_cursar(bruno, programacao_web),
    pode_cursar(carla, programacao_web).

teste(c2_vacuidade, 'disciplina sem pre-requisito: forall verdadeiro por vacuidade').
caso(c2_vacuidade) :-
    prerequisitos_ok(diego, filosofia).

teste(c2_aluno_inexistente, 'aluno inexistente falha de forma limpa').
caso(c2_aluno_inexistente) :-
    \+ prerequisitos_ok(zeca, filosofia),
    \+ pode_cursar(zeca, _),
    \+ disciplinas_liberadas(zeca, _),
    \+ disciplinas_pendentes(zeca, _),
    \+ creditos_cursados(zeca, _).

teste(c2_disciplina_inexistente, 'disciplina inexistente falha de forma limpa').
caso(c2_disciplina_inexistente) :-
    \+ pode_cursar(ana, culinaria),
    \+ prerequisitos_ok(ana, culinaria).


% ============================================================
% CAMADA 3 - fecho transitivo e ciclos
% ============================================================
teste(c3_transitivo_cadeia, 'fecho transitivo na cadeia de profundidade 6').
caso(c3_transitivo_cadeia) :-
    \+ prerequisito(devops, sc_fundamentos),            % nao e direto
    prerequisito_transitivo(devops, sc_fundamentos).

teste(c3_ancestrais, 'ancestrais de devops (setof: ordenado, sem repeticao)').
caso(c3_ancestrais) :-
    ancestrais(devops, L),
    L == [cloud_computing, programacao_distribuida, redes_convergentes,
          sc_conectividade, sc_fundamentos, sc_performance,
          sc_sistemas_operacionais].

teste(c3_findall_vs_setof, 'findall repete ancestral alcancado por 2 caminhos; setof nao').
caso(c3_findall_vs_setof) :-
    findall(A, prerequisito_transitivo(construcao_interpretadores, A), F),
    length(F, 7),
    ancestrais(construcao_interpretadores, S),
    length(S, 6).

teste(c3_sem_ancestral, 'disciplina sem pre-requisito: ancestrais = []').
caso(c3_sem_ancestral) :-
    ancestrais(filosofia, L), L == [].

teste(c3_nao_ancestral, 'filosofia NAO e pre-requisito de devops').
caso(c3_nao_ancestral) :-
    \+ prerequisito_transitivo(devops, filosofia).

teste(c3_sem_ciclo, 'base oficial nao tem ciclos').
caso(c3_sem_ciclo) :-
    base_sem_ciclos, disciplinas_em_ciclo(L), L == [].

teste(c3_transitivo_inexistente, 'fecho transitivo de disciplina inexistente falha').
caso(c3_transitivo_inexistente) :-
    \+ prerequisito_transitivo(culinaria, _).


% ============================================================
% CAMADA 3 - trilhas
% ============================================================
teste(c3_trilha_completa, 'trilha completa do calouro ate a formatura (Secao 8)').
caso(c3_trilha_completa) :-
    trilha_valida(diego, 26, T),
    verificar_trilha(diego, 26, T).

teste(c3_trilha_minima, 'trilha minima do calouro com 26 creditos = 8 semestres').
caso(c3_trilha_minima) :-
    trilha_minima(diego, 26, T),
    length(T, 8),
    verificar_trilha(diego, 26, T).

teste(c3_minima_otima, 'nao existe trilha do calouro com 7 semestres').
caso(c3_minima_otima) :-
    \+ trilha_valida(diego, 26, 7, _).

teste(c3_multiplas_findall, 'findall enumera TODAS as trilhas da eva em 2 semestres').
caso(c3_multiplas_findall) :-
    trilhas_validas(eva, 26, 2, L),
    length(L, 32),
    forall(member(T, L), verificar_trilha(eva, 26, T)).

teste(c3_sem_repeticao, 'as trilhas enumeradas sao todas diferentes').
caso(c3_sem_repeticao) :-
    trilhas_validas(eva, 26, 2, L),
    sort(L, LS), length(LS, 32).

teste(c3_primeiras_k, 'primeiras 5 trilhas do calouro, todas validas').
caso(c3_primeiras_k) :-
    primeiras_trilhas(diego, 26, 5, L),
    length(L, 5),
    forall(member(T, L), verificar_trilha(diego, 26, T)).

teste(c3_bagof, 'bagof agrupa as trilhas da eva por duracao').
caso(c3_bagof) :-
    findall(D-N,
            ( trilhas_por_duracao(eva, 26, 3, D, Ts), length(Ts, N) ),
            Grupos),
    Grupos == [2-32, 3-633].

teste(c3_respeita_creditos, 'nenhum semestre passa do limite de creditos').
caso(c3_respeita_creditos) :-
    trilha_valida(carla, 20, T),
    forall(member(S, T),
           ( findall(C, (member(D, S), disciplina(D,_,C,_)), Cs),
             soma_lista(Cs, Tot), Tot =< 20 )).

teste(c3_ja_formado, 'estado ja formado gera trilha vazia').
caso(c3_ja_formado) :-
    findall(D, disciplina(D, obrigatoria, _, _), Obr),
    gerar_trilha([libras, empreendedorismo_tecnologia|Obr], 26, 12, T),
    T == [].


% ============================================================
% mensagens [aviso] sao esperadas aqui
% ============================================================
teste(r_aluno_inexistente, 'trilha de aluno inexistente: falha com aviso').
caso(r_aluno_inexistente) :-
    \+ trilha_valida(zeca, 26, _).

teste(r_creditos_invalidos, 'limite de creditos invalido: falha com aviso, sem excecao').
caso(r_creditos_invalidos) :-
    \+ trilha_valida(ana, abc, _),
    \+ trilha_valida(ana, -4, _).

teste(r_limite_seguranca, 'horizonte acima do limite de 12 semestres e recusado').
caso(r_limite_seguranca) :-
    \+ trilha_valida(ana, 26, 50, _).

teste(r_disciplina_nao_cabe, 'limite menor que uma disciplina: falha rapida').
caso(r_disciplina_nao_cabe) :-
    \+ trilha_valida(diego, 3, _).

teste(r_impossivel_no_limite, 'formatura impossivel em 12 semestres: falha sem travar').
caso(r_impossivel_no_limite) :-
    \+ trilha_valida(diego, 8, _).