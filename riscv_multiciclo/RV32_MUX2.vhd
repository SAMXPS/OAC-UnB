-- ****************************************** 
--  Circuito: MUX 2 RISCV 32 bits
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

-- Declaração do MUX2.
entity RV32_MUX2_32 is
port (
    source_sel : in  std_logic;
    data_in_0  : in  std_logic_vector(31 downto 0);
    data_in_1  : in  std_logic_vector(31 downto 0);
    data_out   : out std_logic_vector(31 downto 0)
);
end RV32_MUX2_32;

architecture RV32_MUX2_32_ARCH of RV32_MUX2_32 is
    begin
        WITH source_sel SELECT
            data_out <= data_in_0   WHEN '0',
                        data_in_1   WHEN '1',
                        x"00000000" WHEN OTHERS;
end RV32_MUX2_32_ARCH;

