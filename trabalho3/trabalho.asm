#################################################
#* UNIVERSIDADE DE BRASÍLIA                     #
#* INSTITUTO DE CIÊNCIAS EXATAS                 #
#* DEPARTAMENTO DE CIÊNCIA DA COMPUTAÇÃO        #
#* CIC 116394 (OAC)                             #
#* ORGANIZAÇÃO E ARQUITETURA DE COMPUTADORES    #
#* TURMA C - 2021/1                             #
#*                                              #
#* Trabalho III: Programação em assembly para o #
#* RISC-V32                                     #
#*                                              # 
#* Aluno: SAMUEL JAMES DE LIMA BARROSO          #
#* Matrícula: 19/0019948                        #
#*                                              #
#################################################


#################################################
# Área de Dados                                 #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
.data                                           #
color:          .word  0x00FFFF                 # azul turquesa
dx:             .word  64                       # linha com 64 pixels
dy:             .word  64                       # 64 linhas
org:            .word  0x10040000               # endereço da origem da imagem (heap)
                                                #
want_to_draw:                                   #
.asciz "Deseja desenhar uma linha? (s/n): "     #
yes:                                            #
.ascii "s"                                      #
newline:                                        #
.ascii "\n"                                     #
digite_x0:                                      #
.asciz "Digite um valor para x0: "              #
digite_y0:                                      #
.asciz "Digite um valor para y0: "              #
digite_x1:                                      # 
.asciz "Digite um valor para x1: "              #
digite_y1:                                      #
.asciz "Digite um valor para y1: "              #
#################################################


#################################################
# Área de Código                                #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
.text                                           #
#################################################
# Interface com o usuário                       # 
# Utilizando as chamadas do sistema, escreve-se #
# uma mensagem solicitando que o usuário entre  #
# com os valores (x0, y0) e (x1, y1) da linha   # 
# a ser desenhada.                              #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
                                                #
main:                                           #
                li     a7, 4                    # print string
                la     a0, want_to_draw         #
                ecall                           # "Deseja desenhar uma linha? (s/n): " 
                                                #
                li     a7, 12                   # read char
                ecall                           #
                lb     a1, yes                  #
                bne    a0, a1, exit_program     # if (readchar() != 's') exit 0;
                                                # 
                lb     a0, newline              # 
                li     a7, 11                   # 
                ecall                           # prinf("\n");
                                                #
                li     a7, 4                    # print string
                la     a0, digite_x0            #
                ecall                           #
                li     a7, 5                    # read int
                ecall                           #
                add    s0, x0, a0               # read x0 to s0
                                                #
                li     a7, 4                    # print string
                la     a0, digite_y0            #
                ecall                           #
                li     a7, 5                    # read int
                ecall                           #
                add    s1, x0, a0               # read y0 to s1
                                                #
                li     a7, 4                    # print string
                la     a0, digite_x1            #
                ecall                           #  
                li     a7, 5                    # read int
                ecall                           #
                add    s2, x0, a0               # read x1 to s2
                                                #
                li     a7, 4                    # print string
                la     a0, digite_y1            #
                ecall                           #
                li     a7, 5                    # read int
                ecall                           #
                add    s3, x0, a0               # read y1 to s3
                                                # 
                add    a0, x0, s0               #
                add    a1, x0, s1               #
                add    a2, x0, s2               #
                add    a3, x0, s3               #
                call   line                     # line(x0, y0, x1, y1);
                j      main                     #
                                                #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
exit_program:                                   #
                li     a7, 10                   #
                ecall                           #
                                                #
#################################################
# início de rotina: ponto                       #
# void ponto(int x, int y);                     #
#                                               #
# parâmetros:                                   # 
# a0 <- x                                       #
# a1 <- y                                       #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
                                                #
ponto:          sw     ra, 0(sp)                #
                addi   sp, sp, -4               #
                call   getaddress               #
                lw     t0, color                #
                sw     t0, (a0)                 #
                addi   sp, sp, 4                #
                lw     ra, 0(sp)                #  
                ret                             #
                                                #
################################################# 
# início de rotina: getaddress                  #
# int getaddress(int x, int y);                 #
#                                               #
# parâmetros:                                   # 
# a0 <- x                                       #
# a1 <- y                                       #
#                                               #
# retorno:                                      #
# a0 <- endereço do pixel.                      #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
                                                #
getaddress:                                     # 
                addi   t0, x0, 4                # // t0 = 4;
                mul    a0, a0, t0               # // x *= 4;
                mul    a1, a1, t0               # // y *= 4;
                lw     t0, dx                   # // t0 = largura da tela, em pixels;
                mul    a1, a1, t0               # 
                add    a0, a0, a1               # end = 4*x + 4*dx*y; 
                lw     a1, org                  # 
                add    a0, a0, a1               # end += org;
                ret                             #
                                                #
################################################# 
# início de rotina: line                        #
# void line (int x0, int y0, int x1, int y1);   #
#                                               #
# parâmetros:                                   #
# a0 <- x0                                      #
# a1 <- y0                                      #
# a2 <- x1                                      #
# a3 <- y1                                      #
#                                               #
# Observações:                                  # 
# - A implementação desta função é levemente    #
# diferente da solicitada no trabalho. Também   #
# foi implementado os casos onde dy > dx, e     #
# os casos onde x0>x1, y0>y1, x0==x1, y0==y1    #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
                                                #
line:           sw     ra, 0(sp)                # 
                addi   sp, sp, -4               #
                bge    a2, a0, xOK              # if (x0 > x1)
                add    t0, x0, a0               #    
                add    a0, x0, a2               #    
                add    a2, x0, t0               #    
                add    t0, x0, a1               #
                add    a1, x0, a3               #
                add    a3, x0, t0               # swap P0, P1, so x1 is always > x0
                                                #
xOK:            add    s4, x0, a0               # s4=x=x0
                add    s5, x0, a1               # s5=y=y0
                add    s6, x0, a2               # s6=x1
                add    s7, x0, a3               # s7=y1
                sub    s0, s6, s4               # (s0=dx) = x1 - x0
                sub    s1, s7, s5               # (s1=dy) = y1 - y0
                addi   s8, x0, 1                # s8 will be the y increment
                bge    s1, x0, yOK              #
                addi   s8, x0, -1               #
                mul    s1, s1, s8               #
yOK:                                            #
                beq    x0, s0, vLine            # if (dx == 0) then draw a vertical line
                beq    x0, s1, hLine            # if (dy == 0) then draw a horizontal line
                                                #
                add    a0, x0, s4               #
                add    a1, x0, s5               #
                call   ponto                    # ponto(x0,y0)
                                                #
                bge    s0, s1, dx_ge_dy         # if (dx >= dy) goto dx_ge_dy;
                j      dx_lt_dy                 # else goto dx_lt_dy;
                                                # 
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
# dx_ge_dy: trecho de código que implementa o   #
# algoritmo padrão fornecido na descrição do    #
# trabalho. Este é o caso onde dx >= dy.        #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
                                                # 
dx_ge_dy:       addi   t2, x0, 2                # temporary saving 2 on t2
                mul    s2, t2, s1               # D = 2*dy;
                sub    s2, s2, s0               # D -= dx;
                                                # D = 2*dy - dx;
                addi   s4, s4, 1                # x = x0+1       
                                                # 
dx_ge_dy_lp:    addi   t1, x0, 1                # temporary saving 1 on t1
                bge    s2, t1, inc_y            # if (D > 0) goto inc_y;
                                                # else {
                addi   t2, x0, 2                #     t2 = 2;
                mul    t2, s1, t2               #     t2 = 2*dy; 
                add    s2, s2, t2               #     D = D + (2*dy);                        
                                                #}
                j      dx_ge_dy_el              #
inc_y:                                          # inc_y: {
                add    s5, s5, s8               #     y+=s8; 
                addi   t2, x0, 2                #     t2 = 2;
                mul    t3, s1, t2               #     t3 = 2*dy
                mul    t4, s0, t2               #     t4 = 2*dx
                add    s2, s2, t3               #     D += 2*dy;
                sub    s2, s2, t4               #     D -= 2*dx; --> all these lines are equivalent to D = D + (2*dy-2*dx); 
                                                # }
dx_ge_dy_el:    add    a0, x0, s4               #
                add    a1, x0, s5               #
                call   ponto                    # ponto(x, y)
                beq    s4, s6, line_end         # if (x == x1) return;
                addi   s4, s4, 1                # x++
                j      dx_ge_dy_lp              #
                                                #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
# dx_lt_dy: trecho de código que implementa o   #
# um algoritmo levemente diferente do fornecido #
# na descrição do trabalho. Este é o caso onde  #
# dy > dx. Assim, é preciso adaptar um pouco a  #
# execução, trocando as operações em x por y e  #
# vice versa.                                   #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
                                                # 
dx_lt_dy:       addi   t2, x0, 2                # temporary saving 2 on t2
                mul    s2, t2, s0               # D = 2*dx;
                sub    s2, s2, s1               # D -= dy;
                                                # D = 2*dx - dy;
                add    s5, s5, s8               # y = y0+s8       
                                                # 
dx_lt_dy_lp:    addi   t1, x0, 1                # temporary saving 1 on t1
                bge    s2, t1, inc_x            # if (D > 0) goto inc_x;
                                                # else {
                addi   t2, x0, 2                #     t2 = 2;
                mul    t2, s0, t2               #     t2 = 2*dx; 
                add    s2, s2, t2               #     D = D + (2*dx);                        
                                                #}
                j      dx_lt_dy_el              #
inc_x:                                          # inc_x: {
                addi   s4, s4, 1                #     x++; 
                addi   t2, x0, 2                #     t2 = 2;
                mul    t3, s0, t2               #     t3 = 2*dx
                mul    t4, s1, t2               #     t4 = 2*dy
                add    s2, s2, t3               #     D += 2*dx;
                sub    s2, s2, t4               #     D -= 2*dy; --> all these lines are equivalent to D = D + (2*dx-2*dy); 
                                                # }
dx_lt_dy_el:    add    a0, x0, s4               #
                add    a1, x0, s5               #
                call   ponto                    # ponto(x, y)
                beq    s5, s7, line_end         # if (y == y1) return;
                add    s5, s5, s8               # y+=s8
                j      dx_lt_dy_lp              #
                                                #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
# hLine: trecho de código que desenha uma linha #
# horizontal.                                   #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
                                                # 
hLine:          add    a0, x0, s4               #
                add    a1, x0, s5               #
                call   ponto                    # ponto(x, y)
                beq    s4, s6, line_end         # 
                addi   s4, s4, 1                #
                j      hLine                    #
                                                #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
# vLine: trecho de código que desenha uma linha #
# vertical.                                     #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
                                                # 
vLine:          add    a0, x0, s4               #
                add    a1, x0, s5               #
                call   ponto                    # ponto(x, y)
                beq    s5, s7, line_end         #
                add    s5, s5, s8               # 
                j      vLine                    #
                                                # 
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
# line_end: trecho de código que finaliza a     #
# execução da função e desempilha o return      #
# address da pilha.                             #
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  # 
                                                # 
line_end:       addi   sp, sp, 4                #
                lw     ra, 0(sp)                #
                ret                             #
                                                # 
#################################################
