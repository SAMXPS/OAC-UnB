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
        registers[i] = new Register();
    }

    /*  pc = 0x00000000
        ri = 0x00000000
        sp = 0x00003ffc
        gp = 0x00001800 
    */
    PC->write(0x00000000);
    RI->write(0x00000000);
    int i = 0;
    mem[i++] = 0x000000b3;
    mem[i++] = 0x00000093;
    mem[i++] = 0x000070b3;
    mem[i++] = 0x00007093;
    mem[i++] = 0x00000097;
    mem[i++] = 0x00008063;
    mem[i++] = 0x00009063;
    mem[i++] = 0x0000d063;
    //registers(SP).write(0x00003ffc)
    //registers(GP).write(0x00001800)

    (new IE_add())->install(this);
    (new IE_addi())->install(this);
    (new IE_and())->install(this);
    (new IE_andi())->install(this);
    (new IE_auipc())->install(this);
    (new IE_beq())->install(this);
    (new IE_bne())->install(this);
    (new IE_bge())->install(this);
    (new IE_bgeu())->install(this);
    (new IE_blt())->install(this);
    (new IE_bltu())->install(this);
    (new IE_jal())->install(this);
    (new IE_jalr())->install(this);
    (new IE_lb())->install(this);
    (new IE_or())->install(this);
    (new IE_lbu())->install(this);
    (new IE_lw())->install(this);
    (new IE_lui())->install(this);
    (new IE_sltu())->install(this);
    (new IE_ori())->install(this);
    (new IE_sb())->install(this);
    (new IE_slli())->install(this);
    (new IE_slt())->install(this);
    (new IE_srai())->install(this);
    (new IE_srli())->install(this);
    (new IE_sub())->install(this);
    (new IE_sw())->install(this);
    (new IE_xor())->install(this);
    (new IE_ecall())->install(this);

    while (1) {
        fetch();
        Instruction* inst = decode();
        uint32_t hash = inst->hash;
        if (!hash) break;
        auto executor = instructions.find(hash);
        if (executor != instructions.end()) {
            executor->second->describe(inst);
        } else {
            break;
        }
    }
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