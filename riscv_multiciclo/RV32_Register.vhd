-- ****************************************** 
--  Circuito: Registrador RISCV 32 bits
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity RV32_Register is
    port (
        wren     : in  std_logic;
        data_in  : in  std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end RV32_Register;

architecture RV32_Register_ARCH of RV32_Register is
    signal iRegister : std_logic_vector(31 downto 0);
    begin
        write_process: process(wren) 
        begin
            if rising_edge(wren) then
                iRegister <= data_in;
            end if;
        end process write_process;

        update_process: process(iRegister) 
        begin
            data_out <= iRegister;
        end process update_process;      
end RV32_Register_ARCH;