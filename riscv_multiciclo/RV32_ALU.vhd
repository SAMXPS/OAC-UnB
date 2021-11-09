-- ****************************************** 
--  Circuito: ULA RISCV 32
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity RV32_ALU is
    port (
        opcode     : in  std_logic_vector(3 downto 0);
        A, B       : in  std_logic_vector(31 downto 0);
        ALU_Result : out std_logic_vector(31 downto 0);
        Zero       : out std_logic
    );
end RV32_ALU;

architecture RV32_ALU_ARCH of RV32_ALU is
    constant TRUE_32 : std_logic_vector(31 downto 0) := x"00000001";
    constant FALSE_32 : std_logic_vector(31 downto 0) := x"00000000";
    begin
        process(opcode, A, B)
        begin    
            -- ADD A, B     ALU_Result recebe a soma das entradas A, B
            if opcode = "0000" then
                ALU_Result <= std_logic_vector(resize(unsigned(A) + unsigned(B), 32));
            end if;

            -- SUB A, B     ALU_Result recebe A - B
            if opcode = "0001" then 
                ALU_Result <= std_logic_vector(resize(unsigned(A) - unsigned(B), 32));
            end if;

            -- AND A, B     ALU_Result recebe a operação lógica A and B, bit a bit
            if opcode = "0010" then
                ALU_Result <= A AND B;
            end if;
            -- OR A, B      ALU_Result recebe a operação lógica A or B, bit a bit
            if opcode = "0011" then
                ALU_Result <= A OR  B;
            end if;

            -- XOR A, B     ALU_Result recebe a operação lógica A xor B, bit a bit
            if opcode = "0100" then
                ALU_Result <= A XOR B; 
            end if;

            -- SLL A, B        ALU_Result recebe a entrada A deslocada B bits à esquerda
            if opcode = "0101" then
                ALU_Result <= resize(shift_left(unsigned(A), unsigned(B)), 32);
            end if; 

            -- SRL A, B        ALU_Result recebe a entrada A deslocada B bits à direita sem sinal
            if opcode = "0110" then
                ALU_Result <= resize(shift_right(unsigned(A), unsigned(B)), 32);
            end if;  

            -- SRA A, B        ALU_Result recebe a entrada A deslocada B bits à direita com sinal 
            if opcode = "0111" then
                ALU_Result <= resize(shift_right(signed(A), unsigned(B)), 32);
            end if;  

            -- SLT A, B        ALU_Result = 1 se A < B, com sinal
            if opcode = "1000" then
                ALU_Result <= TRUE_32 when (signed(A) < signed(B)) else FALSE_32;
            end if;  

            -- SLTU A, B       ALU_Result = 1 se A < B, sem sinal
            if opcode = "1000" then
                ALU_Result <= TRUE_32 when (unsigned(A) < unsigned(B)) else FALSE_32;
            end if;  

            -- SGE A, B        ALU_Result = 1 se A ≥ B, com sinal
            if opcode = "1010" then
                ALU_Result <= TRUE_32 when (signed(A) >= signed(B)) else FALSE_32;
            end if;  

            -- SGEU A, B       ALU_Result = 1 se A ≥ B, sem sinal 
            if opcode = "1011" then
                ALU_Result <= TRUE_32 when (unsigned(A) >= unsigned(B)) else FALSE_32;
            end if;  

            -- SEQ A, B        ALU_Result = 1 se A == B
            if opcode = "1100" then
                ALU_Result <= TRUE_32 when (A = B) else FALSE_32;
            end if; 

            -- SNE A, B        ALU_Result = 1 se A != B
            if opcode = "1101" then
                ALU_Result <= FALSE_32 when (A = B) else TRUE_32;
            end if;

            if opcode = "1110" or opcode = "1111" then
                ALU_Result <= FALSE_32;
            end if;
                    
        end process;

        process(ALU_result)
        begin
            with ALU_Result select
            Zero <= '0' when x"00000000",
                    '1' when others;
        end process;

end RV32_ALU_ARCH;