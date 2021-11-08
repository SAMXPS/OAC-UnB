-- ****************************************** 
--  Circuito: MUX 4 RISCV 32 bits
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

-- Declaração do MUX4.
entity RV32_MUX4_32 is
port (
    source_sel : in  std_logic_vector(1 downto 0);
    data_in_0  : in  std_logic_vector(31 downto 0);
    data_in_1  : in  std_logic_vector(31 downto 0);
    data_in_2  : in  std_logic_vector(31 downto 0);
    data_in_3  : in  std_logic_vector(31 downto 0);
    data_out   : out std_logic_vector(31 downto 0)
);
end RV32_MUX4_32;
    

architecture RV32_MUX4_32_ARCH of RV32_MUX4_32 is
    begin
        WITH source_sel SELECT
            data_out <= data_in_0   WHEN "00",
                        data_in_1   WHEN "01",
                        data_in_2   WHEN "10",
                        data_in_3   WHEN "11",
                        x"00000000" WHEN OTHERS;
end RV32_MUX4_32_ARCH;