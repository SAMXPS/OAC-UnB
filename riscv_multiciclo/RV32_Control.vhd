-- ****************************************** 
--  Circuito: Controle RISCV-32 MultiCiclo
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RV32_pack.all;
USE std.textio.ALL;
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
    MemtoReg    : out std_logic_vector(1 downto 0);
    IRWrite     : out std_logic;
    PCSource    : out std_logic;
    ALUOp       : out std_logic_vector(3 downto 0);
    ALUSrcB     : out std_logic_vector(1 downto 0);
    ALUSrcA     : out std_logic_vector(1 downto 0);
    RegWrite    : out std_logic;
    PCBackWren  : out std_logic;
    RDataWrite  : out std_logic;
    MemDataWrite: out std_logic;
    ALUOutWrite : out std_logic
);
end RV32_Control;

architecture RV32_Control_ARCH of RV32_Control is
    type RV32_STATE is (
        FETCH,
        DECODE,
        CALC_R, CALC_MEM, CALC_BRANCH, CALC_JUMP,
        MEM_R, MEM_LOAD, MEM_STORE,
        MEM_LOAD_END
    );
    signal NEXT_STATE,CURRENT_STATE : RV32_STATE;
    begin
        sync_process: process(Clock)
        begin
            if (rising_edge(Clock)) then
                CURRENT_STATE <= NEXT_STATE;
            end if;
        end process sync_process;

        comb_process: process(CURRENT_STATE)
        begin
            if (CURRENT_STATE = FETCH) then
                -- IR <= Mem[PC]
                -- PCback <= PC
                -- PC <= PC+4
                PCWriteCond <= '0';     -- dont care
                PCWrite     <= '1';     -- PC <= PC+4
                IorD        <= '0';     -- PC entra como endereço de memória
                MemRead     <= '1';     -- Habilita leitura na memória
                MemWrite    <= '0';     -- Não há escrita na memória
                MemtoReg    <= "00";    -- dont care
                IRWrite     <= '1';     -- Escreve leitura da memória no registrador de instruções
                PCSource    <= '0';     -- PC vem da ULA
                ALUOp       <= "0000";  -- ALUResult = PC + 4
                ALUSrcB     <= "01";    -- 4
                ALUSrcA     <= "10";    -- PC
                RegWrite    <= '0';     -- Não há escrita no banco de registradores
                PCBackWren  <= '1';     -- PCBack <= PC (atual, antes da soma)
                RDataWrite  <= '0';     -- Não há escrita em A,B
                MemDataWrite<= '1';     -- Há escrita no registrador de memória
                ALUOutWrite <= '0';     -- Não há necessidade de escrever no registrador ALUout

                NEXT_STATE <= DECODE;
            elsif (CURRENT_STATE = DECODE) then
                -- A <= Reg[IR[19:15]]
                -- B <= Reg[IR[24:20]]
                -- SaidaULA <= PCBack + (imm<<1)
                PCSource    <= '0';     -- dont care
                PCWriteCond <= '0';     -- não há escrita no pc
                PCWrite     <= '0';     -- não há escrita no pc
                IorD        <= '0';     -- dont care
                MemRead     <= '0';     -- Não há leitura na memória
                MemWrite    <= '0';     -- Não há escrita na memória
                MemtoReg    <= "00";    -- dont care
                MemDataWrite<= '0';     -- Não há escrita no registrador de memória
                IRWrite     <= '0';     -- Não há escrita no registrador de instruções
                RegWrite    <= '0';     -- Não há escrita no banco de registradores
                ALUOp       <= "0000";  -- ALUResult = PCback+(Imm<<1)
                ALUSrcB     <= "11";    -- Imm<<1
                ALUSrcA     <= "00";    -- PCBack
                ALUOutWrite <= '1';     -- ALUout < ALUResult
                PCBackWren  <= '1';     -- PCBack <= PC (atual, antes da soma)
                RDataWrite  <= '1';     -- Há escrita em A,B

                if (Op = iRType) then
                    -- Instruções do tipo R
                    NEXT_STATE <= CALC_R;
                elsif (Op = iILType) or (Op = iSType) then
                    -- Load ou store
                    NEXT_STATE <= CALC_MEM;
                elsif (Op = iBType) then
                    -- Branches (desvios condicionais)
                    NEXT_STATE <= CALC_BRANCH;
                elsif (Op = iJAL) or (Op = iJALR) then
                    NEXT_STATE <= CALC_JUMP;
                else
                    report "Erro de funcionamento, opcode não implementado" severity warning;
                end if;

            else
                NEXT_STATE <= FETCH;
            end if;
        end process comb_process;
        
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