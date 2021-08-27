```
UNIVERSIDADE DE BRASÍLIA
INSTITUTO DE CIÊNCIAS EXATAS 
DEPARTAMENTO DE CIÊNCIA DA COMPUTAÇÃO
116394 ORGANIZAÇÃO E ARQUITETURA DE COMPUTADORES 
TURMA C - 2021/1

Trabalho II: Simulador RISCV (32 bits)

Aluno: SAMUEL JAMES DE LIMA BARROSO
Matrícula: 19/0019948
Plataforma: Ubuntu Server 18.04.5 LTS
Compilador: gcc version 7.5.0 (Ubuntu 7.5.0-3ubuntu1~18.04)
IDE: Visual Studio Code (com extensão Remote SSH)
```

# Simulador RISCO (RiscV32I)

## Apresentação do problema
	
Este projeto tem como objetivo principal desenvolver, em linguagem de programação C/C++, um simulador (bem simplificado) de um processador que executa instruções da arquitetura RiscV de 32 bits. 

O simulador consiste em um programa que lê arquivos binários que contém códigos de um programa para RiscV compilado em assembly, por meio da ferramenta RARS, e os executa em um ambiente emulado.

A importância deste projeto está em entender mais aprofundadamente, de forma prática, a organização da ISA (Instruction Set Architecture) do RISC-V. O desenvolvimento desse simulador nos permitirá ter mais familiaridade e prática com essa arquitetura.

## Descrição da Implementação

Inicialmente, pensei em desenvolver esse projeto utilizando *Orientação a Objetos do C++*. Acreditava que seria útil utilizar conceitos de abstração e hierarquia/herança de classes, juntamente com interfaces, para resolver o problema da execução das instruções. [Neste estágio do projeto](https://github.com/SAMXPS/OAC-UnB/commit/12bb4b92d1f79e17bdb099a2a34838f6270cd76f#diff-ad77bbbac4b34264abae0831a0aa1289bdaa3f76474973f45b810cebe00dbea3), cada instrução tinha um executor que implementava uma classe "InstructionExecutor", com vários detalhes interessantes. Entretanto, comecei a me perder dentro da implementação por conta da *sintaxe extremamente carregada*.

Nesse contexto, eu poderia ter tentado utilizar overloading de operadores do C++ pra me ajudar. Entretanto, resolvi recomeçar a implementação das instruções de uma forma diferenciada, por meio de um [*arquivo de template*](template/instructions.cpp.template), que posteriormente se tornaria um arquivo de código de C++, por meio do programa [*generate_instructions*](template/generate_instructions), escrito em *Ruby*, e um arquivo [*instruction_set*](template/instruction_set) contendo todas as instruções e um código enxuto de implemetalões.

Basicamente, o programa [*generate_instructions*](template/generate_instructions) lê o arquivo de instruções e, para cada linha, aplica uma expressão em *regex* para extrair os campos *nome, opcode, funct3, funct7 e code* para cada instrução substitui os valores no arquivo de template. Antes de substituir o campo *code*, o programa também faz uma limpeza de sintaxe, inserindo quebras de linha e identação.

Dessa forma, *é possível alterar as instruções em um arquivo de acesso rápido*, bastando apenas rodar o script *generate_instructions.sh* para gerar um novo [*Instructions.cpp*](src/Instructions.cpp).
> nota : é preciso ter o ambiente ruby instalado para rodar o script. Entretanto, não é obrigatório para compilação, uma vez que já forneci o arquivo gerado pelo script dentro deste projeto.

### Decodificação das instruções

A decodificação das instruções é feita na classe [InstructionDecoder](src/InstructionDecoder.hpp). Essa classe é responsável por receber todos os códigos binários e extrair os bits, fazer extensões de sinal e *hashing* das instruções.

A ideia de hashing foi feita com intuito de agilizar o processo de execução das instruções dentro do ambiente C++, por meio de um *unordered_map*. Nesse contexto, cada instrução foi mapeada com seu opcode, funct3 e funct7 para um número de 32 bits que posteriormente é utilizado como chave no HashMap.

### (TODO) como implementaram as classes de instruções:
- lógico-aritméticas
- saltos condicionais
- jumps
- acesso à memória
- chamadas do sistema

## Testes (TODO: explain)

### Modo de DEBUG

