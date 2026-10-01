% ============================================================
% CAMADA 1 - BASE DE FATOS
% Matriz curricular de Ciencia da Computacao - PUCPR
% (Resolucao 166/2023 - CONSUN, ingressantes a partir de 2023/1)
% ============================================================
% Somente FATOS. Nada aqui e deduzido: tudo e verdade "e pronto".
% Nomes sao atomos: minusculos, sem acento, sem espaco, sem aspas.
% Prefixos usados para as familias de disciplinas:
%   ec_ = Experiencia Criativa
%   rp_ = Resolucao de Problemas
%   sc_ = Sistemas Ciberfisicos
% ============================================================

% Permite que o teste de ciclo acrescente um prerequisito/2 em outro
% ponto do programa sem gerar warning de "clausulas separadas".
:- multifile prerequisito/2.
:- discontiguous prerequisito/2.


% ------------------------------------------------------------
% disciplina(Nome, Tipo, Creditos, PeriodoSugerido)
% Tipo: obrigatoria ou eletiva
% Creditos: coluna CRED da matriz oficial
% ------------------------------------------------------------

% 1o periodo (24 creditos)
disciplina(ec_navegando_computacao,     obrigatoria, 6, 1).
disciplina(raciocinio_algoritmico,      obrigatoria, 6, 1).
disciplina(rp_logica_matematica,        obrigatoria, 4, 1).
disciplina(sc_fundamentos,              obrigatoria, 4, 1).
disciplina(filosofia,                   obrigatoria, 4, 1).

% 2o periodo (24 creditos)
disciplina(programacao_web,             obrigatoria, 4, 2).
disciplina(programacao_imperativa,      obrigatoria, 4, 2).
disciplina(arquitetura_banco_dados,     obrigatoria, 6, 2).
disciplina(rp_natureza_discreta,        obrigatoria, 4, 2).
disciplina(sc_conectividade,            obrigatoria, 4, 2).
disciplina(etica,                       obrigatoria, 2, 2).

% 3o periodo (26 creditos)
disciplina(ec_criando_solucoes,         obrigatoria, 6, 3).
disciplina(programacao_oo,              obrigatoria, 6, 3).
disciplina(modelagem_fenomenos_fisicos, obrigatoria, 4, 3).
disciplina(seguranca_informacao,        obrigatoria, 4, 3).
disciplina(sc_performance,              obrigatoria, 4, 3).
disciplina(clinica_tic,                 obrigatoria, 2, 3).

% 4o periodo (26 creditos)
disciplina(programacao_logica_funcional, obrigatoria, 4, 4).
disciplina(rp_estruturados,             obrigatoria, 4, 4).
disciplina(big_data,                    obrigatoria, 4, 4).
disciplina(modelagem_sistemas,          obrigatoria, 4, 4).
disciplina(redes_convergentes,          obrigatoria, 4, 4).
disciplina(sc_sistemas_operacionais,    obrigatoria, 4, 4).
disciplina(teologia_sociedade,          obrigatoria, 2, 4).

% 5o periodo (24 creditos)
disciplina(complexidade_algoritmos,     obrigatoria, 4, 5).
disciplina(ec_inovando,                 obrigatoria, 6, 5).
disciplina(metodos_pesquisa,            obrigatoria, 4, 5).
disciplina(rp_grafos,                   obrigatoria, 6, 5).
disciplina(metodos_quantitativos,       obrigatoria, 4, 5).

% 6o periodo (26 creditos)
disciplina(programacao_distribuida,     obrigatoria, 4, 6).
disciplina(gestao_projetos_ageis,       obrigatoria, 6, 6).
disciplina(pesquisa_aplicada,           obrigatoria, 4, 6).
disciplina(aprendizagem_maquina,        obrigatoria, 4, 6).
disciplina(inteligencia_artificial,     obrigatoria, 4, 6).
disciplina(engenharia_software,         obrigatoria, 4, 6).

% 7o periodo (26 creditos)
disciplina(cloud_computing,             obrigatoria, 4, 7).
disciplina(ec_transformador1,           obrigatoria, 4, 7).
disciplina(data_science,                obrigatoria, 6, 7).
disciplina(construcao_interpretadores,  obrigatoria, 4, 7).
disciplina(software_grafico_3d,         obrigatoria, 4, 7).
disciplina(arquitetura_software,        obrigatoria, 4, 7).

% 8o periodo (24 creditos)
disciplina(devops,                      obrigatoria, 4, 8).
disciplina(ec_transformador2,           obrigatoria, 4, 8).
disciplina(avaliacao_desempenho,        obrigatoria, 4, 8).
disciplina(processamento_linguagem_natural, obrigatoria, 4, 8).
disciplina(mundos_virtuais,             obrigatoria, 4, 8).
disciplina(visao_computacional,         obrigatoria, 4, 8).

% Eletivas
% A matriz exige 6 creditos de eletivas "ao longo do curso" e
% cita LIBRAS como optativa. As outras duas sao EXEMPLOS: trocar
% pelas eletivas que a PUCPR realmente oferece (e conferir os
% creditos, inclusive o de LIBRAS). O periodo sugerido de uma
% eletiva e uma decisao do grupo (documentar em decisoes.md).
disciplina(libras,                      eletiva,     2, 5).
disciplina(empreendedorismo_tecnologia, eletiva,     4, 6).
disciplina(computacao_quantica,         eletiva,     4, 7).


% ------------------------------------------------------------
% prerequisito(Disciplina, PreRequisito)
% A matriz oficial nao define pre-requisitos (coluna vazia):
% estes foram definidos pelo grupo. Regras seguidas:
%   1. so pre-requisitos DIRETOS (os indiretos sao deduzidos
%      pela regra prerequisito_transitivo, na Camada 3);
%   2. o pre-requisito sempre e de um periodo ANTERIOR;
%   3. um fato por par (disciplina com 2 pre-requisitos = 2 fatos).
% ------------------------------------------------------------

% Cadeia: Experiencia Criativa (profundidade 4)
prerequisito(ec_criando_solucoes,  ec_navegando_computacao).
prerequisito(ec_inovando,          ec_criando_solucoes).
prerequisito(ec_transformador1,    ec_inovando).
prerequisito(ec_transformador2,    ec_transformador1).

% Cadeia: Sistemas Ciberfisicos
prerequisito(sc_conectividade,         sc_fundamentos).
prerequisito(sc_performance,           sc_conectividade).
prerequisito(sc_sistemas_operacionais, sc_performance).

% Cadeia: Resolucao de Problemas (logica e estruturas)
prerequisito(rp_natureza_discreta,     rp_logica_matematica).
prerequisito(rp_estruturados,          rp_natureza_discreta).
prerequisito(rp_grafos,                rp_estruturados).
prerequisito(complexidade_algoritmos,  rp_estruturados).

% Cadeia: Programacao
prerequisito(programacao_imperativa,       raciocinio_algoritmico).
prerequisito(programacao_web,              raciocinio_algoritmico).
prerequisito(programacao_oo,               programacao_imperativa).
prerequisito(programacao_logica_funcional, programacao_imperativa).
prerequisito(programacao_logica_funcional, rp_logica_matematica).
prerequisito(construcao_interpretadores,   programacao_logica_funcional).
prerequisito(construcao_interpretadores,   rp_estruturados).

% Engenharia / modelagem
prerequisito(modelagem_sistemas,    programacao_oo).
prerequisito(engenharia_software,   modelagem_sistemas).
prerequisito(arquitetura_software,  engenharia_software).

% Redes, sistemas e infraestrutura
% (devops chega a sc_fundamentos por 6 niveis: a cadeia mais longa)
prerequisito(seguranca_informacao,     sc_conectividade).
prerequisito(redes_convergentes,       sc_conectividade).
prerequisito(programacao_distribuida,  sc_sistemas_operacionais).
prerequisito(programacao_distribuida,  redes_convergentes).
prerequisito(cloud_computing,          programacao_distribuida).
prerequisito(devops,                   cloud_computing).
prerequisito(avaliacao_desempenho,     sc_performance).
prerequisito(avaliacao_desempenho,     metodos_quantitativos).

% Dados e inteligencia artificial
prerequisito(big_data,                 arquitetura_banco_dados).
prerequisito(inteligencia_artificial,  rp_grafos).
prerequisito(aprendizagem_maquina,     metodos_quantitativos).
prerequisito(data_science,             big_data).
prerequisito(data_science,             aprendizagem_maquina).
prerequisito(processamento_linguagem_natural, aprendizagem_maquina).
prerequisito(processamento_linguagem_natural, inteligencia_artificial).
prerequisito(visao_computacional,      aprendizagem_maquina).

% Computacao grafica
prerequisito(software_grafico_3d,      modelagem_fenomenos_fisicos).
prerequisito(software_grafico_3d,      programacao_oo).
prerequisito(mundos_virtuais,          software_grafico_3d).

% Pesquisa
prerequisito(pesquisa_aplicada,        metodos_pesquisa).
prerequisito(metodos_pesquisa,         ec_criando_solucoes).

% Disciplinas que ficariam sem pre-requisito em periodos avancados.
% Sem estes fatos, um calouro poderia cursar, por exemplo, Gestao de
% Projetos (6o periodo) no 1o semestre, porque forall e verdadeiro
% por vacuidade quando nao ha pre-requisito.
prerequisito(arquitetura_banco_dados,     raciocinio_algoritmico).
prerequisito(modelagem_fenomenos_fisicos, rp_logica_matematica).
prerequisito(clinica_tic,                 ec_navegando_computacao).
prerequisito(metodos_quantitativos,       rp_natureza_discreta).
prerequisito(gestao_projetos_ageis,       modelagem_sistemas).

% Cadeia: formacao humanistica (disciplinas institucionais)
prerequisito(etica,                       filosofia).
prerequisito(teologia_sociedade,          etica).


% ------------------------------------------------------------
% Regra de formatura (dado da matriz, por isso e fato):
% todas as obrigatorias + pelo menos 6 creditos de eletivas.
% ------------------------------------------------------------
creditos_eletivos_minimos(6).


% ------------------------------------------------------------
% Alunos ficticios de teste
% ------------------------------------------------------------
aluno(ana).    % adiantada: 1o ao 4o completos + parte do 5o
aluno(bruno).  % ritmo normal: 1o e 2o completos
aluno(carla).  % atrasada/trancamento: reprovou logica, trancou parte do 2o
aluno(diego).  % calouro: nenhum historico (caso de borda)
aluno(eva).    % formanda: falta so o 8o periodo e o Projeto Transformador I

% cursou(Aluno, Disciplina)

% --- ana ---
cursou(ana, ec_navegando_computacao).
cursou(ana, raciocinio_algoritmico).
cursou(ana, rp_logica_matematica).
cursou(ana, sc_fundamentos).
cursou(ana, filosofia).
cursou(ana, programacao_web).
cursou(ana, programacao_imperativa).
cursou(ana, arquitetura_banco_dados).
cursou(ana, rp_natureza_discreta).
cursou(ana, sc_conectividade).
cursou(ana, etica).
cursou(ana, ec_criando_solucoes).
cursou(ana, programacao_oo).
cursou(ana, modelagem_fenomenos_fisicos).
cursou(ana, seguranca_informacao).
cursou(ana, sc_performance).
cursou(ana, clinica_tic).
cursou(ana, programacao_logica_funcional).
cursou(ana, rp_estruturados).
cursou(ana, big_data).
cursou(ana, modelagem_sistemas).
cursou(ana, redes_convergentes).
cursou(ana, sc_sistemas_operacionais).
cursou(ana, teologia_sociedade).
cursou(ana, complexidade_algoritmos).
cursou(ana, metodos_quantitativos).
cursou(ana, libras).

% --- bruno ---
cursou(bruno, ec_navegando_computacao).
cursou(bruno, raciocinio_algoritmico).
cursou(bruno, rp_logica_matematica).
cursou(bruno, sc_fundamentos).
cursou(bruno, filosofia).
cursou(bruno, programacao_web).
cursou(bruno, programacao_imperativa).
cursou(bruno, arquitetura_banco_dados).
cursou(bruno, rp_natureza_discreta).
cursou(bruno, sc_conectividade).
cursou(bruno, etica).

% --- carla ---
cursou(carla, ec_navegando_computacao).
cursou(carla, raciocinio_algoritmico).
cursou(carla, sc_fundamentos).
cursou(carla, filosofia).
cursou(carla, programacao_imperativa).
cursou(carla, etica).

% --- diego: nenhum fato cursou/2 ---

% --- eva (formanda) ---
% (Camada 1 so tem fatos: o historico e listado por extenso.)
cursou(eva, ec_navegando_computacao).
cursou(eva, raciocinio_algoritmico).
cursou(eva, rp_logica_matematica).
cursou(eva, sc_fundamentos).
cursou(eva, filosofia).
cursou(eva, programacao_web).
cursou(eva, programacao_imperativa).
cursou(eva, arquitetura_banco_dados).
cursou(eva, rp_natureza_discreta).
cursou(eva, sc_conectividade).
cursou(eva, etica).
cursou(eva, ec_criando_solucoes).
cursou(eva, programacao_oo).
cursou(eva, modelagem_fenomenos_fisicos).
cursou(eva, seguranca_informacao).
cursou(eva, sc_performance).
cursou(eva, clinica_tic).
cursou(eva, programacao_logica_funcional).
cursou(eva, rp_estruturados).
cursou(eva, big_data).
cursou(eva, modelagem_sistemas).
cursou(eva, redes_convergentes).
cursou(eva, sc_sistemas_operacionais).
cursou(eva, teologia_sociedade).
cursou(eva, complexidade_algoritmos).
cursou(eva, ec_inovando).
cursou(eva, metodos_pesquisa).
cursou(eva, rp_grafos).
cursou(eva, metodos_quantitativos).
cursou(eva, programacao_distribuida).
cursou(eva, gestao_projetos_ageis).
cursou(eva, pesquisa_aplicada).
cursou(eva, aprendizagem_maquina).
cursou(eva, inteligencia_artificial).
cursou(eva, engenharia_software).
cursou(eva, cloud_computing).
cursou(eva, data_science).
cursou(eva, construcao_interpretadores).
cursou(eva, software_grafico_3d).
cursou(eva, arquitetura_software).
cursou(eva, libras).
cursou(eva, empreendedorismo_tecnologia).