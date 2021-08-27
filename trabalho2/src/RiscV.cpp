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
#include <iostream>
#include <stdio.h>
#include "RiscV.hpp"
#include "Instructions.hpp"

uint32_t registers[32] = {0}; // TODO: hardwire register x0
uint32_t ri;
uint32_t pc;
int32_t  mem[MEM_SIZE];
int error = 0;          // Flag de erro.
char error_msg[128];    // Espaço para salvarmos as mensagens de erro.
bool     enable = 1;
bool     debug = 0;
int      exit_code = 0;
uint8_t rs1;
uint8_t rs2;
uint8_t rd;
int32_t imm;
InstructionDecoder* decoder = new InstructionDecoder();
std::unordered_map<uint32_t, InstructionImplementation> instructions;

std::string _text_file = "text.bin";
std::string _data_file = "data.bin";

const uint32_t  TEXT_ADDRESS = 0x0000;
const uint32_t  DATA_ADDRESS = 0x2000;
const uint32_t  SP_START     = 0x3ffc;
const uint32_t  GP_START     = 0x1800;

enum _REGISTERS {
    ZERO=0, RA=1,	SP=2,	GP=3,
    TP=4,	T0=5,	T1=6,	T2=7,
    S0=8,	S1=9,	A0=10,	A1=11,
    A2=12,	A3=13,	A4=14,	A5=15,
    A6=16,	A7=17,  S2=18,	S3=19,
    S4=20,	S5=21, 	S6=22,	S7=23,
    S8=24,	S9=25,  S10=26,	S11=27,
    T3=28,	T4=29,	T5=30,	T6=31
};

/**
 * Função que imprime um erro.
 */
void catchError() {
    if (error) {
        printf("Erro: %s", error_msg);
    }
}

void install_instruction(const InstructionImplementation&impl) {
    uint32_t hash = InstructionDecoder::generate_hash(impl.opcode, impl.funct3, impl.funct7);
    instructions[hash] = impl;
}

void rfile_mem(const char* fname, uint32_t index) {
    FILE* f = fopen(fname, "r");
    int c;
    uint8_t* memb = (uint8_t*)mem;
    while ((c = fgetc(f)) != EOF) {
        memb[index++] = c;
    }
    fclose(f);
}

void load_mem() {
    pc = TEXT_ADDRESS;
    registers[SP] = SP_START;
    registers[GP] = GP_START;

    rfile_mem(_text_file.c_str(), TEXT_ADDRESS);
    rfile_mem(_data_file.c_str(), DATA_ADDRESS);
}

void dump_reg(char fcode) {
    const char* format;
    if (fcode == 'd') {
        format = "x%d -> %d\n\t";
    } else {
        format = "x%d -> 0x%08X\t\t";
    }
    printf("pc -> 0x%X\n", pc);
    for (int i=0; i < 32; i++) {
        printf(format, i, registers[i]);
        if (i%4==3) printf("\n");
    }
}

void fetch() {
    ri = mem[pc/4];
    pc += 4;
}

void decode() {
    decoder->decode(ri);
}

void step() {
    fetch();
    decode();
    execute();
}

void run() {
    while(enable && !error) {
        step();
    }
}

void execute() {

    auto executor = instructions.find(decoder->hash);
    if (executor == instructions.end()) {
        executor = instructions.find(decoder->generate_hash(decoder->opcode, decoder->funct3, 0));
        if (executor == instructions.end()) {
            executor = instructions.find(decoder->generate_hash(decoder->opcode, 0, 0));
            if (executor == instructions.end()) {
                enable = 0;
                exit_code = 1;
                printf("Instruction not found.");
                return;
            }
        }
    }

    InstructionImplementation imp = executor->second;

    registers[0] = 0;
    rd = decoder->rd;
    rs1 = decoder->rs1;
    rs2 = decoder->rs2;

    switch(imp.type) {
        case 'R':
            imm = 0;
            break;
        case 'I':
            imm = decoder->imm12_i;
            break;
        case 'S':
            imm = decoder->imm12_s;
            break;
        case 'B':
            imm = decoder->imm13;
            break;
        case 'J':
            imm = decoder->imm21;
            break;
        case 'U':
            imm = decoder->imm20_u;
            break;
        default:
            imm = 0;
            break;
    }
    
    if (debug) {
        dump_reg('h');
        printf("0x%08X: %s rd: x%d rs1: x%d rs2: x%d imm: %d", (pc-4), imp.name.c_str(), rd, rs1, rs2, imm);
    }

    (*(imp.exec))();
}


int main(int argc, char** argv) {
    load_instructions();
    load_mem();

    if (argc > 2) {
        _text_file = argv[1];
        _data_file = argv[1];
    }

    if (argc > 3) {
        debug = 1;
        printf ("Debug mode ON.\n");
        while (getchar() == '\n') {
            step();
            catchError();
        }
 
    } else {
        run();
        catchError();
    }
  
    return exit_code;
}

void ecall() {
    uint32_t code = registers[A7];
    uint32_t a0 = registers[A0];
    switch (code) {
        case 1:
            printf("%d", a0);
            break;
        case 4:
            printf("%s", ((char*)mem)+a0);
            break;
        case 10:
            enable = 0;
            break;
        default:
            break;
    }
}

bool validateWordAddress(uint32_t address) {
    error = address % 4 != 0 || address >= MEM_SIZE*4;
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