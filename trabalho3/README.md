```
UNIVERSIDADE DE BRASÍLIA
INSTITUTO DE CIÊNCIAS EXATAS 
DEPARTAMENTO DE CIÊNCIA DA COMPUTAÇÃO
116394 ORGANIZAÇÃO E ARQUITETURA DE COMPUTADORES 
TURMA C - 2021/1

Trabalho III: Programação em assembly para RiscV (32)

Aluno: SAMUEL JAMES DE LIMA BARROSO
Matrícula: 19/0019948
```

# Relatório de Implementação

## Objetivo

O objetivo deste trabalho é reforçar as habilidades de programação em assembly utilizando o conjunto de instruções disponíveis para a arquitetura RiscV por meio do software de emulação *Rars*. Além disso, será abordado o conceito de desenho gráficos por meio da ferramena de mapeamento de memória <-> imagem desse software. Nesse contexto, o programa a ser desenvolvido será capaz de desenhar linhas (segmentos de retas, com ponto inicial e ponto final) na tela fornecida (pode-se considerar uma tela 2d RGB com coordenadas x,y e tamanho 64x64).

## Documentação do código

Nas linhas seguintes será feita uma breve documentação do código assembly construído, separada por labels. Além da documentação contida aqui, existem, também, vários comentários úteis dentro do arquivo *.asm*.

### main

Interface com o usuário, feita utilizando as chamadas do sistema (*ecall*). É escrito uma mensagem solicitando que o usuário entre com os valores (x0, y0) e (x1, y1) da linha a ser desenhada. Antes da execução, é perguntado ao usuário se ele deseja desenhar mais uma linha. Para desenhar uma nova linha, basta pressionar a tecla 's'. Caso qualquer outra tecla seja pressionada, o programa termina.

### ponto

Rotina que recebe as coordenadas *(x,y)* de um ponto e o colore na tela. Os parâmetros são passados nos registradores *a0 = x*, *a1 = y*. Internamente, essa rotina utiliza a sub-rotina getaddress para calcular o endereçamento correto na memória.

### getaddress

Rotina que recebe as coordenadas *(x,y)* de um ponto e retorna o endereço de memória associado ao pixel que este ponto representa. Os parâmetros são passados nos registradores *a0 = x*, *a1 = y*. O retorno é escrito em *a0*.
O funcionamento básico dessa rotina é multiplicar y pela quantidade de colunas, somar com x e multiplicar o resultado soma por 4. Finalmente, é somado o endereço base.

### line

Rotina que recebe duas coordenadas de ponto e desenha na tela uma linha conectando-as utilizando o algoritmo de Bresenham. 
> Nota: neste trabalho, foram implementadas todas as possibilidades do algoritmo de Bresenham, não somente o caso onde dx > dy e x1 > x0 e y1 > y0. Dessa forma, os pontos informados podem ser quaisquer um dentro da tela.

Nas linhas iniciais da rotina, é feita uma verificação de qual ponto está mais à direita, ou seja, qual deles possui a coordenada x maior. Caso x1 seja menor que x0, é feito um swap entre os dois pontos.

Em seguida, é verificado se a coordenada y1 é maior ou menor que y0. Caso y1 seja maior que y0, o valor *1* é salvo no registrador *s8*. Caso y1 seja menor que y0, o valor *-1* é salvo no registrador *s8*. O registrador *s8* será utilizado como *delta y*, ou seja, valor a ser incrementado em y, podendo ser positivo ou negativo.

Depois disso, é feito o cálculo de *dx* e *dy*, conforme descrito no algoritmo de Bresenham. Com esse cálculo, surgem 4 possibilidades de execução do algoritmo:

- Caso dx == 0, segue para **vLine**.
- Caso dy == 0, segue para **hLine**.
- Caso dx >= dy, proessegue para **dx_ge_dy**.
- Caso dx < dy, proessegue para **dx_lt_dy**.

#### hLine

Rotina que desenha uma linha horizontal na tela, ou seja, há variação apenas na coordenada x.

#### vLine

Rotina que desenha uma linha vertical na tela, ou seja, há variação apenas na coordenada y.

#### dx_ge_dy

Rotina padrão solicitada no trabalho, caso onde a variação em x é maior que a variação em y.

#### dx_lt_dy

Rotina adicional implementada, caso onde a variação de y é maior que a variação em x. Nessa parte, a ideia geral é adaptar o algoritmo de Bresenham, "trocando x por y", isto é, incrementando y de y0+1 até y1 e, a cada passo, utilizando D para definir se será feito x+=1 ou não. De forma geral, é um espelhamento do algoritmo de x pra y e vice versa.

Essa rotina, juntamente com *hLine* e *vLine* foram implementadas para que seja possível desenhar linhas em **qualquer orientação** dentro da tela.

## Observação adicional

Conforme orientado pelo professor, o modelo compacto não suporta um display de 64 x 64. Vai ultrapassar o limite da heap. Para fazer funcionar, foi utilizado a configuração de memória default, onde o endereço da heap é 0x10040000.