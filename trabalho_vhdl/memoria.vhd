-- ****************************************** 
--  Circuito: Memória RISCV 32
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity memoriaRV is
    port (
        clock   : in  std_logic;
        wren    : in  std_logic;
        address : in  std_logic_vector; -- std_logic_vector sem tamanho pode ser utilizado para designar um
        datain  : in  std_logic_vector; -- tamanho flexível de dados, definido conforme a instância da arquitetura.
        dataout : out std_logic_vector
    );
end entity memoriaRV;

architecture memoriaRV_arch of memoriaRV is
    type   mem_type is array (0 to (2**address'length)-1) of std_logic_vector(datain'range);
    signal mem : mem_type;
    signal read_address : std_logic_vector(address'range);

    begin
        Write: process(clock) begin
            if wren = '1' then
                mem(to_integer(unsigned(address))) <= datain;
            end if;
            read_address <= address;
        end process;
        dataout <= mem(to_integer(unsigned(read_address)));
end memoriaRV_arch;