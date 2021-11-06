ENTITY genImm32_tb IS END;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE std.textio.ALL;

ARCHITECTURE genImm32_tb OF genImm32_tb IS

    -- Declaração do componente.
    component genImm32
    port (
        instr : in  std_logic_vector(31 downto 0);
        imm32 : out signed(31 downto 0)
    );
    end component;

    signal instr : std_logic_vector(31 downto 0);
    signal imm32 : signed(31 downto 0);

begin

    my_genImm32: genImm32 port map(
        instr   => instr,
        imm32   => imm32
    );



    PROCESS 

        procedure test_instruction(
            input_instr : std_logic_vector(31 downto 0); 
            expected_imm32 : signed(31 downto 0)
        ) is
            begin
                instr <= input_instr;
                wait for 5 ns;
                assert imm32 = expected_imm32 report "Erro de funcionamento" severity warning;
                wait for 5 ns;
        end procedure; 

        begin

            wait for 5 ns;
            -- add t0, zero, zero 0x000002b3 R-type inexiste: 0 0x00000000
            test_instruction(x"000002b3", x"00000000");
            -- lw t0, 16(zero) 0x01002283 I-type0 16 0x00000010
            test_instruction(x"01002283", x"00000010");
            -- addi t1, zero, -100 0xf9c00313 I-type1 -100 0xFFFFFF9C
            test_instruction(x"f9c00313", x"FFFFFF9C");
            -- xori t0, t0, -1 0xfff2c293 I-type1 -1 0xFFFFFFFF
            test_instruction(x"fff2c293", x"FFFFFFFF");
            -- addi t1, zero, 354 0x16200313 I-type1 354 0x00000162
            test_instruction(x"16200313", x"00000162");
            -- jalr zero, zero, 0x18 0x01800067 I-type2 0x18 / 24 0x00000018
            test_instruction(x"01800067", x"00000018");
            -- lui s0, 2 0x00002437 U-type 0x2000 0x00002000
            test_instruction(x"00002437", x"00002000");
            -- sw t0, 60(s0) 0x02542e23 S-type 60 0x0000003C
            test_instruction(x"02542e23", x"0000003C");
            -- bne t0, t0, main 0xfe5290e3 SB-type -32C 0xFFFFFFE0
            test_instruction(x"fe5290e3", x"FFFFFFE0");
            -- jal rot 0x00c000ef UJ-type 0xC / 12 0x0000000C
            test_instruction(x"00c000ef", x"0000000C");
            wait;
    end PROCESS; 

end genImm32_tb;