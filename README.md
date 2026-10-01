# PjBL1 - Curriculum Advisor em Prolog

Trabalho de Programação Lógica e Funcional (PUCPR).

A ideia é representar a grade de Ciência da Computação da PUCPR em Prolog e conseguir responder coisas como "quais disciplinas eu já posso fazer?" e "tem algum caminho daqui até a formatura?". A grade usada é a matriz oficial de 2023.

## Organização

```
projeto/
├── src/
│   ├── curriculum.pl      camada 1: disciplinas, pré-requisitos e alunos de teste
│   ├── elegibilidade.pl   camada 2: o que o aluno pode cursar agora
│   ├── trilhas.pl         camada 3: pré-requisitos indiretos, ciclos e trilhas
│   └── main.pl            carrega tudo e tem o demo
├── tests/
│   ├── consultas_teste.pl testes
│   └── ciclo-teste.pl     teste com um ciclo de pré-requisitos de propósito
├── docs/
│   └── decisoes.md        por que fizemos cada coisa e as limitações
└── README.md
```

Cada arquivo carrega o anterior, então abrindo o `main.pl` vem tudo junto.

## Como rodar

Precisa do SWI-Prolog. Dentro da pasta `projeto/`:

```
swipl src/main.pl
```

Tem que carregar sem nenhum warning. Depois é só rodar:

```prolog
?- demo.
?- demo(diego).
```

O `demo` mostra as três camadas com o aluno bruno. Dá para passar outro aluno, como no segundo exemplo.

## Alunos de teste

- `ana`: adiantada
- `bruno`: no ritmo normal, fez o 1º e o 2º períodos
- `carla`: atrasada, reprovou em Lógica Matemática e trancou parte do 2º período
- `diego`: calouro, ainda não fez nada
- `eva`: quase formando

## Algumas consultas para testar

```prolog
?- disciplinas_do_semestre(1, L).
?- pode_cursar(bruno, D).
?- disciplinas_liberadas(carla, L).
?- disciplinas_pendentes(bruno, L).
?- creditos_cursados(ana, Total).
?- ancestrais(devops, L).
?- trilha_minima(diego, 26, T), imprimir_trilha(T).
?- trilha_valida(diego, 26, T).
?- primeiras_trilhas(diego, 26, 5, Ts).
```

Nas trilhas, o 26 é o máximo de créditos por semestre (é o maior período da grade). O limite de semestres simulados é 12.

Cuidado: não peçam todas as trilhas de um aluno que está no começo do curso, tipo `trilhas_validas(diego, 26, 12, L)`. São milhões de combinações e não termina. Para ver várias trilhas, usem `primeiras_trilhas` ou a eva, que tem poucas.

## Testes

```
swipl -g rodar_testes -t halt tests/consultas_teste.pl
```

Tem que terminar com `39 de 39 testes passaram.` As linhas com `[aviso]` no meio são normais: são os testes que mandam coisa errada de propósito (aluno que não existe, limite inválido etc.) para ver se o programa recusa direito.

O teste de ciclo roda separado, porque ele bagunça a base de propósito:

```
swipl tests/ciclo-teste.pl
```

E aí:

```prolog
?- existe_ciclo(raciocinio_algoritmico).   % true
?- disciplinas_em_ciclo(L).                % as 3 disciplinas do ciclo
?- trilha_valida(diego, 26, T).            % false, com aviso de ciclo
```

## Rodando no SWISH

Os arquivos estão prontos para o SWI-Prolog. Para usar no SWISH, salvem cada arquivo como um programa e, no topo de cada um, comentem a linha do `ensure_loaded` e descomentem a do `include`. As duas nunca podem ficar ativas ao mesmo tempo.