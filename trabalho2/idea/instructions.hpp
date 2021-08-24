#ifndef _INCLUDE_INSTRUCTIONS_HPP
#define _INCLUDE_INSTRUCTIONS_HPP

#include "riscv.hpp"
#include <stdint.h>  
#include <string>  

class RiscV;

class Instruction {
    public:
        uint32_t instruction;
        uint32_t hash;
        uint8_t opcode;
        uint8_t rs1;
        uint8_t rs2;
        uint8_t rd;
        uint8_t shamt;
        uint8_t funct3;
        uint8_t funct7;
        int32_t imm12_i;
        int32_t imm12_s;
        int32_t imm13;
        int32_t imm20_u;
        int32_t imm21;

        Instruction() {

        }

        Instruction(uint32_t code) {
            this->decode(code);
        }

        static uint32_t extract_bits(const uint8_t&start_bit, const uint8_t&end_bit, const uint32_t&code, const uint8_t&position=0) {
            return (code & ((((1<<(end_bit-start_bit+1)))-1) << start_bit)) >> (start_bit - position);
        }

        static int32_t sign_ext(int32_t&value, const uint8_t&bits) {
            value = ((int32_t(-1))<<bits) | value;
        }
    
        
        static uint32_t generate_hash(uint8_t opcode, uint8_t funct3, uint8_t funct7) {
            return uint32_t(opcode<<16|funct3<<8|funct7);
        }

        void decode(uint32_t code) {
            instruction = code;

            // Extração de bits
            opcode = extract_bits(0, 6, code, 0);
            rs1 = extract_bits(15, 19, code, 0);
            rs2 = extract_bits(20, 24, code, 0);
            rd = extract_bits(7, 11, code, 0);
            shamt = extract_bits(20, 24, code, 0);
            funct3 = extract_bits(12, 14, code, 0);
            funct7 = extract_bits(25, 31, code, 0);
            imm12_i = extract_bits(20, 30, code, 0);
            imm12_s = extract_bits(25, 30, code, 4) + extract_bits(7, 11, code, 0);
            imm13 = extract_bits(8, 11, code, 1) + extract_bits(25, 30, code, 5) + extract_bits(7, 7, code, 11);
            imm20_u = extract_bits(12, 31, code, 12);
            imm21 = extract_bits(12, 19, code, 12) + extract_bits(20, 20, code, 11) + extract_bits(21, 30, code, 1);
            
            // Extensão de sinal
            if (code>>31) {
                sign_ext(imm12_i, 11);
                sign_ext(imm12_s, 11);
                sign_ext(imm13, 12);
                sign_ext(imm21, 20);
            }

            hash = generate_hash(opcode, funct3, funct7);
        }

        void debug() {
            printf("instruction: \t0x%08X\t%d \n", instruction, instruction);
            printf("opcode: \t0x%08X\t%d \n", opcode, opcode);
            printf("rs1: \t\t0x%08X\t%d \n", rs1, rs1);
            printf("rs2: \t\t0x%08X\t%d \n", rs2, rs2);
            printf("rd: \t\t0x%08X\t%d \n", rd, rd);
            printf("shamt: \t\t0x%08X\t%d \n", shamt, shamt);
            printf("funct3: \t0x%08X\t%d \n", funct3, funct3);
            printf("funct7: \t0x%08X\t%d \n", funct7, funct7);
            printf("imm12_i: \t0x%08X\t%d \n", imm12_i, imm12_i);
            printf("imm12_s: \t0x%08X\t%d \n", imm12_s, imm12_s);
            printf("imm13: \t\t0x%08X\t%d \n", imm13, imm13);
            printf("imm20_u: \t0x%08X\t%d \n", imm20_u, imm20_u);
            printf("imm21: \t\t0x%08X\t%d \n", imm21, imm21);
            printf("hash: \t\t0x%08X\t%d \n", hash, hash);
        }
};

class InstructionExecutor {
    protected:
        uint32_t hash;

        InstructionExecutor(uint8_t opcode, uint8_t funct3, uint8_t funct7) {
            this->hash = Instruction::generate_hash(opcode, funct3, funct7);
        }

    public:
        uint32_t getHash() {
            return this->hash;
        }

        void install(RiscV* cpu);
        virtual std::string getName() = 0;
        virtual void describe(Instruction* instruction) = 0;
        virtual std::string execute(Instruction* instruction, RiscV* cpu) = 0;
};

#endif