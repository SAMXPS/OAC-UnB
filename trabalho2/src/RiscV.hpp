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
#ifndef _RISCV_HPP
#define _RISCV_HPP

#include <stdint.h> 
#include <string>
#include <unordered_map>
#include "InstructionDecoder.hpp"
#include "InstructionImplementation.hpp"
#define MEM_SIZE 4096 

extern uint32_t registers[32];
extern uint32_t ri;
extern uint32_t pc;
extern int32_t  mem[MEM_SIZE];
extern bool enable;

extern uint8_t rs1;
extern uint8_t rs2;
extern uint8_t rd;
extern int32_t imm;

extern InstructionDecoder* decoder;
extern std::unordered_map<uint32_t, InstructionImplementation> instructions;

void install_instruction(const InstructionImplementation&impl);
void load_mem();

int32_t lw(uint32_t address, int32_t kte);
int32_t lb(uint32_t address, int32_t kte);
int32_t lbu(uint32_t address, int32_t kte);
void sw(uint32_t address, int32_t kte, int32_t dado);
void sb(uint32_t address, int32_t kte, int8_t dado);

void ecall();
void fetch();
void decode();
void execute();
void step();
void run();


#endif