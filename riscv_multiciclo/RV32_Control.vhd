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
        FETCH,                                      -- Ciclo 1: Fetch da instrução
        DECODE,                                     -- Ciclo 2: Decode da instrução
        CALC_R, CALC_MEM, CALC_BRANCH, CALC_JUMP,   -- Ciclo 3: Cálculo dos dados
        MEM_R, MEM_LOAD, MEM_STORE,                 -- Ciclo 4: Acesso à memória
        MEM_LOAD_END                                -- Ciclo 5: Fim do load
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
                    report "Erro de funcionamento, opcode não implementado?" severity warning;
                end if;

            elsif (CURRENT_STATE = CALC_R) then
                -- ALUOut <= A op B

                if    (Op = iRType) then
                    -- TODO ALUOp
                    ALUSrcA     <= "01";    -- A
                    ALUSrcB     <= "00";    -- B
                elsif (Op = iIType) then
                    -- TODO ALUOp
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

                -- TODO ALUOp: depende do funct3
                ALUOp       <= "1100";  -- A EQ B?
                ALUSrcB     <= "01";    -- A
                ALUSrcA     <= "00";    -- B

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