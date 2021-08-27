#ifndef _RISCV_HPP
#define _RISCV_HPP

#include <stdint.h> 
#include <string>
#include <unordered_map>
#include "InstructionDecoder.hpp"
#include "InstructionImplementation.hpp"
#define MEM_SIZE 4096 

extern uint32_t registers[32]; // TODO: hardwire register x0
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

// TODO: add lw, sw...etc from last trab

void ecall();
void fetch();
void decode();
void execute();
void step();
void run();

#endif