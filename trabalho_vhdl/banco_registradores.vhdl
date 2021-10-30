-- ****************************************** 
--  Circuito: Banco de Registradores RISCV 32
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity XREGS is
    generic (WSIZE : natural := 32);
    port (
    clk, wren, rst  : in std_logic;
    rs1, rs2, rd    : in std_logic_vector(4 downto 0);
    data            : in std_logic_vector(WSIZE-1 downto 0);
    ro1, ro2        : out std_logic_vector(WSIZE-1 downto 0)
);
end XREGS;


architecture XREGS_arch of XREGS is
    type xRegArray is array (natural range <>) of std_logic_vector(WSIZE-1 downto 0);
    signal bREG : xRegArray(0 to 31);
    begin
        -- Escrita/reset sempre será sincrona.
        sync_proc: process(clk) 
        begin
            if rising_edge(clk) then
                if (rst = '1') then
                    for i in bREG'range loop
                        bREG(i) <= x"00000000";
                    end loop;
                else
                    if (wren = '1') then
                        bREG(to_integer(unsigned(rd))) <= data;
                        bREG(0) <= x"00000000";
                    end if;
                end if;
            end if;
        end process sync_proc;

        -- Leitura pode ser assincrona. Assim que rs1 ou rs2 mudarem, os valores serão escritos no barramento.
        comb_proc: process(rs1, rs2, bREG)
        begin
            ro1 <= bREG(to_integer(unsigned(rs1)));
            ro2 <= bREG(to_integer(unsigned(rs2)));
        end process comb_proc;
end XREGS_arch;