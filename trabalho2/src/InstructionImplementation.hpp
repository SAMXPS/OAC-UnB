/**
 * UNIVERSIDADE DE BRASÍLIA
 * INSTITUTO DE CIÊNCIAS EXATAS 
 * DEPARTAMENTO DE CIÊNCIA DA COMPUTAÇÃO
 * 116394 ORGANIZAÇÃO E ARQUITETURA DE COMPUTADORES 
 * TURMA C - 2021/1
 *
 * Trabalho II: Simulador RISCV (32 bits)
 * Autor: SAMUEL JAMES DE LIMA BARROSO
 */
#ifndef _INSTRUCTION_IMPLEMENTATION_HPP
#define _INSTRUCTION_IMPLEMENTATION_HPP
#include <string>
#include <stdint.h>

typedef struct _instruction_code {
    std::string name;
    char        type;
    uint8_t     opcode;
    uint8_t     funct3;
    uint8_t     funct7;
    void        (*exec)();
} InstructionImplementation;

#endif