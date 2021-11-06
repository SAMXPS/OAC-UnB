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