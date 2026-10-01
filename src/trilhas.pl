% ============================================================
% CAMADA 3 - FECHO TRANSITIVO E GERACAO DE TRILHAS (trilhas.pl)
% ============================================================
% Olha para o historico completo de pre-requisitos (diretos e
% indiretos) e para o FUTURO (caminho ate a formatura).
%
% Decisao central: o "estado" do aluno durante a simulacao e uma
% LISTA de disciplinas cursadas passada como argumento, e nao a
% base de fatos alterada com assert/retract. Assim, quando o
% Prolog retrocede (backtracking), a trilha de variaveis (trail)
% desfaz tudo sozinha - nenhum efeito colateral sobra na base.
% ============================================================

% SWI-Prolog (padrao):
:- ensure_loaded('elegibilidade.pl').
% SWISH: comente a linha acima e descomente a de baixo.
% :- include('nnl-elegibilidade').


% Rede de seguranca contra explosao combinatoria: nenhuma trilha
% simula mais do que este numero de semestres, mesmo com a base
% correta e sem ciclos.
limite_semestres(12).


% ============================================================
% 3.1 FECHO TRANSITIVO
% ============================================================

% ------------------------------------------------------------
% prerequisito_transitivo(?Disciplina, ?Ancestral)
% Ancestral e pre-requisito direto OU indireto de Disciplina.
%
% Disciplina e instanciada primeiro (via disciplina/4): isso
% garante que a lista de visitados nunca contenha variavel livre
% e que uma disciplina inexistente falhe de forma limpa.
% ------------------------------------------------------------
prerequisito_transitivo(Disciplina, Ancestral) :-
    disciplina(Disciplina, _, _, _),
    pre_trans(Disciplina, Ancestral, [Disciplina]).

% Caso base: pre-requisito direto.
pre_trans(D, Ancestral, _Visitados) :-
    prerequisito(D, Ancestral).
% Passo recursivo: sobe um nivel, MAS so por um no ainda nao
% visitado. A lista de visitados cresce a cada passo e o grafo e
% finito, entao a recursao e bem fundada e termina MESMO que a
% base tenha um ciclo (ex.: a -> b -> a).
pre_trans(D, Ancestral, Visitados) :-
    prerequisito(D, Intermediaria),
    \+ memberchk(Intermediaria, Visitados),
    pre_trans(Intermediaria, Ancestral, [Intermediaria|Visitados]).


% ------------------------------------------------------------
% ancestrais(+Disciplina, -Lista)
% Todos os pre-requisitos diretos e indiretos, SEM repeticao.
%
% Aqui setof/3 e a escolha certa: a mesma disciplina pode ser
% alcancada por caminhos diferentes (ex.: rp_logica_matematica chega a
% construcao_interpretadores via programacao_logica_funcional E via
% rp_estruturados), entao
% findall traria duplicatas. setof remove duplicatas e ordena.
% Como setof FALHA quando nao ha solucao, o caso "sem
% pre-requisitos" e tratado devolvendo [].
% ------------------------------------------------------------
ancestrais(Disciplina, Lista) :-
    disciplina(Disciplina, _, _, _),
    (   setof(A, prerequisito_transitivo(Disciplina, A), Lista)
    ->  true
    ;   Lista = []
    ).


% ------------------------------------------------------------
% existe_ciclo(?Disciplina)
% Verdadeiro se prerequisito_transitivo(D, D) se sustenta, ou seja,
% D depende (direta ou indiretamente) de si mesma: base malformada.
% once/1 evita que a mesma disciplina seja reportada varias vezes
% (por varios caminhos) sem cortar a enumeracao de outras.
% ------------------------------------------------------------
existe_ciclo(Disciplina) :-
    disciplina(Disciplina, _, _, _),
    once(prerequisito_transitivo(Disciplina, Disciplina)).

% disciplinas_em_ciclo(-Lista): todas as disciplinas envolvidas em ciclo.
disciplinas_em_ciclo(Lista) :-
    findall(D, existe_ciclo(D), Lista).

% base_sem_ciclos: aqui o \+ com variavel livre e INTENCIONAL:
% \+ existe_ciclo(_) significa "nao existe nenhuma disciplina em
% ciclo", que e exatamente o que queremos verificar.
base_sem_ciclos :-
    \+ existe_ciclo(_).

% referencia_invalida(?D, ?P): prerequisito/2 citando disciplina
% que nao esta cadastrada em disciplina/4 (outro tipo de base
% malformada que vale detectar).
referencia_invalida(D, P) :-
    prerequisito(D, P),
    \+ ( disciplina(D, _, _, _), disciplina(P, _, _, _) ).


% ============================================================
% 3.2 ESTADO DO ALUNO DURANTE A SIMULACAO (listas, sem assert)
% ============================================================

% historico(+Aluno, -Cursadas): estado inicial da simulacao.
% findall para que um aluno sem historico (calouro) obtenha [].
historico(Aluno, Cursadas) :-
    aluno(Aluno),
    findall(D, cursou(Aluno, D), Cursadas).

% creditos_eletivos(+Cursadas, -Total)
creditos_eletivos(Cursadas, Total) :-
    findall(C,
            ( member(D, Cursadas),
              disciplina(D, eletiva, C, _) ),
            Cs),
    soma_lista(Cs, Total).

% formado(+Cursadas): todas as obrigatorias + minimo de eletivas.
formado(Cursadas) :-
    forall(disciplina(D, obrigatoria, _, _),
           memberchk(D, Cursadas)),
    creditos_eletivos(Cursadas, CE),
    creditos_eletivos_minimos(Min),
    CE >= Min.

% faltam_eletivas(+Cursadas, -Faltam)
faltam_eletivas(Cursadas, Faltam) :-
    creditos_eletivos(Cursadas, CE),
    creditos_eletivos_minimos(Min),
    Faltam is max(0, Min - CE).

% relevante(+Cursadas, -D): disciplina que ainda vale a pena
% planejar. Obrigatorias sempre; eletivas so enquanto o minimo de
% creditos eletivos nao foi atingido (poda: depois disso, eletivas
% extras nao aproximam o aluno da formatura).
relevante(_, D) :-
    disciplina(D, obrigatoria, _, _).
relevante(Cursadas, D) :-
    faltam_eletivas(Cursadas, F),
    F > 0,
    disciplina(D, eletiva, _, _).

% disciplinas_disponiveis(+Cursadas, -Lista)
% Mesma ideia de pode_cursar/2 da Camada 2, mas sobre a LISTA de
% cursadas simulada (e nao sobre os fatos cursou/2).
disciplinas_disponiveis(Cursadas, Lista) :-
    findall(D,
            ( relevante(Cursadas, D),
              \+ memberchk(D, Cursadas),
              forall(prerequisito(D, P), memberchk(P, Cursadas)) ),
            Lista).


% ============================================================
% 3.3 LIMITE INFERIOR (poda da busca)
% ============================================================
% semestres_minimos(+Cursadas, +MaxCreditos, -Min)
% Estimativa OTIMISTA de quantos semestres ainda faltam, no minimo.
% Se ela ja passa do numero de semestres restantes, aquele ramo da
% busca e abandonado sem ser explorado. E otimista (nunca
% superestima), entao a poda nunca descarta uma trilha valida.
%   - por creditos: teto(creditos que faltam / MaxCreditos)
%   - por cadeia:   maior profundidade de pre-requisitos pendentes
%                   (uma disciplina por semestre em cada elo)
semestres_minimos(Cursadas, MaxCreditos, Min) :-
    findall(C,
            ( disciplina(D, obrigatoria, C, _),
              \+ memberchk(D, Cursadas) ),
            Cs),
    soma_lista(Cs, CredObrig),
    faltam_eletivas(Cursadas, CredElet),
    Total is CredObrig + CredElet,
    PorCreditos is (Total + MaxCreditos - 1) // MaxCreditos,
    findall(P,
            ( disciplina(D, obrigatoria, _, _),
              \+ memberchk(D, Cursadas),
              profundidade(D, Cursadas, P) ),
            Ps),
    maximo_lista(Ps, PorCadeia),
    Min is max(PorCreditos, PorCadeia).

% profundidade(+D, +Cursadas, -P): numero minimo de semestres para
% concluir D, contando a cadeia de pre-requisitos ainda pendentes.
% So e chamada depois de base_sem_ciclos, entao sempre termina.
profundidade(D, Cursadas, P) :-
    findall(PP,
            ( prerequisito(D, Pre),
              \+ memberchk(Pre, Cursadas),
              profundidade(Pre, Cursadas, PP) ),
            Ps),
    maximo_lista(Ps, M),
    P is M + 1.

% maximo_lista(+Lista, -Max): maior elemento, 0 para lista vazia.
maximo_lista([], 0).
maximo_lista([X|Xs], M) :-
    maximo_lista(Xs, M0),
    M is max(X, M0).


% ============================================================
% 3.4 GERACAO DE TRILHAS (recursao + backtracking)
% ============================================================

% ------------------------------------------------------------
% trilha_valida(?Aluno, +MaxCreditosPorSemestre, -Trilha)
% Trilha = lista de semestres, cada semestre uma lista de
% disciplinas. Usa o limite de seguranca de semestres.
% Por backtracking (;) gera trilhas alternativas.
% ------------------------------------------------------------
trilha_valida(Aluno, MaxCreditos, Trilha) :-
    limite_semestres(Lim),
    trilha_valida(Aluno, MaxCreditos, Lim, Trilha).

% trilha_valida(?Aluno, +MaxCreditos, +MaxSemestres, -Trilha)
% Versao com horizonte explicito (MaxSemestres =< limite_semestres).
trilha_valida(Aluno, MaxCreditos, MaxSemestres, Trilha) :-
    aluno_valido(Aluno),
    parametros_validos(MaxCreditos, MaxSemestres),
    historico(Aluno, Cursadas),
    horizonte_suficiente(Aluno, Cursadas, MaxCreditos, MaxSemestres),
    gerar_trilha(Cursadas, MaxCreditos, MaxSemestres, Trilha).

% horizonte_suficiente: se nem a estimativa otimista cabe no
% horizonte, avisa e falha logo, explicando o motivo.
horizonte_suficiente(Aluno, Cursadas, MaxCred, MaxSem) :-
    semestres_minimos(Cursadas, MaxCred, Min),
    (   Min > MaxSem
    ->  aviso('~w precisa de pelo menos ~w semestres com ~w creditos/semestre (horizonte: ~w)',
              [Aluno, Min, MaxCred, MaxSem])
    ;   true
    ).

% gerar_trilha(+Cursadas, +MaxCred, +SemestresRestantes, -Trilha)
% Caso base: ja formado -> nao precisa de mais semestres.
gerar_trilha(Cursadas, _, _, []) :-
    formado(Cursadas).
% Passo recursivo: escolhe UM semestre e simula o resto.
gerar_trilha(Cursadas, MaxCred, Restantes, [Semestre|Resto]) :-
    \+ formado(Cursadas),
    Restantes > 0,                                  % criterio de parada
    semestres_minimos(Cursadas, MaxCred, Min),
    Min =< Restantes,                               % poda por limite inferior
    disciplinas_disponiveis(Cursadas, Disponiveis),
    faltam_eletivas(Cursadas, FaltaElet),
    escolher_semestre(Disponiveis, MaxCred, FaltaElet, Semestre), % ponto de escolha
    append(Semestre, Cursadas, NovasCursadas),      % novo estado (lista nova)
    Restantes1 is Restantes - 1,
    gerar_trilha(NovasCursadas, MaxCred, Restantes1, Resto).

% escolher_semestre(+Disponiveis, +MaxCred, +FaltaEletiva, -Semestre)
% Subconjunto NAO vazio das disponiveis cuja soma de creditos nao
% passa de MaxCred. Os elementos mantem a ordem da lista original,
% entao a mesma combinacao nunca aparece duas vezes em ordens
% diferentes. A primeira alternativa INCLUI a disciplina, entao a
% primeira trilha encontrada e "gulosa" (semestres cheios).
% Eletivas so entram enquanto ainda faltam creditos eletivos
% (FaltaEletiva > 0): evita trilhas que diferem apenas por
% eletivas "a mais", que nao aproximam o aluno da formatura.
escolher_semestre(Disponiveis, MaxCred, FaltaEletiva, Semestre) :-
    subconjunto(Disponiveis, MaxCred, FaltaEletiva, Semestre),
    Semestre \= [].

subconjunto([], _, _, []).
subconjunto([D|Ds], Saldo, Falta, [D|Sem]) :-
    disciplina(D, Tipo, C, _),
    C =< Saldo,
    pode_incluir(Tipo, Falta),
    Saldo1 is Saldo - C,
    atualizar_falta(Tipo, C, Falta, Falta1),
    subconjunto(Ds, Saldo1, Falta1, Sem).
subconjunto([_|Ds], Saldo, Falta, Sem) :-
    subconjunto(Ds, Saldo, Falta, Sem).

pode_incluir(obrigatoria, _).
pode_incluir(eletiva, Falta) :- Falta > 0.

atualizar_falta(obrigatoria, _, Falta, Falta).
atualizar_falta(eletiva, C, Falta, Falta1) :- Falta1 is max(0, Falta - C).


% ------------------------------------------------------------
% Validacao de entrada: falha LIMPA com mensagem, nunca excecao.
% Os cortes aqui sao "verdes": so evitam reavaliar a validacao.
% ------------------------------------------------------------
aluno_valido(Aluno) :-
    var(Aluno), !,
    aluno(Aluno).                 % enumera os alunos de teste
aluno_valido(Aluno) :-
    aluno(Aluno), !.
aluno_valido(Aluno) :-
    aviso('aluno inexistente: ~w', [Aluno]).

parametros_validos(MaxCred, MaxSem) :-
    (   \+ ( integer(MaxCred), MaxCred > 0 )
    ->  aviso('MaxCreditosPorSemestre deve ser inteiro positivo (recebido: ~w)', [MaxCred])
    ;   \+ ( integer(MaxSem), MaxSem >= 0 )
    ->  aviso('numero de semestres deve ser inteiro >= 0 (recebido: ~w)', [MaxSem])
    ;   limite_semestres(Lim), MaxSem > Lim
    ->  aviso('~w semestres excede o limite de seguranca (~w)', [MaxSem, Lim])
    ;   \+ base_sem_ciclos
    ->  disciplinas_em_ciclo(Ciclo),
        aviso('base de pre-requisitos com CICLO em ~w; trilha nao gerada', [Ciclo])
    ;   referencia_invalida(D, P)
    ->  aviso('prerequisito(~w, ~w) cita disciplina nao cadastrada', [D, P])
    ;   disciplina(D, obrigatoria, C, _), C > MaxCred
    ->  aviso('~w (~w creditos) nao cabe em semestre de ~w creditos', [D, C, MaxCred])
    ;   true
    ).

% aviso(+Formato, +Args): escreve a mensagem e FALHA.
aviso(Formato, Args) :-
    format('[aviso] ', []),
    format(Formato, Args),
    nl,
    fail.


% ============================================================
% 3.5 UMA, VARIAS OU A MELHOR TRILHA
% ============================================================

% primeira_trilha(+Aluno, +MaxCred, -Trilha): UMA trilha (a gulosa).
primeira_trilha(Aluno, MaxCred, Trilha) :-
    once(trilha_valida(Aluno, MaxCred, Trilha)).

% trilhas_validas(+Aluno, +MaxCred, +MaxSem, -Trilhas)
% TODAS as trilhas dentro de um horizonte de MaxSem semestres.
% O horizonte e obrigatorio de proposito: o numero de trilhas cresce
% de forma explosiva. Use com alunos perto da formatura (ex.: eva) ou
% use primeiras_trilhas/4 para pegar so as K primeiras.
trilhas_validas(Aluno, MaxCred, MaxSem, Trilhas) :-
    aluno_valido(Aluno),
    findall(T, trilha_valida(Aluno, MaxCred, MaxSem, T), Trilhas).

% primeiras_trilhas(+Aluno, +MaxCred, +K, -Trilhas)
% As K primeiras trilhas. limit/2 interrompe o backtracking depois
% de K solucoes, entao funciona mesmo quando o total de trilhas e
% grande demais para um findall completo.
primeiras_trilhas(Aluno, MaxCred, K, Trilhas) :-
    findall(T, limit(K, trilha_valida(Aluno, MaxCred, T)), Trilhas).

% trilhas_por_duracao(+Aluno, +MaxCred, +MaxSem, ?Duracao, -Trilhas)
% bagof/3 AGRUPA pelas variaveis livres do objetivo que nao estao
% no template: aqui, Duracao. Cada resposta traz uma duracao e as
% trilhas daquela duracao. (findall juntaria tudo numa lista so.)
trilhas_por_duracao(Aluno, MaxCred, MaxSem, Duracao, Trilhas) :-
    bagof(T,
          ( trilha_valida(Aluno, MaxCred, MaxSem, T),
            length(T, Duracao) ),
          Trilhas).

% trilha_minima(+Aluno, +MaxCred, -Trilha)
% Busca por aprofundamento iterativo: tenta N = limite inferior,
% N+1, ... ate limite_semestres. A primeira trilha achada tem o
% MENOR numero possivel de semestres.
trilha_minima(Aluno, MaxCred, Trilha) :-
    aluno_valido(Aluno),
    limite_semestres(Lim),
    parametros_validos(MaxCred, Lim),
    historico(Aluno, Cursadas),
    semestres_minimos(Cursadas, MaxCred, Min0),
    once(( between(Min0, Lim, N),
           gerar_trilha(Cursadas, MaxCred, N, Trilha) )).


% ============================================================
% 3.6 VERIFICACAO INDEPENDENTE DE UMA TRILHA
% ============================================================
% verificar_trilha(+Aluno, +MaxCred, +Trilha)
% Confere, usando o FECHO TRANSITIVO, que toda disciplina aparece
% depois de TODOS os seus pre-requisitos diretos e indiretos, que
% nenhum semestre passa do limite de creditos, que nada e repetido
% e que ao final o aluno esta formado. Serve para testar o gerador
% com um criterio diferente do usado para gerar.
verificar_trilha(Aluno, MaxCred, Trilha) :-
    historico(Aluno, Cursadas),
    verificar_semestres(Trilha, Cursadas, MaxCred, Final),
    formado(Final).

verificar_semestres([], Cursadas, _, Cursadas).
verificar_semestres([Sem|Resto], Cursadas, MaxCred, Final) :-
    Sem \= [],
    findall(C, (member(D, Sem), disciplina(D, _, C, _)), Cs),
    soma_lista(Cs, Total),
    Total =< MaxCred,
    forall(member(D, Sem),
           ( \+ memberchk(D, Cursadas),
             forall(prerequisito_transitivo(D, A),
                    memberchk(A, Cursadas)) )),
    append(Sem, Cursadas, Novas),
    verificar_semestres(Resto, Novas, MaxCred, Final).


% ============================================================
% 3.7 EXIBICAO
% ============================================================
% imprimir_trilha(+Trilha)
imprimir_trilha(Trilha) :-
    imprimir_semestres(Trilha, 1).

imprimir_semestres([], _).
imprimir_semestres([Sem|Resto], N) :-
    findall(C, (member(D, Sem), disciplina(D, _, C, _)), Cs),
    soma_lista(Cs, Total),
    format("Semestre ~w (~w creditos): ~w~n", [N, Total, Sem]),
    N1 is N + 1,
    imprimir_semestres(Resto, N1).