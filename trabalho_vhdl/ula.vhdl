-- ****************************************** 
--  Circuito: ULA RISCV 32
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity ulaRV is
    generic (WSIZE : natural := 32);
    port (
        opcode  : in  std_logic_vector(3 downto 0);
        A, B    : in  std_logic_vector(WSIZE-1 downto 0);
        Z       : out std_logic_vector(WSIZE-1 downto 0);
        cond    : out std_logic
    );
end ulaRV;

architecture ulaRV_arch of ulaRV is
    constant TRUE_32 : std_logic_vector(WSIZE-1 downto 0) := x"00000001";
    constant FALSE_32 : std_logic_vector(WSIZE-1 downto 0) := x"00000000";
    begin
        process(opcode, A, B)
        begin    
            -- ADD A, B     Z recebe a soma das entradas A, B
            if opcode = "0000" then
                Z <= std_logic_vector(resize(unsigned(A) + unsigned(B), 32));
            end if;

            -- SUB A, B     Z recebe A - B
            if opcode = "0001" then 
                Z <= std_logic_vector(resize(unsigned(A) - unsigned(B), 32));
            end if;

            -- AND A, B     Z recebe a operação lógica A and B, bit a bit
            if opcode = "0010" then
                Z <= A AND B;
            end if;
            -- OR A, B      Z recebe a operação lógica A or B, bit a bit
            if opcode = "0011" then
                Z <= A OR  B;
            end if;

            -- XOR A, B     Z recebe a operação lógica A xor B, bit a bit
            if opcode = "0100" then
                Z <= A XOR B; 
            end if;

            -- SLL A, B        Z recebe a entrada A deslocada B bits à esquerda
            if opcode = "0101" then
                Z <= resize(shift_left(unsigned(A), unsigned(B)), 32);
            end if; 

            -- SRL A, B        Z recebe a entrada A deslocada B bits à direita sem sinal
            if opcode = "0110" then
                Z <= resize(shift_right(unsigned(A), unsigned(B)), 32);
            end if;  

            -- SRA A, B        Z recebe a entrada A deslocada B bits à direita com sinal 
            if opcode = "0111" then
                Z <= resize(shift_right(signed(A), unsigned(B)), 32);
            end if;  

            -- SLT A, B        Z = 1 se A < B, com sinal
            if opcode = "1000" then
                Z <= TRUE_32 when (signed(A) < signed(B)) else FALSE_32;
            end if;  

            -- SLTU A, B       Z = 1 se A < B, sem sinal
            if opcode = "1000" then
                Z <= TRUE_32 when (unsigned(A) < unsigned(B)) else FALSE_32;
            end if;  

            -- SGE A, B        Z = 1 se A ≥ B, com sinal
            if opcode = "1010" then
                Z <= TRUE_32 when (signed(A) >= signed(B)) else FALSE_32;
            end if;  

            -- SGEU A, B       Z = 1 se A ≥ B, sem sinal 
            if opcode = "1011" then
                Z <= TRUE_32 when (unsigned(A) >= unsigned(B)) else FALSE_32;
            end if;  

            -- SEQ A, B        Z = 1 se A == B
            if opcode = "1100" then
                Z <= TRUE_32 when (A = B) else FALSE_32;
            end if; 

            -- SNE A, B        Z = 1 se A != B
            if opcode = "1101" then
                Z <= FALSE_32 when (A = B) else TRUE_32;
            end if;

            if opcode = "1110" or opcode = "1111" then
                Z <= FALSE_32;
            end if;
                
            with Z select
                cond <= '0' when x"00000000",
                        '1' when others;
        end process;
end ulaRV_arch;