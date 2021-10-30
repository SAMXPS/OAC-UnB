ENTITY XREGS_tb IS END;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE std.textio.ALL;

entity XREGS_tb is
    generic (WSIZE : natural := 32);
end XREGS_tb;

ARCHITECTURE XREGS_tb OF XREGS_tb IS
    
    
    -- Declaração do componente.
    component XREGS
    port (
        clk, wren, rst  : in std_logic;
        rs1, rs2, rd    : in std_logic_vector(4 downto 0);
        data            : in std_logic_vector(WSIZE-1 downto 0);
        ro1, ro2        : out std_logic_vector(WSIZE-1 downto 0)
    );
    end component;

    signal clk          : std_logic := '1';
    signal wren, rst    : std_logic := '0';
    signal rs1, rs2, rd : std_logic_vector(4 downto 0);
    signal ro1, ro2     : std_logic_vector(WSIZE-1 downto 0);
    signal data         : std_logic_vector(WSIZE-1 downto 0);

    -- Constantes para auxilio da testbench.
    constant clock_time: time           := 1 ns;
    constant clock_half_time: time      := 0.5 ns;
    constant clock_quarter_time: time   := 0.25 ns;    

    -- Variavel que finaliza a variação do clock quando em  false.
    shared variable enable_tb : boolean := true;
begin

    my_XREGS: XREGS port map(
        clk  => clk,
        wren => wren,
        rst  => rst,
        rs1  => rs1,
        rs2  => rs2,
        rd   => rd,
        ro1  => ro1,
        ro2  => ro2,
        data => data
    );

    -- Processo de geração do clock
    clock_process: process
    begin
        while enable_tb loop
            wait for clock_half_time;
            clk <= not clk;
        end loop;
        wait;
    end process clock_process;

    PROCESS 

        procedure write_to(
            frd   : std_logic_vector( 4 downto 0);
            fdata : std_logic_vector(31 downto 0)
        ) is
            begin
                wait until falling_edge(clk);
                wait for clock_quarter_time;
                wren <= '1';
                rst  <= '0';
                rd   <= frd;
                data <= fdata;
                wait until rising_edge(clk);
                wait for clock_quarter_time;
                wren <= '0';
        end procedure; 

        begin
            -- Inicialização
            wren <= '0';
            rd   <= "00000";
            rs1  <= "00000";
            rs2  <= "00000";
            data <= x"00000000";
            data <= x"00000000";

            -- Teste de reset
            rst  <= '1';
            wait until rising_edge(clk);
            wait for clock_quarter_time;
            rst  <= '0';

            -- Teste de escrita em x0
            write_to("00000", x"ffff0002");
            assert ro1 = x"00000000" report "Escrita indevida no registrador x0" severity warning;
            assert ro2 = x"00000000" report "Escrita indevida no registrador x0" severity warning;
            
            rs1 <= "00001";
            rs2 <= "00010";

            -- Teste de escrita em x1
            write_to("00001", x"ffff0001");
            assert ro1 = x"ffff0001" report "Erro de escrita em x1" severity warning;

            -- Teste de escrita em x2
            write_to("00010", x"ffff0002");
            assert ro2 = x"ffff0002" report "Erro de escrita em x2" severity warning;
            
            -- Teste de reset
            rst  <= '1';
            wait until rising_edge(clk);
            wait for clock_quarter_time;
            assert ro1 = x"00000000" report "Problema em reset" severity warning;
            assert ro2 = x"00000000" report "Problema em reset" severity warning;

            enable_tb := false;
            wait;
    end PROCESS; 

end XREGS_tb;