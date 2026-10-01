## Camada 1 (fatos)

Usamos a matriz oficial de Ciência da Computação da PUCPR (Resolução 166/2023, ingressantes a partir de 2023/1). São 47 disciplinas obrigatórias em 8 períodos, e os créditos vieram da coluna CRED. Conferimos que a soma de cada período bate com o total da matriz (24, 24, 26, 26, 24, 26, 26 e 24).

A matriz não traz pré-requisitos (a coluna REQUISITO está vazia), então definimos os nossos. Seguimos três regras:

- só colocamos o pré-requisito direto como fato. O indireto o Prolog deduz pela regra `prerequisito_transitivo`, então não faz sentido guardar ele também;
- o pré-requisito sempre é de um período anterior, senão a própria grade sugerida ficaria impossível de cumprir;
- um fato por par. Se uma disciplina tem dois pré-requisitos, são dois fatos `prerequisito`, e não uma lista dentro de um fato só.

Para montar as cadeias aproveitamos as "famílias" que a grade já tem: as Experiências Criativas (Navegando, Criando Soluções, Inovando, Projeto Transformador I e II), as de Sistemas Ciberfísicos, as de Resolução de Problemas (Lógica Matemática, Natureza Discreta, Estruturados, Grafos) e as de Programação. A cadeia mais longa ficou a de DevOps, com 6 níveis até Fundamentos de Sistemas Ciberfísicos.

Na primeira versão algumas disciplinas de períodos mais avançados ficaram sem pré-requisito, como Gestão de Projetos (6º) e Métodos Quantitativos (5º). Percebemos isso testando a Camada 2: o `forall` dava verdadeiro por vacuidade e o calouro aparecia podendo cursar essas disciplinas logo no primeiro semestre. Resolvemos adicionando pré-requisitos que fazem sentido, por exemplo Métodos Quantitativos depois de Natureza Discreta, e Filosofia antes de Ética, que vem antes de Teologia e Sociedade. Depois disso a trilha mínima de um calouro com 26 créditos por semestre passou a ter 8 semestres, que é a duração do curso.

Sobre as eletivas: a matriz pede 6 créditos, mas a única optativa que ela cita é LIBRAS. Cadastramos LIBRAS e mais duas eletivas de exemplo (`empreendedorismo_tecnologia` e `computacao_quantica`) só para ter as 3 que o enunciado pede. A regra de formatura também virou fato: `creditos_eletivos_minimos(6)`. Deixamos de fora o Projeto Comunitário e as Atividades Complementares, porque não são disciplinas que a pessoa cursa num semestre específico.

Todos os nomes são átomos em minúsculo, sem acento e sem aspas. Não usamos os códigos da matriz (tipo PCO109A) porque começam com maiúscula e o Prolog ia entender como variável. Os prefixos `ec_`, `rp_` e `sc_` são só para agrupar as famílias de disciplinas.

Criamos o fato `aluno/1` porque, sem ele, um aluno sem nenhum histórico não aparece em nenhum `cursou` e fica igual a um aluno que nem existe.

Os alunos de teste são cinco:

- `ana`, adiantada;
- `bruno`, no ritmo normal;
- `carla`, atrasada (reprovou em Lógica Matemática e trancou parte do 2º período);
- `diego`, calouro, sem histórico;
- `eva`, formanda.

A eva foi adicionada depois, por causa dos testes de enumeração (explicado mais abaixo).

## Camada 2 (elegibilidade)

O `prerequisitos_ok` usa `forall(prerequisito(D, P), cursou(A, P))`. É o "para todo" da lógica de primeira ordem: para todo P que é pré-requisito de D, o aluno cursou P. O `forall` não foi visto em aula, mas o enunciado pede. Ele equivale a `\+ (prerequisito(D, P), \+ cursou(A, P))`, ou seja, "não existe pré-requisito que o aluno não cursou". Preferimos o `forall` porque fica mais fácil de ler do que duas negações.

Em todos os predicados, `aluno(Aluno)` e `disciplina(Disciplina, ...)` vêm antes de qualquer `\+`. Testamos o contrário e `\+ cursou(_, D)` com `D` sem valor não significa "uma disciplina que ninguém cursou", e sim "ninguém cursou nada", o que dá falso direto. Colocar `aluno(Aluno)` primeiro também resolve outro problema: sem ele, `prerequisitos_ok(zeca, filosofia)` dava verdadeiro, mesmo o zeca não existindo, porque Filosofia não tem pré-requisito.

Sobre `findall`, `setof` e `bagof`:

- em `disciplinas_liberadas` e `disciplinas_pendentes` usamos `findall`, porque não tem repetição para tirar e, quando não acha nada, ele devolve `[]`. O `setof` falharia nesse caso, e lista vazia é uma resposta válida;
- em `creditos_cursados` o `findall` é obrigatório: se o aluno fez três disciplinas de 4 créditos, a lista tem que ser `[4, 4, 4]`. Com `setof` ela virava `[4]` e a soma dava errado;
- em `ancestrais` usamos `setof`, porque o mesmo pré-requisito pode ser alcançado por dois caminhos. Por exemplo, Lógica Matemática chega a Construção de Interpretadores por dois lados, e o `findall` traz ela repetida (7 itens contra 6 do `setof`);
- o `bagof` aparece no `demo` e em `trilhas_por_duracao`, para agrupar as trilhas pela quantidade de semestres.

O `soma_lista` segue o mesmo padrão do `somaLista` das listas de exercício: lista vazia soma 0, senão soma o resto e adiciona o primeiro.

## Camada 3 (fecho transitivo e trilhas)

O `prerequisito_transitivo` segue a mesma ideia do `rota` das listas de exercício: ou é pré-requisito direto, ou é pré-requisito de um pré-requisito. A diferença é que guardamos uma lista das disciplinas já visitadas. Sem ela, se a base tiver um ciclo, a recursão nunca para. O `existe_ciclo(D)` é exatamente o que o enunciado pede: `prerequisito_transitivo(D, D)`.

Para gerar as trilhas não usamos `assert` nem `retract`. O "estado" do aluno durante a simulação é uma lista com as disciplinas que ele já cursou, passada de uma chamada para a outra. Quando o Prolog volta atrás no backtracking, essa lista volta junto, sem nada sobrando na base. Com `assert` isso não acontece, que é justamente o problema que a tabela de armadilhas do enunciado descreve.

O `gerar_trilha` funciona assim: se o aluno já está formado (todas as obrigatórias e 6 créditos de eletivas), acabou. Se não, ele olha as disciplinas disponíveis, escolhe um grupo que caiba no limite de créditos e chama a si mesmo com a lista atualizada. A escolha do grupo é o ponto de backtracking: se não der para formar por aquele caminho, ele volta e tenta outro grupo.

Em cada passo só conferimos os pré-requisitos diretos, e isso já garante os indiretos: se A depende de B e B depende de C, B só entra depois de C, então quando A entrar C já estará lá. Mesmo assim fizemos o `verificar_trilha`, que confere cada trilha usando o fecho transitivo, para ter uma prova que não depende da mesma lógica que gerou a trilha.

Para a busca não travar:

- tem o limite de 12 semestres que o enunciado pede;
- antes de continuar um caminho, o programa calcula o mínimo de semestres que ainda faltam (pelos créditos e pela maior cadeia de pré-requisitos pendente). Se não cabe no tempo que sobra, ele abandona aquele caminho na hora;
- as disciplinas de um semestre seguem sempre a mesma ordem, então [a, b] e [b, a] não contam como trilhas diferentes;
- eletivas só entram enquanto ainda faltam créditos de eletiva.

A primeira coisa que tentamos para "enumerar várias trilhas" foi pedir todas as trilhas do diego. Isso não terminou. Com 47 disciplinas são milhões de combinações, que é a explosão combinatória da tabela de armadilhas. Por isso a enumeração é sempre limitada: o `demo` pega as 20 primeiras trilhas do aluno com `findall` e `limit`, e o `bagof` agrupa essas 20 por duração. Para testar que o `findall` acha todas as trilhas, usamos a eva, que está quase formando. Ela tem 32 trilhas possíveis em até 2 semestres e 665 em até 3, então dá para conferir o resultado.

O único corte que usamos está no `aluno_valido`, e ele não muda o resultado das consultas, só evita repetir a validação. No resto usamos `once` e if-then-else.

## Tratamento de erros

- aluno ou disciplina que não existe: na Camada 2 a consulta simplesmente dá `false`. Na Camada 3, dá `false` com um aviso;
- aluno sem histórico: funciona normal, com listas vazias, 0 créditos e a trilha completa até a formatura;
- limite de créditos inválido (texto, zero ou negativo): `false` com aviso, sem erro de execução;
- disciplina que não cabe no limite de créditos, ou formatura impossível dentro de 12 semestres: falha na hora, com aviso dizendo o motivo;
- pedir mais de 12 semestres: recusado com aviso;
- ciclo na base: `existe_ciclo` encontra, o fecho transitivo continua terminando, e as trilhas são recusadas com um aviso que lista as disciplinas do ciclo.

## Testes

Cada teste tem duas partes: `teste(Id, Descricao)` e `caso(Id) :- ...`, onde o resultado esperado fica dentro do próprio `caso`. Os testes que precisam falhar usam `\+`. No começo os testes eram guardados numa variável e executados com `once(Objetivo)`, mas o SWISH bloqueou isso (o sandbox não deixa executar um objetivo que ele não consegue ver antes). Com `caso(Id)` ele sabe o que vai ser executado.

São 39 testes, cobrindo os casos obrigatórios da Seção 8 e alguns casos de borda: aluno sem histórico, aluno e disciplina inexistentes, limite inválido e formatura impossível.

O teste de ciclo fica num arquivo separado porque precisa de uma base com ciclo, e a base oficial não pode ter um. Ele carrega o sistema e adiciona um único pré-requisito errado: Raciocínio Algorítmico passando a depender de POO, que já depende de Raciocínio por meio de Imperativa.

## SWISH e SWI-Prolog

Desenvolvemos no SWISH, mas o projeto é entregue para o SWI-Prolog. Por isso:

- no SWI, cada arquivo carrega o anterior com `ensure_loaded`. No SWISH, o equivalente é `include`. Deixamos as duas linhas no topo de cada arquivo, com a do SWISH comentada;
- `prerequisito/2` é `multifile` porque, no SWI, o teste de ciclo é outro arquivo. Sem isso o SWI acha que estamos redefinindo o predicado e apaga os pré-requisitos originais;
- usamos `discontiguous` porque, no SWISH, o fato do ciclo fica longe dos outros `prerequisito` e aparecia um aviso de cláusulas separadas. A própria mensagem do SWI-Prolog sugere o `discontiguous`, e conferimos no manual que ele só tira o aviso. Usamos o mesmo para `teste` e `caso`.

## Limitações

- os pré-requisitos foram escolhidos por nós. Com outros pré-requisitos as trilhas seriam diferentes;
- só LIBRAS é eletiva real, as outras duas são de exemplo;
- mesmo com as podas, o número de trilhas cresce muito rápido. Listar todas só é viável para quem está perto de formar;
- a estimativa de semestres mínimos é otimista. Em alguns casos a busca ainda pode demorar para concluir que não existe trilha;
- não modelamos disciplinas oferecidas só em semestre par ou ímpar, co-requisitos (que a matriz prevê), reprovação durante a simulação, mínimo de créditos por semestre ou limite de vagas;
- o histórico não é conferido: se um `cursou` tiver uma disciplina sem os pré-requisitos dela (aproveitamento de estudos, por exemplo), o sistema aceita.