#include "instructions.hpp"

enum REGISTERS {
    ZERO=0, RA=1,	SP=2,	GP=3,
    TP=4,	T0=5,	T1=6,	T2=7,
    S0=8,	S1=9,	A0=10,	A1=11,
    A2=12,	A3=13,	A4=14,	A5=15,
    A6=16,	A7=17,  S2=18,	S3=19,
    S4=20,	S5=21, 	S6=22,	S7=23,
    S8=24,	S9=25,  S10=26,	S11=27,
    T3=28,	T4=29,	T5=30,	T6=31
};

void InstructionExecutor::install(RiscV* cpu) {
    if (this->hash) {
        printf("Installing hash %X to %s instruction.\n", this->hash, this->getName().c_str());
        cpu->instructions[this->hash] = this;
    } else {
        printf("Instruction %s not ready.\n", this->getName().c_str());
    }
}

// 0000000 rs2 rs1 000 rd 0110011 ADD
class IE_add : public InstructionExecutor {
    public:
        IE_add() : InstructionExecutor(0b0110011, 0b000, 0x00) { }
        std::string getName() {
            return "add";
        }

        void describe(Instruction* instruction) {
            printf("add rd: x%d, rs1: x%d, rs2: x%d\n", instruction->rd, instruction->rs1, instruction->rs2);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(cpu->registers[instruction->rs1]->readUnsigned() + cpu->registers[instruction->rs2]->readUnsigned());
        }
};

// imm[11:0] rs1 000 rd 0010011 ADDI
class IE_addi : public InstructionExecutor {
    public:
        IE_addi() : InstructionExecutor(0b0010011,0b000,0x00) { }
        std::string getName() {
            return "addi";
        }

        void describe(Instruction* instruction) {
            printf("addi rd: x%d, rs1: x%d, imm: %d\n", instruction->rd, instruction->rs1, instruction->imm12_i);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(cpu->registers[instruction->rs1]->read() + instruction->imm12_i);
        }
};

// 0000000 rs2 rs1 111 rd 0110011 AND
class IE_and : public InstructionExecutor {
    public:
        IE_and() : InstructionExecutor(0b0110011,0b111,0x00) { }
        std::string getName() {
            return "and";
        }

        void describe(Instruction* instruction) {
            printf("and rd: x%d, rs1: x%d, rs2: x%d\n", instruction->rd, instruction->rs1, instruction->rs2);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(cpu->registers[instruction->rs1]->readUnsigned() & cpu->registers[instruction->rs2]->readUnsigned());
        }
};

// imm[11:0] rs1 111 rd 0010011 ANDI
class IE_andi : public InstructionExecutor {
    public:
        IE_andi() : InstructionExecutor(0b0010011,0b111,0x00) { }
        std::string getName() {
            return "andi";
        }

        void describe(Instruction* instruction) {
            printf("andi rd: x%d, rs1: x%d, imm: %d\n", instruction->rd, instruction->rs1, instruction->imm12_i);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(cpu->registers[instruction->rs1]->readUnsigned() & ((uint32_t) instruction->imm12_i));
        }
};

// imm[31:12] rd 0010111 AUIPC
class IE_auipc : public InstructionExecutor {
    public:
        IE_auipc() : InstructionExecutor(0b0010111,0x00,0x00) { }
        std::string getName() {
            return "auipc";
        }

        void describe(Instruction* instruction) {
            printf("auipc rd: x%d, imm: x%d\n", instruction->rd, instruction->imm21);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(cpu->PC->readUnsigned() + instruction->imm21);
        }
};

// imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 BEQ
class IE_beq : public InstructionExecutor {
    public:
        IE_beq() : InstructionExecutor(0b1100011,0x00,0x00) { }
        std::string getName() {
            return "beq";
        }

        void describe(Instruction* instruction) {
            printf("beq rs1: x%d, rs2: x%d, jdiff: %d\n", instruction->rs1, instruction->rs2, instruction->imm13);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            if (cpu->registers[instruction->rs1]->readUnsigned() == cpu->registers[instruction->rs2]->readUnsigned()) {
                cpu->PC->write(cpu->PC->readUnsigned() + instruction->imm13);
            }
        }
};

// imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 BNE
class IE_bne : public InstructionExecutor {
    public:
        IE_bne() : InstructionExecutor(0b1100011,0b001,0x00) { }
        std::string getName() {
            return "bne";
        }

        void describe(Instruction* instruction) {
            printf("bne rs1: x%d, rs2: x%d, jdiff: %d\n", instruction->rs1, instruction->rs2, instruction->imm13);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            if (cpu->registers[instruction->rs1]->readUnsigned() != cpu->registers[instruction->rs2]->readUnsigned()) {
                cpu->PC->write(cpu->PC->readUnsigned() + instruction->imm13);
            }
        }
};

// imm[12|10:5] rs2 rs1 101 imm[4:1|11] 1100011 BGE
class IE_bge : public InstructionExecutor {
    public:
        IE_bge() : InstructionExecutor(0b1100011,0b101,0x00) { }
        std::string getName() {
            return "bge";
        }

        void describe(Instruction* instruction) {
            printf("bge rs1: x%d, rs2: x%d, jdiff: %d\n", instruction->rs1, instruction->rs2, instruction->imm13);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            if (cpu->registers[instruction->rs1]->read() >= cpu->registers[instruction->rs2]->read()) {
                cpu->PC->write(cpu->PC->readUnsigned() + instruction->imm13);
            }
        }
};

// imm[12|10:5] rs2 rs1 111 imm[4:1|11] 1100011 BGEU
class IE_bgeu : public InstructionExecutor {
    public:
        IE_bgeu() : InstructionExecutor(0b1100011,0b111,0x00) { }
        std::string getName() {
            return "bgeu";
        }

        void describe(Instruction* instruction) {
            printf("bgeu rs1: x%d, rs2: x%d, jdiff: %d\n", instruction->rs1, instruction->rs2, instruction->imm13);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            if (cpu->registers[instruction->rs1]->readUnsigned() >= cpu->registers[instruction->rs2]->readUnsigned()) {
                cpu->PC->write(cpu->PC->readUnsigned() + instruction->imm13);
            }
        }
};

// imm[12|10:5] rs2 rs1 100 imm[4:1|11] 1100011 BLT
class IE_blt : public InstructionExecutor {
    public:
        IE_blt() : InstructionExecutor(0b1100011,0b100,0x00) { }
        std::string getName() {
            return "blt";
        }

        void describe(Instruction* instruction) {
            printf("blt rs1: x%d, rs2: x%d, jdiff: %d\n", instruction->rs1, instruction->rs2, instruction->imm13);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            if (cpu->registers[instruction->rs1]->read() < cpu->registers[instruction->rs2]->read()) {
                cpu->PC->write(cpu->PC->readUnsigned() + instruction->imm13);
            }
        }
};

// imm[12|10:5] rs2 rs1 110 imm[4:1|11] 1100011 BLTU
class IE_bltu : public InstructionExecutor {
    public:
        IE_bltu() : InstructionExecutor(0b1100011,0b110,0x00) { }
        std::string getName() {
            return "bltu";
        }

        void describe(Instruction* instruction) {
            printf("bltu rs1: x%d, rs2: x%d, jdiff: %d\n", instruction->rs1, instruction->rs2, instruction->imm13);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            if (cpu->registers[instruction->rs1]->readUnsigned() < cpu->registers[instruction->rs2]->readUnsigned()) {
                cpu->PC->write(cpu->PC->readUnsigned() + instruction->imm13);
            }
        }
};

// imm[20|10:1|11|19:12] rd 1101111 JAL
class IE_jal : public InstructionExecutor {
    public:
        IE_jal() : InstructionExecutor(0b1101111,0x00,0x00) { }
        std::string getName() {
            return "jal";
        }

        void describe(Instruction* instruction) {
            printf("jal rd: x%d, imm: 0x%08X\n", instruction->rd, instruction->imm21);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            // JAL stores the address of the instruction following the jump (pc+4) into register rd.
            cpu->registers[instruction->rd]->write(cpu->PC->readUnsigned()+4);

            // The offset is sign-extended and added to the pc to form the jump target address.
            cpu->PC->write(cpu->PC->readUnsigned() + instruction->imm21);
        }
};

// imm[11:0] rs1 000 rd 1100111 JALR
class IE_jalr : public InstructionExecutor {
    public:
        IE_jalr() : InstructionExecutor(0b1100111,0x00,0x00) { }
        std::string getName() {
            return "jalr";
        }

        void describe(Instruction* instruction) {
            printf("jalr rd: x%d, rs1: x%d, imm: %d\n", instruction->rd, instruction->rs1, instruction->imm12_i);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            // The address of the instruction following the jump (pc+4) is written to register rd. 
            cpu->registers[instruction->rd]->write(cpu->PC->readUnsigned()+4);

            // The indirect jump instruction JALR (jump and link register) uses the I-type encoding. The target
            // address is obtained by adding the 12-bit signed I-immediate to the register rs1, then setting the
            // least-significant bit of the result to zero. 
            cpu->PC->write((cpu->registers[instruction->rs1]->readUnsigned() + instruction->imm12_i) & 0xFFFFFFFE);
        }
};

// imm[11:0] rs1 000 rd 0000011 LB
class IE_lb : public InstructionExecutor {
    public:
        IE_lb() : InstructionExecutor(0b0000011,0b000,0x00) { }
        std::string getName() {
            return "lb";
        }

        void describe(Instruction* instruction) {
            printf("lb rd: x%d, rs1: x%d, imm: %d\n", instruction->rd, instruction->rs1, instruction->imm12_i);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(
                cpu->lb(
                    cpu->registers[instruction->rs1]->readUnsigned() + instruction->imm12_i
                )
            );
        }
};

// 0000000 rs2 rs1 110 rd 0110011 OR
class IE_or : public InstructionExecutor {
    public:
        IE_or() : InstructionExecutor(0b0110011,0b110,0x00) { }
        std::string getName() {
            return "or";
        }

        void describe(Instruction* instruction) {
            printf("or rd: x%d, rs1: x%d, rs2: x%d\n", instruction->rd, instruction->rs1, instruction->rs2);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(cpu->registers[instruction->rs1]->readUnsigned() | cpu->registers[instruction->rs2]->readUnsigned());
        }
};

// imm[11:0] rs1 100 rd 0000011 LBU
class IE_lbu : public InstructionExecutor {
    public:
        IE_lbu() : InstructionExecutor(0b0000011,0b100,0x00) { }
        std::string getName() {
            return "lbu";
        }

        void describe(Instruction* instruction) {
            printf("lbu rd: x%d, rs1: x%d, imm: %d\n", instruction->rd, instruction->rs1, instruction->imm12_i);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(
                cpu->lbu(
                    cpu->registers[instruction->rs1]->readUnsigned() + instruction->imm12_i
                )
            );
        }
};

// imm[11:0] rs1 010 rd 0000011 LW
class IE_lw : public InstructionExecutor {
    public:
        IE_lw() : InstructionExecutor(0b0000011,0b010,0x00) { }
        std::string getName() {
            return "lw";
        }

        void describe(Instruction* instruction) {
            printf("lw rd: x%d, rs1: x%d, imm: %d\n", instruction->rd, instruction->rs1, instruction->imm12_i);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(
                cpu->lw(
                    cpu->registers[instruction->rs1]->readUnsigned() + instruction->imm12_i
                )
            );
        }
};

// imm[31:12] rd 0110111 LUI
class IE_lui : public InstructionExecutor {
    public:
        IE_lui() : InstructionExecutor(0b0110111,0x00,0x00) { }
        std::string getName() {
            return "lui";
        }

        void describe(Instruction* instruction) {
            printf("lui rd: x%d, imm: x%d\n", instruction->rd, instruction->imm21);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(
                instruction->imm20_u
            );
        }
};

// 0000000 rs2 rs1 011 rd 0110011 SLTU
class IE_sltu : public InstructionExecutor {
    public:
        IE_sltu() : InstructionExecutor(0b0110011,0b011,0x00) { }
        std::string getName() {
            return "sltu";
        }

        void describe(Instruction* instruction) {
            printf("sltu rd: x%d, rs1: x%d, rs2: x%d\n", instruction->rd, instruction->rs1, instruction->rs2);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(
                (cpu->registers[instruction->rs1]->readUnsigned() < cpu->registers[instruction->rs2]->readUnsigned()) ? 1 : 0
            );
        }
};

// imm[11:0] rs1 110 rd 0010011 ORI
class IE_ori : public InstructionExecutor {
    public:
        IE_ori() : InstructionExecutor(0b0010011,0b110,0x00) { }
        std::string getName() {
            return "ori";
        }

        void describe(Instruction* instruction) {
            printf("ori rd: x%d, rs1: x%d, imm: %d\n", instruction->rd, instruction->rs1, instruction->imm12_i);
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            cpu->registers[instruction->rd]->write(cpu->registers[instruction->rs1]->readUnsigned() | ((uint32_t) instruction->imm12_i));
        }
};


class IE_sb : public InstructionExecutor {
    public:
        IE_sb() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "sb";
        }

        void describe(Instruction* instruction) {
            printf("sb");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};


class IE_slli : public InstructionExecutor {
    public:
        IE_slli() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "slli";
        }

        void describe(Instruction* instruction) {
            printf("slli");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};


class IE_slt : public InstructionExecutor {
    public:
        IE_slt() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "slt";
        }

        void describe(Instruction* instruction) {
            printf("slt");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};


class IE_srai : public InstructionExecutor {
    public:
        IE_srai() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "srai";
        }

        void describe(Instruction* instruction) {
            printf("srai");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};


class IE_srli : public InstructionExecutor {
    public:
        IE_srli() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "srli";
        }

        void describe(Instruction* instruction) {
            printf("srli");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};


class IE_sub : public InstructionExecutor {
    public:
        IE_sub() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "sub";
        }

        void describe(Instruction* instruction) {
            printf("sub");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};


class IE_sw : public InstructionExecutor {
    public:
        IE_sw() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "sw";
        }

        void describe(Instruction* instruction) {
            printf("sw");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};


class IE_xor : public InstructionExecutor {
    public:
        IE_xor() : InstructionExecutor(0x00,0x00,0x00) { }
        std::string getName() {
            return "xor";
        }

        void describe(Instruction* instruction) {
            printf("xor");
        }

        void execute(Instruction* instruction, RiscV* cpu) {

        }
};

/*
    Syscall: implementar as chamadas para (ver help do RARS)
        • imprimir inteiro
        • imprimir string
        • encerrar programa
*/
// 000000000000 00000 000 00000 1110011 ECALL
class IE_ecall : public InstructionExecutor {
    public:
        IE_ecall() : InstructionExecutor(0b1110011,0x00,0x00) { }
        std::string getName() {
            return "ecall";
        }

        void describe(Instruction* instruction) {
            printf("ecall");
        }

        void execute(Instruction* instruction, RiscV* cpu) {
            // TODO
            // a7 code
            int code = cpu->registers[REGISTERS.A7]->read();
            uint32_t a0 = cpu->registers[REGISTERS.A0]->readUnsigned();
            switch (code) {
                case 1:
                    printf("%d\n", a0);
                    break;
                case 4:
                    printf("%s\n", ((char*)cpu->mem)+a0);
                    break;
                case 10:
                    // TODO end simulation
                    break;
                default:
                    break;
            }
            // PrintInt 1 Prints an integer a0 = integer to print N/A
            // PrintString 4 Prints a null-terminated string to the console a0 = the address of the string N/A
            // Exit 10 Exits the program with code 0 N/A N/A
        }
};


int main() {
   // (new Instruction(0xFFFFFFFF))->debug();
   // (new Instruction(0x001000EF))->debug();
   // (new Instruction(0x00a38313))->debug();
    //(new Instruction(0xf9c38313))->debug();
    RiscV* cpu = new RiscV();
}