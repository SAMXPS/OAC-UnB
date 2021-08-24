#include "riscv.hpp"
#include "instructions.hpp"
#include "instructions.cpp"
#include <stdint.h>  
#include <unordered_map>
#define MEM_SIZE 4096 

RiscV::RiscV() {
    // Inicializando registradores
    registers[0] = new ConstantGenerator();
    for (int i = 1; i < 32; i++) {
        registers[1] = new Register();
    }

    /*  pc = 0x00000000
        ri = 0x00000000
        sp = 0x00003ffc
        gp = 0x00001800 
    */
    PC->write(0x00000000);
    RI->write(0x00000000);
    mem[0] = 0x001000EF;
    //registers(SP).write(0x00003ffc)
    //registers(GP).write(0x00001800)
    (new IE_jal())->install(this);
    fetch();
    printf("RI: %X\n", RI->readUnsigned());
    execute(decode());
}

// Memory access
int32_t RiscV::lw(uint32_t address, int32_t kte) {
    return mem[(address+kte)/4];
}

int32_t RiscV::lb(uint32_t address, int32_t kte) {
    return (int32_t) (((int8_t*)mem) [address+kte]);
}

int32_t RiscV::lbu(uint32_t address, int32_t kte) {
    return (int32_t) (((uint8_t*)mem) [address+kte]);
}

void RiscV::sw(uint32_t address, int32_t kte, int32_t dado) {
    mem[(address+kte)/4] = dado;
}

void RiscV::sb(uint32_t address, int32_t kte, int8_t dado) {
    (((int8_t*)mem) [address+kte]) = dado;
}

void RiscV::fetch() {
    RI->write(lw(PC->readUnsigned(), 0)); // carrega instrução endereçada pelo pc
    PC->write(PC->readUnsigned() + 4); // aponta para a próxima instrução
}

Instruction* RiscV::decode() {
    return new Instruction(RI->readUnsigned());
}

void RiscV::execute(Instruction* inst) {
    uint32_t hash = inst->hash;
    printf("hash: %X\n", hash);
    auto executor = instructions.find(hash);
    if (executor != instructions.end()) {
        printf("Executing: ");
        executor->second->describe(inst);
        executor->second->execute(inst, this);
    } else {
        printf("instruction not found\n");
        // instruction not found
    }
}