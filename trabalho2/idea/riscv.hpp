#ifndef _INCLUDE_RISCV_H
#define _INCLUDE_RISCV_H

#include <stdint.h>  
#include "register.hpp"
#include "instructions.hpp"
#include <unordered_map>
#define MEM_SIZE 4096 

class RiscV {
    public:
        IRegister* registers[32];
        IRegister* RI = new Register();
        IRegister* PC = new Register();
        int32_t mem[MEM_SIZE];
        std::unordered_map<uint32_t, InstructionExecutor*> instructions;

        RiscV();

        int32_t lw(uint32_t address, int32_t kte);
        int32_t lb(uint32_t address, int32_t kte);
        int32_t lbu(uint32_t address, int32_t kte);
        void sw(uint32_t address, int32_t kte, int32_t dado);
        void sb(uint32_t address, int32_t kte, int8_t dado);

        void fetch();
        Instruction* decode();
        void execute(Instruction* inst);
};

#endif