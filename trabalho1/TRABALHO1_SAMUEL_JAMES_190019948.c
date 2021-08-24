/**
 * UNIVERSIDADE DE BRASÍLIA
 * INSTITUTO DE CIÊNCIAS EXATAS 
 * DEPARTAMENTO DE CIÊNCIA DA COMPUTAÇÃO
 * 116394 ORGANIZAÇÃO E ARQUITETURA DE COMPUTADORES 
 * TURMA C - 2021/1
 *
 * Trabalho I: Memória do RISCV 
 *
 * Aluno: SAMUEL JAMES DE LIMA BARROSO
 * Matrícula: 19/0019948
 *
 * Plataforma: Ubuntu Server 18.04.5 LTS 
 * Compilador: gcc version 7.5.0 (Ubuntu 7.5.0-3ubuntu1~18.04)
 * IDE: Visual Studio Code (com extensão Remote SSH)
 */

#include <stdint.h>  
#include <stdio.h>
#include <stdbool.h>

#define MEM_SIZE 4096 

int32_t mem[MEM_SIZE];  // Memória.
int error = 0;          // Flag de erro.
char error_msg[128];    // Espaço para salvarmos as mensagens de erro.

/**
 * Função auxiliar que verifica se o endereço é válido.
 */
bool validateWordAddress(uint32_t address) {
    error = address % 4 != 0 || address >= MEM_SIZE;
    if (error) sprintf(error_msg, "Endereço 0x%08X inválido.\n", (address));
    return !error;
}

int32_t lw(uint32_t address, int32_t kte) {
    if (validateWordAddress(address+kte)) {
        return mem[(address+kte)/4];
    }
    return 0;
}

int32_t lb(uint32_t address, int32_t kte) {
    // OBS: essa validação é feita apenas para saber se estamos em um endereço menor que MEM_SIZE
    if (validateWordAddress(((address+kte)/4) * 4)) {
        int8_t* memb = (int8_t*)mem;    //acessando a memória em bytes
        return (int32_t) memb[address+kte];
    }
    return 0;
}


int32_t lbu(uint32_t address, int32_t kte) {
    // OBS: essa validação é feita apenas para saber se estamos em um endereço menor que MEM_SIZE
    if (validateWordAddress(((address+kte)/4) * 4)) {
        uint8_t* memb = (uint8_t*)mem;    //acessando a memória em bytes
        return (int32_t) memb[address+kte];
    }
    return 0;
}

void sw(uint32_t address, int32_t kte, int32_t dado) {
    if (validateWordAddress(address+kte)) {
        mem[(address+kte)/4] = dado;
    }
}

void sb(uint32_t address, int32_t kte, int8_t dado) {
    // OBS: essa validação é feita apenas para saber se estamos em um endereço menor que MEM_SIZE
    if (validateWordAddress(((address+kte)/4) * 4)) {
        int8_t* memb = (int8_t*)mem;    //acessando a memória em bytes
        memb[address+kte] = dado;
    }
}

/**
 * Função que limpa (escreve 0's) na memória.
 */
void clearMemory() {
    for (int i = 0; i < MEM_SIZE; i++) {
        mem[i] = 0;
    }
}
/**
 * Função que imprime um erro.
 */
void catchError() {
    if (error) {
        printf("Erro: %s", error_msg);
    }
}

/**
 * Função principal que testa as implementações solicitadas.
 */
int main() {

    // Limpamos a memória antes de começar as operações.
    clearMemory();

    // Teste A
    sb(0, 0, 0x04); sb(0, 1, 0x03); sb(0, 2, 0x02); sb(0, 3, 0x01);

    // Teste B
    sb(4, 0, 0xFF); sb(4, 1, 0xFE); sb(4, 2, 0xFD); sb(4, 3, 0xFC);

    // Teste C
    sw(12, 0, 0xFF);

    // Teste D
    sw(16, 0, 0xFFFF);

    // Teste E
    sw(20, 0, 0xFFFFFFFF);

    // Teste F
    sw(24, 0, 0x80000000);

    for (int i = 0; i < 7; i++) {
        // mostrando a memória
        printf("Teste de escrita %c: mem[%d] = 0x%08X\n", 'A' + i, i, mem[i]);
    }
    printf("\n");

    // Testes de leitura
    // 3. Ler os dados e imprimir em hexadecimal:
    printf("Teste de leitura A: \n");
    printf("lb(4,0) = 0x%08X\n", lb(4,0));
    printf("lb(4,1) = 0x%08X\n", lb(4,1));
    printf("lb(4,2) = 0x%08X\n", lb(4,2));
    printf("lb(4,3) = 0x%08X\n", lb(4,3));
    printf("\n");
    printf("Teste de leitura B: \n");
    printf("lbu(4,0) = 0x%08X\n", lbu(4,0));
    printf("lbu(4,1) = 0x%08X\n", lbu(4,1));
    printf("lbu(4,2) = 0x%08X\n", lbu(4,2));
    printf("lbu(4,3) = 0x%08X\n", lbu(4,3));
    printf("\n");
    printf("Teste de leitura C: \n");
    printf("lw(12,0) = 0x%08X\n", lw(12,0));
    printf("lw(16,0) = 0x%08X\n", lw(16,0));
    printf("lw(20,0) = 0x%08X\n", lw(20,0));
    printf("\n");

    // A partir daqui, fiz alguns testes extras.

    // Teste E1 : escrever uma palavra em endereço não divisível por 4.
    // Esperamos ter um erro na saída.
    sw(29, 0, 0x80000000);
    printf("Teste E1: ");
    catchError();

    // Teste E2 : ler uma palavra de um endereço não divisível por 4.
    // Esperamos ter um erro na saída.
    lw(33, 0);
    printf("Teste E2: ");
    catchError();

    // Teste E3: ler uma palavra da memória.
    printf("Teste E3: ");
    int32_t mem_0 = lw(0, 0);
    if (mem_0 == 0x01020304) {
        printf("Leitura de palavra feita com sucesso.\n");
    } else {
        printf("Erro ao ler palavra da memória.\n");
    }

    // Teste E4: ler um byte da memória
    printf("Teste E4: ");
    int32_t memb_0 = lb(0, 0);
    if (memb_0 == 0x04) {
        printf("Leitura de byte feita com sucesso.\n");
    } else {
        printf("Erro ao ler byte da memória.\n");
    }

    // Teste E5: ler byte negativo da memória, para ver se o ultimo bit foi extendido.
    printf("Teste E5: ");
    int32_t memb_4 = lb(4,0);
    if (memb_4 == -1) {
        printf("Leitura de byte negativo feita com sucesso. Byte lido: 0x%08X = -1\n", memb_4);
    } else {
        printf("Erro ao ler byte negativo da memória.\n");
    }

    // Teste E6: ler byte "negativo" da memória como unsigned, para ver se o ultimo bit não foi extendido.
    printf("Teste E6: ");
    int32_t membu_4 = lbu(4,0);
    if (membu_4 == 255) {
        printf("Leitura de byte sem sinal feita com sucesso. Byte lido: 0x%08X = 255\n", membu_4);
    } else {
        printf("Erro ao ler byte sem sinal da memória.\n");
    }

    // Teste E7: ler palavra em endereço fora da memória
    // Esperamos um erro.
    printf("Teste E7: ");
    int32_t mem_end = lw(MEM_SIZE,0);
    catchError();

    // Teste E8: ler palavra em endereço negativo.
    // Esperamos um erro.
    printf("Teste E8: ");
    int32_t mem_neg = lw(-1,0);
    catchError();

    // Teste E9: ler palavra em endereço positivo mas com deslocamento negativo.
    printf("Teste E9: ");
    printf("lw(16,-4) = 0x%08X\n", lw(16,-4));

    // Teste E10: ler byte em endereço positivo mas com deslocamento negativo.
    printf("Teste E10: ");
    printf("lb(16,-4) = 0x%08X\n", lb(16,-4));

    // Teste E11: ler byte sem sinal em endereço positivo mas com deslocamento negativo.
    printf("Teste E11: ");
    printf("lbu(16,-4) = 0x%08X\n", lbu(16,-4));

    printf("\n");
    printf("Fim dos testes.\n");
    return 0;
}

