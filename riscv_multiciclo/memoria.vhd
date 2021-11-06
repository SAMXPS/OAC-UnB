-- ****************************************** 
--  Circuito: Memória RISCV 32
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

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
    type   ram_type is array (0 to (2**address'length)-1) of std_logic_vector(datain'range);

    impure function init_ram_hex return ram_type  is
        file     data_file   : text open read_mode is "ram_data_hex.txt";
        file     code_file   : text open read_mode is "ram_code_hex.txt";
        variable text_line   : line;
        variable ram_depth   : natural := (2**address'length);
        variable ram_content : ram_type;
        variable i           : natural := 0;
        begin
            --for i in 0 to ram_depth - 1 loop
            --    readline(text_file, text_line);
            --    hread(text_line, ram_content(i));
            --end loop;

            i := 16#0000#/4; -- 0x0000 byte -> code address start
            while not endfile(code_file) loop
                readline(code_file, text_line);
                hread(text_line, ram_content(i));
                i := i + 1;
            end loop;

            while i < (16#2000#/4) loop
                ram_content(i) := std_logic_vector(to_unsigned(0,datain'length));
                i := i + 1;
            end loop;
            
            i := 16#2000#/4; -- 0x2000 -> data address start
            while not endfile(data_file) loop
                readline(data_file, text_line);
                hread(text_line, ram_content(i));
                i := i + 1;
            end loop;
            
            return ram_content;
    end function;

    signal mem : ram_type := init_ram_hex;
    signal read_address : std_logic_vector(address'range);

    begin

        dataout <= mem(to_integer(unsigned(read_address)));

        Write: process(clock) begin
            if wren = '1' then
                mem(to_integer(unsigned(address))) <= datain;
            end if;
            read_address <= address;
        end process;
end memoriaRV_arch;