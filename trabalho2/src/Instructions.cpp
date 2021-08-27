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
#include "Instructions.hpp"

void I_add() {
	registers[rd]=registers[rs1]+registers[rs2];
}

void I_and() {
	registers[rd]=registers[rs1]&registers[rs2];
}

void I_or() {
	registers[rd]=registers[rs1]|registers[rs2];
}

void I_sub() {
	registers[rd]=registers[rs1]-registers[rs2];
}

void I_xor() {
	registers[rd]=registers[rs1]^registers[rs2];
}

void I_addi() {
	registers[rd]=registers[rs1]+imm;
}

void I_andi() {
	registers[rd]=registers[rs1]&imm;
}

void I_ori() {
	registers[rd]=registers[rs1]|imm;
}

void I_auipc() {
	registers[rd]=imm+(pc-4);
}

void I_lui() {
	registers[rd]=imm;
}

void I_beq() {
	pc += (registers[rs1]==registers[rs2])*(imm-4);
}

void I_bne() {
	pc += (registers[rs1]!=registers[rs2])*(imm-4);
}

void I_bge() {
	pc += (( int32_t) registers[rs1] >= ( int32_t)registers[rs2])*(imm-4);
}

void I_bgeu() {
	pc += ((uint32_t) registers[rs1] >= (uint32_t)registers[rs2])*(imm-4);
}

void I_blt() {
	pc += (( int32_t) registers[rs1] <  ( int32_t)registers[rs2])*(imm-4);
}

void I_bltu() {
	pc += ((uint32_t) registers[rs1] <  (uint32_t)registers[rs2])*(imm-4);
}

void I_jal() {
	registers[rd]=pc;
	pc+=(imm-4);
}

void I_jalr() {
	registers[rd]=pc;
	pc=(registers[rs1]+imm)&0xFFFFFFFE;
}

void I_lb() {
	registers[rd]=lb(registers[rs1], imm);
}

void I_lbu() {
	registers[rd]=lbu(registers[rs1], imm);
}

void I_lw() {
	registers[rd]=lw(registers[rs1], imm);
}

void I_sb() {
	sb(registers[rs1], imm,registers[rs2]);
}

void I_sw() {
	sw(registers[rs1], imm,registers[rs2]);
}

void I_sltu() {
	registers[rd]=((uint32_t) registers[rs1] < (uint32_t)registers[rs2]);
}

void I_slt() {
	registers[rd]=(( int32_t) registers[rs1] < ( int32_t)registers[rs2]);
}

void I_slli() {
	registers[rd]=registers[rs1]<<rs2;
}

void I_srli() {
	registers[rd]=registers[rs1]>>rs2;
}

void I_srai() {
	registers[rd]=(uint32_t)((int32_t)registers[rs1]>>rs2);
}

void I_ecall() {
	ecall();
}


void load_instructions() {
    install_instruction(InstructionImplementation{"add", 'R', 0b0110011, 0b000, 0b0000000, &I_add});
    install_instruction(InstructionImplementation{"and", 'R', 0b0110011, 0b111, 0b0000000, &I_and});
    install_instruction(InstructionImplementation{"or", 'R', 0b0110011, 0b110, 0b0000000, &I_or});
    install_instruction(InstructionImplementation{"sub", 'R', 0b0110011, 0b000, 0b0100000, &I_sub});
    install_instruction(InstructionImplementation{"xor", 'R', 0b0110011, 0b100, 0b0000000, &I_xor});
    install_instruction(InstructionImplementation{"addi", 'I', 0b0010011, 0b000, 0b0000000, &I_addi});
    install_instruction(InstructionImplementation{"andi", 'I', 0b0010011, 0b111, 0b0000000, &I_andi});
    install_instruction(InstructionImplementation{"ori", 'I', 0b0010011, 0b110, 0b0000000, &I_ori});
    install_instruction(InstructionImplementation{"auipc", 'U', 0b0010111, 0b000, 0b0000000, &I_auipc});
    install_instruction(InstructionImplementation{"lui", 'U', 0b0110111, 0b000, 0b0000000, &I_lui});
    install_instruction(InstructionImplementation{"beq", 'B', 0b1100011, 0b000, 0b0000000, &I_beq});
    install_instruction(InstructionImplementation{"bne", 'B', 0b1100011, 0b001, 0b0000000, &I_bne});
    install_instruction(InstructionImplementation{"bge", 'B', 0b1100011, 0b101, 0b0000000, &I_bge});
    install_instruction(InstructionImplementation{"bgeu", 'B', 0b1100011, 0b111, 0b0000000, &I_bgeu});
    install_instruction(InstructionImplementation{"blt", 'B', 0b1100011, 0b100, 0b0000000, &I_blt});
    install_instruction(InstructionImplementation{"bltu", 'B', 0b1100011, 0b110, 0b0000000, &I_bltu});
    install_instruction(InstructionImplementation{"jal", 'J', 0b1101111, 0b000, 0b0000000, &I_jal});
    install_instruction(InstructionImplementation{"jalr", 'I', 0b1100111, 0b000, 0b0000000, &I_jalr});
    install_instruction(InstructionImplementation{"lb", 'I', 0b0000011, 0b000, 0b0000000, &I_lb});
    install_instruction(InstructionImplementation{"lbu", 'I', 0b0000011, 0b100, 0b0000000, &I_lbu});
    install_instruction(InstructionImplementation{"lw", 'I', 0b0000011, 0b010, 0b0000000, &I_lw});
    install_instruction(InstructionImplementation{"sb", 'S', 0b0100011, 0b000, 0b0000000, &I_sb});
    install_instruction(InstructionImplementation{"sw", 'S', 0b0100011, 0b010, 0b0000000, &I_sw});
    install_instruction(InstructionImplementation{"sltu", 'R', 0b0110011, 0b011, 0b0000000, &I_sltu});
    install_instruction(InstructionImplementation{"slt", 'R', 0b0110011, 0b010, 0b0000000, &I_slt});
    install_instruction(InstructionImplementation{"slli", 'R', 0b0010011, 0b001, 0b0000000, &I_slli});
    install_instruction(InstructionImplementation{"srli", 'R', 0b0010011, 0b101, 0b0000000, &I_srli});
    install_instruction(InstructionImplementation{"srai", 'R', 0b0010011, 0b101, 0b0100000, &I_srai});
    install_instruction(InstructionImplementation{"ecall", 'I', 0b1110011, 0b000, 0b0000000, &I_ecall});
}
