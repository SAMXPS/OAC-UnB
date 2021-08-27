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