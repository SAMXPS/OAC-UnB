-- ****************************************** 
--  Circuito: Controle RISCV-32 MultiCiclo
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity RV32_Control is
port (
    Clock       : in  std_logic;
    Op          : in  std_logic_vector(6 downto 0);
    PCWriteCond : out std_logic;
    PCWrite     : out std_logic;
    IorD        : out std_logic;
    MemRead     : out std_logic;
    MemWrite    : out std_logic;
    MemtoReg    : out std_logic;
    IRWrite     : out std_logic;
    PCSource    : out std_logic;
    ALUOp       : out std_logic;
    ALUSrcB     : out std_logic_vector(2 downto 0);
    ALUSrcA     : out std_logic;
    RegWrite    : out std_logic
);
end RV32_Control;

architecture RV32_Control_ARCH of RV32_Control is
    type RV32_STATE is (
        FETCH,
        DECODE,
        CALC_R, CALC_MEM, CALC_BRANCH, CALC_JUMP
        MEM_R, MEM_LOAD, MEM_STORE,
        MEM_LOAD_END
    );
    begin
        
end RV32_Control_ARCH;

-- LW, SW, ADD, ADDi, SUB, AND, NAND, OR, NOR, XOR, SLT, JAL, JALR AUIPC,
-- LUI, BEQ, BNE
-- Grupo 3:  Shift

--Grupo Shift:
-- SLL: deslocamento lógico à esquerda
-- sll rd, rs1, rs2 X[rd] = X[rs1] << X[rs2]
-- SRL: deslocamento lógico à direita
-- srl rd, rt, shamt X[rd] = X[rs1] >>u X[rs2]
-- SRA: deslocamento aritmético à direita
-- sra rd, rt, shamt X[rd] = X[rs1] >> X[rs2] 