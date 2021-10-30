ENTITY memoriaRV_tb IS END;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE std.textio.ALL;

ARCHITECTURE memoriaRV_tb OF memoriaRV_tb IS

    -- Declaração do componente.
    component memoriaRV is
        port (
            clock   : in  std_logic;
            wren    : in  std_logic;
            address : in  std_logic_vector(11 downto 0); -- std_logic_vector sem tamanho pode ser utilizado para designar um
            datain  : in  std_logic_vector(31 downto 0); -- tamanho flexível de dados, definido conforme a instância da arquitetura.
            dataout : out std_logic_vector(31 downto 0)
        );
    end component;

    signal clock   : std_logic := '1';
    signal wren    : std_logic;
    signal address : std_logic_vector(11 downto 0);
    signal datain  : std_logic_vector(31 downto 0);
    signal dataout : std_logic_vector(31 downto 0);

    -- Constantes para auxilio da testbench.
    constant clock_time: time           := 1 ns;
    constant clock_half_time: time      := 0.5 ns;
    constant clock_quarter_time: time   := 0.25 ns;    

    -- Variavel que finaliza a variação do clock quando em  false.
    signal enable_tb : std_logic := '1';
begin

    my_memoriaRV: memoriaRV port map(
        clock   => clock,
        wren    => wren,
        address => address,
        datain  => datain,
        dataout => dataout
    );

    -- Processo de geração do clock
    clock_process: process
    begin
        while enable_tb = '1' loop
            wait for clock_half_time;
            clock <= not clock;
        end loop;
        wait;
    end process clock_process;

    testbench_process: process 
    begin
        wren      <= '0';
        address   <= x"000";
        wait until rising_edge(clock);
        assert dataout = x"00000001" report "Problema de leitura" severity warning;
        enable_tb <= '0';
        wait;
    end process testbench_process; 

end memoriaRV_tb;