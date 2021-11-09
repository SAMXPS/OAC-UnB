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
    Instruction : in  std_logic_vector(31 downto 0);
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
        FETCH,                                      -- Ciclo 1: Fetch da instrução
        DECODE,                                     -- Ciclo 2: Decode da instrução
        CALC_R, CALC_MEM, CALC_BRANCH, CALC_JUMP,   -- Ciclo 3: Cálculo dos dados
        MEM_R, MEM_LOAD, MEM_STORE,                 -- Ciclo 4: Acesso à memória
        MEM_LOAD_END                                -- Ciclo 5: Fim do load
    );
    signal NEXT_STATE,CURRENT_STATE : RV32_STATE;
    signal request_ula_control      : std_logic := '0';
    signal funct3                   : std_logic_vector(2 downto 0);
    signal funct7                   : std_logic_vector(6 downto 0);
    signal funct7b30                : std_logic;

    begin

        funct3    <= Instruction(14 downto 12);
        funct7    <= Instruction(31 downto 25);
        funct7b30 <= funct7(5);

        sync_process: process(Clock)
        begin
            if (rising_edge(Clock)) then
                CURRENT_STATE <= NEXT_STATE;
            end if;
        end process sync_process;

-- LW,      OK
-- SW,      OK
-- ADD,     OK
-- ADDi,    OK
-- SUB,     OK
-- AND,     OK
-- NAND,    ?? não existe
-- OR,      OK
-- NOR,     ?? não existe
-- XOR,     OK
-- SLT,     OK
-- JAL,     OK
-- JALR,    OK
-- AUIPC,   OK
-- LUI,     OK
-- BEQ,     OK
-- BNE      OK
-- Grupo 3:  Shift
-- SLL: deslocamento lógico à esquerda          OK
-- sll rd, rs1, rs2 X[rd] = X[rs1] << X[rs2]
-- SRL: deslocamento lógico à direita           OK
-- srl rd, rt, shamt X[rd] = X[rs1] >>u X[rs2]
-- SRA: deslocamento aritmético à direita       OK
-- sra rd, rt, shamt X[rd] = X[rs1] >> X[rs2] 

-- imm[11:0] rs1 000 rd 0010011 ADDI     OK
-- imm[11:0] rs1 010 rd 0010011 SLTI     OK 
-- imm[11:0] rs1 011 rd 0010011 SLTIU    OK
-- imm[11:0] rs1 100 rd 0010011 XORI     OK
-- imm[11:0] rs1 110 rd 0010011 ORI      OK
-- imm[11:0] rs1 111 rd 0010011 ANDI     OK
-- 0000000 shamt rs1 001 rd 0010011 SLLI OK
-- 0000000 shamt rs1 101 rd 0010011 SRLI OK
-- 0100000 shamt rs1 101 rd 0010011 SRAI OK

-- 0000000 rs2 rs1 000 rd 0110011 ADD    OK
-- 0100000 rs2 rs1 000 rd 0110011 SUB    OK
-- 0100000 rs2 rs1 101 rd 0110011 SRA    OK
-- 0000000 rs2 rs1 101 rd 0110011 SRL    OK
-- 0000000 rs2 rs1 001 rd 0110011 SLL    OK
-- 0000000 rs2 rs1 010 rd 0110011 SLT    OK
-- 0000000 rs2 rs1 011 rd 0110011 SLTU   OK
-- 0000000 rs2 rs1 100 rd 0110011 XOR    OK
-- 0000000 rs2 rs1 110 rd 0110011 OR     OK
-- 0000000 rs2 rs1 111 rd 0110011 AND    OK

-- imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011 BEQ     OK
-- imm[12|10:5] rs2 rs1 001 imm[4:1|11] 1100011 BNE     OK
-- imm[12|10:5] rs2 rs1 100 imm[4:1|11] 1100011 BLT     OK
-- imm[12|10:5] rs2 rs1 101 imm[4:1|11] 1100011 BGE     OK
-- imm[12|10:5] rs2 rs1 110 imm[4:1|11] 1100011 BLTU    OK
-- imm[12|10:5] rs2 rs1 111 imm[4:1|11] 1100011 BGEU    OK

        ula_control: process(request_ula_control)
        begin
            if (rising_edge(request_ula_control)) then
                if (Op = iRType) or (Op = iIType) then
                    if (funct3 = iADDSUB3) then
                        if (funct7b30 = iSUB7) and (Op = iRType) then
                            ALUOp <= ULA_SUB;
                        else
                            ALUOp <= ULA_ADD;
                        end if;
                    elsif (funct3 = iAND3) then
                        ALUOp <= ULA_AND;
                    elsif (funct3 = iOR3) then
                        ALUOp <= ULA_OR;
                    elsif (funct3 = iXOR3) then
                        ALUOp <= ULA_XOR;
                    elsif (funct3 = iSLL3) then
                        ALUOp <= ULA_SLL;
                    elsif (funct3 = iSRA3) then
                        if (funct7b30 = iSRA7) then
                            ALUOp <= ULA_SRA;
                        else
                            ALUOp <= ULA_SRL;
                        end if;
                    elsif (funct3 = iSLTI3) then
                        ALUOp <= ULA_SLT;
                    elsif (funct3 = iSLTIU3) then
                        ALUOp <= ULA_SLTU;
                    else
                        report "Erro de funcionamento do controle da ULA, funct3 invalido?" severity warning;
                    end if;
                elsif (Op = iBType) then
                    if (funct3 = iBEQ3) then
                        ALUOp <= ULA_SEQ;
                    elsif (funct3 = iBNE3) then
                        ALUOp <= ULA_SNE;
                    elsif (funct3 = iBLT3) then
                        ALUOp <= ULA_SLT;
                    elsif (funct3 = iBGE3) then
                        ALUOp <= ULA_SGE;
                    elsif (funct3 = iBLTU3) then
                        ALUOp <= ULA_SLTU;
                    elsif (funct3 = iBGEU3) then
                        ALUOp <= ULA_SGEU;
                    else
                        report "Erro de funcionamento do controle da ULA, funct3 invalido?" severity warning;
                    end if;
                else
                    report "Erro de funcionamento do controle da ULA, estado invalido?" severity warning;
                end if;
                request_ula_control <= '0';
            end if;
        end process ula_control;

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

                if (Op = iJAL) then
                    ALUSrcA     <= "01";-- SaidaULA <= regs[rs1] + (imm<<1)
                end if;
                
                --constant iRType		: std_logic_vector(6 downto 0) := "0110011";
                --constant iILType	    : std_logic_vector(6 downto 0) := "0000011";
                --constant iSType		: std_logic_vector(6 downto 0) := "0100011";
                --constant iBType		: std_logic_vector(6 downto 0) := "1100011";
                --TODO constant iIType		: std_logic_vector(6 downto 0) := "0010011";
                --TODO constant iLUI		: std_logic_vector(6 downto 0) := "0110111";
                --TODO constant iAUIPC		: std_logic_vector(6 downto 0) := "0010111";
                --constant iJALR		: std_logic_vector(6 downto 0) := "1100111";
                --constant iJAL		: std_logic_vector(6 downto 0) := "1101111";
                --TODO constant eCALL		: std_logic_vector(6 downto 0) := "1110011";

                if (Op = iRType) or (Op = iIType) or (Op = iLUI) or (Op = iAUIPC) then
                    NEXT_STATE <= CALC_R;                   -- Instruções do tipo R
                elsif (Op = iILType) or (Op = iSType) then
                    NEXT_STATE <= CALC_MEM;                 -- Load ou store
                elsif (Op = iBType) then
                    NEXT_STATE <= CALC_BRANCH;              -- Branches (desvios condicionais)
                elsif (Op = iJAL) or (Op = iJALR) then
                    NEXT_STATE <= CALC_JUMP;                -- Jumps
                else
                    -- Provavelmente a instrução NOP deve cair aqui?
                    NEXT_STATE <= FETCH;
                    report "Erro de funcionamento, opcode não implementado?" severity warning;
                end if;

            elsif (CURRENT_STATE = CALC_R) then
                -- ALUOut <= A op B

                if    (Op = iRType) then
                    request_ula_control <= '1';
                    ALUSrcA     <= "01";    -- A
                    ALUSrcB     <= "00";    -- B
                elsif (Op = iIType) then
                    request_ula_control <= '1';
                    ALUSrcB     <= "01";    -- A
                    ALUSrcA     <= "10";    -- Imm
                elsif (Op = iLUI)   then
                    ALUOp       <= "0000";  -- Soma
                    ALUSrcB     <= "11";    -- 0
                    ALUSrcA     <= "10";    -- Imm
                elsif (Op = iAUIPC) then
                    ALUOp       <= "0000";  -- Soma
                    ALUSrcB     <= "00";    -- PCback
                    ALUSrcA     <= "10";    -- Imm
                else
                    report "Erro de funcionamento, opcode inválido para o estado CALC_R" severity warning;
                end if;

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
                ALUOutWrite <= '1';     -- ALUout < ALUResult
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                NEXT_STATE <= MEM_R;
            elsif (CURRENT_STATE = CALC_MEM) then
                -- SaidaULA<=A+imm
                ALUOp       <= "0000";  -- Soma
                ALUSrcB     <= "01";    -- A
                ALUSrcA     <= "10";    -- Imm

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
                ALUOutWrite <= '1';     -- ALUout < ALUResult
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                if (Op = iILType)   then
                    NEXT_STATE <= MEM_LOAD;
                elsif (Op = iSType) then
                    NEXT_STATE <= MEM_STORE;
                else
                    report "Erro de funcionamento do controle, Opcode inválido para CALC_MEM?" severity warning;
                end if;
            elsif (CURRENT_STATE = CALC_BRANCH) then
                -- Se (A==B)
                -- PC<=SaidaULA

                request_ula_control <= '1';
                ALUSrcA     <= "01";    -- A
                ALUSrcB     <= "00";    -- B

                PCSource    <= '1';     -- PC <= saidaULA
                PCWriteCond <= '1';     -- escrita condicional no pc
                PCWrite     <= '0';     -- não há escrita fixa no pc
                IorD        <= '0';     -- dont care
                MemRead     <= '0';     -- Não há leitura na memória
                MemWrite    <= '0';     -- Não há escrita na memória
                MemtoReg    <= "00";    -- dont care
                MemDataWrite<= '0';     -- Não há escrita no registrador de memória
                IRWrite     <= '0';     -- Não há escrita no registrador de instruções
                RegWrite    <= '0';     -- Não há escrita no banco de registradores
                ALUOutWrite <= '0';     -- Não há escrita no registrador de saída da ULA
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                -- Fim da execução da instrução, podemos começar uma nova.
                NEXT_STATE <= FETCH;
            elsif (CURRENT_STATE = CALC_JUMP) then
                -- Reg[IR[11:7]]<= PC+4
                -- PC<=SaidaULA

                --ALUOp       <= "0000";  -- Dont care
                --ALUSrcB     <= "01";    -- Dont care
                --ALUSrcA     <= "00";    -- Dont care

                PCSource    <= '1';     -- PC <= saidaULA
                PCWriteCond <= '0';     -- Não há escrita condicional no pc
                PCWrite     <= '1';     -- PC <= saidaULA
                IorD        <= '0';     -- dont care
                MemRead     <= '0';     -- Não há leitura na memória
                MemWrite    <= '0';     -- Não há escrita na memória
                MemtoReg    <= "01";    -- rd <= PC+4
                MemDataWrite<= '0';     -- Não há escrita no registrador de memória
                IRWrite     <= '0';     -- Não há escrita no registrador de instruções
                RegWrite    <= '1';     -- Há escrita no banco de registradores
                ALUOutWrite <= '0';     -- Não há escrita no registrador de saída da ULA
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                -- Fim da execução da instrução, podemos começar uma nova.
                NEXT_STATE <= FETCH;
            elsif (CURRENT_STATE = MEM_R) then
                -- Reg[IR[11:7]]<=SaidaULA

                PCSource    <= '0';     -- dont care
                PCWriteCond <= '0';     -- não há escrita no pc
                PCWrite     <= '0';     -- não há escrita no pc
                IorD        <= '0';     -- dont care
                MemRead     <= '0';     -- Não há leitura na memória
                MemWrite    <= '0';     -- Não há escrita na memória
                MemtoReg    <= "00";    -- Banco de registradores recebe saída da ula
                MemDataWrite<= '0';     -- Não há escrita no registrador de memória
                IRWrite     <= '0';     -- Não há escrita no registrador de instruções
                RegWrite    <= '1';     -- Há escrita no banco de registradores
                --ALUOp       <= "0000";-- Dont care
                --ALUSrcB     <= "11";  -- Dont care
                --ALUSrcA     <= "00";  -- Dont care
                ALUOutWrite <= '0';     -- Não há mudança na ALUOut
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                -- Fim da execução da instrução, podemos começar uma nova.
                NEXT_STATE <= FETCH;
            elsif (CURRENT_STATE = MEM_LOAD) then
                -- Load: MDR <= Mem[SaidaULA]
                
                PCSource    <= '1';     -- Enderço vem da ALUOut
                PCWriteCond <= '0';     -- não há escrita no pc
                PCWrite     <= '0';     -- não há escrita no pc
                IorD        <= '0';     -- dont care
                MemRead     <= '1';     -- há leitura na memória
                MemWrite    <= '0';     -- não há escrita na memória
                MemtoReg    <= "00";    -- dont care
                MemDataWrite<= '1';     -- Há escrita no registrador de memória
                IRWrite     <= '0';     -- Não há escrita no registrador de instruções
                RegWrite    <= '0';     -- Não há escrita no banco de registradores
                --ALUOp       <= "0000";  -- Dont care
                --ALUSrcB     <= "00";    -- Dont care
                --ALUSrcA     <= "00";    -- Dont care
                ALUOutWrite <= '0';     -- Não há escrita no registrador de saída da ULA
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                NEXT_STATE <= MEM_LOAD_END;
            elsif (CURRENT_STATE = MEM_STORE) then
                -- Store: Mem[SaidaULA] <= B
                
                PCSource    <= '1';     -- Enderço vem da ALUOut
                PCWriteCond <= '0';     -- não há escrita no pc
                PCWrite     <= '0';     -- não há escrita no pc
                IorD        <= '0';     -- dont care
                MemRead     <= '0';     -- não há leitura na memória
                MemWrite    <= '1';     -- Há escrita na memória
                MemtoReg    <= "00";    -- dont care
                MemDataWrite<= '0';     -- Não há escrita no registrador de memória
                IRWrite     <= '0';     -- Não há escrita no registrador de instruções
                RegWrite    <= '0';     -- Não há escrita no banco de registradores
                --ALUOp       <= "0000";  -- Dont care
                --ALUSrcB     <= "00";    -- Dont care
                --ALUSrcA     <= "00";    -- Dont care
                ALUOutWrite <= '0';     -- Não há escrita no registrador de saída da ULA
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                -- Fim da execução da instrução, podemos começar uma nova.
                NEXT_STATE <= FETCH;
            elsif (CURRENT_STATE = MEM_LOAD_END) then
                -- Load: Reg[IR[11:7]] <= MDR

                PCSource    <= '0';     -- dont care
                PCWriteCond <= '0';     -- não há escrita no pc
                PCWrite     <= '0';     -- não há escrita no pc
                IorD        <= '0';     -- dont care
                MemRead     <= '0';     -- não há leitura na memória
                MemWrite    <= '0';     -- não há escrita na memória
                MemtoReg    <= "10";    -- Dado vem do registrador de memória
                MemDataWrite<= '0';     -- Não há escrita no registrador de memória
                IRWrite     <= '0';     -- Não há escrita no registrador de instruções
                RegWrite    <= '1';     -- Há escrita no banco de registradores
                --ALUOp       <= "0000";  -- Dont care
                --ALUSrcB     <= "00";    -- Dont care
                --ALUSrcA     <= "00";    -- Dont care
                ALUOutWrite <= '0';     -- Não há escrita no registrador de saída da ULA
                PCBackWren  <= '0';     -- Não há escrita no PCBack
                RDataWrite  <= '0';     -- Não há escrita em A,B

                -- Fim da execução da instrução, podemos começar uma nova.
                NEXT_STATE <= FETCH;
            else
                report "Erro de funcionamento do controle, ESTADO INVALIDO?" severity warning;
            end if;
        end process comb_process;
        
end RV32_Control_ARCH;
