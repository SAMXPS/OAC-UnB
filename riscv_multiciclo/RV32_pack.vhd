-- arquivo disponibilizado pelo professor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package RV32_pack is
    
    --constant IMEM_SIZE	: integer := 1024;
    --constant IMEM_ADDR	: integer := 8;
    --constant WORD_SIZE 	: natural := 32;
    --constant BREG_IDX 	: natural := 5;
    --constant ZERO32 		: std_logic_vector(WORD_SIZE-1 downto 0) := (others=>'0');
    --constant INC_PC		: std_logic_vector(WORD_SIZE-1 downto 0) := (2=>'1', others=>'0');
    
    -- Type Declaration (optional)
    --type word_array is array (natural range<>) of std_logic_vector(WORD_SIZE-1 downto 0);
    
    -- Opcodes do RV32I
    constant iRType		: std_logic_vector(6 downto 0) := "0110011";
    constant iILType	: std_logic_vector(6 downto 0) := "0000011";
    constant iSType		: std_logic_vector(6 downto 0) := "0100011";
    constant iBType		: std_logic_vector(6 downto 0) := "1100011";
    constant iIType		: std_logic_vector(6 downto 0) := "0010011";
    constant iLUI		: std_logic_vector(6 downto 0) := "0110111";
    constant iAUIPC		: std_logic_vector(6 downto 0) := "0010111";
    constant iJALR		: std_logic_vector(6 downto 0) := "1100111";
    constant iJAL		: std_logic_vector(6 downto 0) := "1101111";
    constant eCALL		: std_logic_vector(6 downto 0) := "1110011";

    -- Campo funct3
    constant iADDSUB3	: std_logic_vector(2 downto 0) := "000";
    constant iXOR3		: std_logic_vector(2 downto 0) := "100";
    constant iADD3		: std_logic_vector(2 downto 0) := "000";
    constant iOR3		: std_logic_vector(2 downto 0) := "110";
    constant iSLTI3		: std_logic_vector(2 downto 0) := "010";
    constant iAND3		: std_logic_vector(2 downto 0) := "111";
    constant iSLTIU3	: std_logic_vector(2 downto 0) := "001";
    constant iSLTU3	    : std_logic_vector(2 downto 0) := "011";
    constant iSR3		: std_logic_vector(2 downto 0) := "101";
    constant iBEQ3		: std_logic_vector(2 downto 0) := "000";
    constant iBNE3		: std_logic_vector(2 downto 0) := "001";
    constant iBLT3		: std_logic_vector(2 downto 0) := "100";
    constant iBGE3		: std_logic_vector(2 downto 0) := "101";	
    constant iBLTU3		: std_logic_vector(2 downto 0) := "110";
    constant iBGEU3		: std_logic_vector(2 downto 0) := "111";
    constant iLB3		: std_logic_vector(2 downto 0) := "000";
    constant iLH3		: std_logic_vector(2 downto 0) := "001";
    constant iSLL3		: std_logic_vector(2 downto 0) := "001";
    constant iSLA3		: std_logic_vector(2 downto 0) := "101";
    constant iSRA3		: std_logic_vector(2 downto 0) := "101";
    constant iSRI3		: std_logic_vector(2 downto 0) := "101";
    constant iLW3		: std_logic_vector(2 downto 0) := "000";
    constant iLBU3		: std_logic_vector(2 downto 0) := "100";
    constant iLHU3		: std_logic_vector(2 downto 0) := "101";
    constant iSB3		: std_logic_vector(2 downto 0) := "000";
    constant iSH3		: std_logic_vector(2 downto 0) := "001";
    constant iSW3		: std_logic_vector(2 downto 0) := "010";
    
    -- Campo funct7 / bit30	
    constant iSUB7		: std_logic := '1';
    constant iSRA7		: std_logic := '1';
    constant iSRAI7		: std_logic := '1';

    -- Controle ULA
    constant ULA_ADD	: std_logic_vector(3 downto 0) := "0000";
    constant ULA_SUB	: std_logic_vector(3 downto 0) := "0001";
    constant ULA_AND	: std_logic_vector(3 downto 0) := "0010";
    constant ULA_OR		: std_logic_vector(3 downto 0) := "0011";
    constant ULA_XOR	: std_logic_vector(3 downto 0) := "0100";
    constant ULA_SLL	: std_logic_vector(3 downto 0) := "0101";
    constant ULA_SRL	: std_logic_vector(3 downto 0) := "0110";
    constant ULA_SRA	: std_logic_vector(3 downto 0) := "0111";
    constant ULA_SLT	: std_logic_vector(3 downto 0) := "1000";
    constant ULA_SLTU	: std_logic_vector(3 downto 0) := "1001";
    constant ULA_SGE	: std_logic_vector(3 downto 0) := "1010";
    constant ULA_SGEU	: std_logic_vector(3 downto 0) := "1011";
    constant ULA_SEQ	: std_logic_vector(3 downto 0) := "1100";
    constant ULA_SNE	: std_logic_vector(3 downto 0) := "1101";
    
    -- Auxiliares para MUX ULA SRC A
    constant ULA_SRC_A_PCBACK	: std_logic_vector(1 downto 0) := "00";
    constant ULA_SRC_A_RDATA	: std_logic_vector(1 downto 0) := "01";
    constant ULA_SRC_A_PC		: std_logic_vector(1 downto 0) := "10";
    constant ULA_SRC_A_ZERO32   : std_logic_vector(1 downto 0) := "11";

    -- Auxiliares para MUX ULA SRC B
    constant ULA_SRC_B_RDATA	: std_logic_vector(1 downto 0) := "00";
    constant ULA_SRC_B_FOUR32	: std_logic_vector(1 downto 0) := "01";
    constant ULA_SRC_B_IMM		: std_logic_vector(1 downto 0) := "10";
    constant ULA_SRC_B_IMMS1   	: std_logic_vector(1 downto 0) := "11";

end RV32_pack;

package body RV32_pack is

    -- Type Declaration (optional)

    -- Subtype Declaration (optional)

    -- Constant Declaration (optional)

    -- Function Declaration (optional)

    -- Function Body (optional)

    -- Procedures

end RV32_pack;