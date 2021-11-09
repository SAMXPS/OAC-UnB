-- ****************************************** 
--  Circuito: RISCV-32 MultiCiclo
--  Autor: Samuel James de Lima Barroso / 190019948
-- ******************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity RV32 is end;

architecture RV32_ARCH of RV32 is

    -- Declaração do Registrador.
    component RV32_Register
    port (
        wren     : in  std_logic;
        data_in  : in  std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
    end component RV32_Register;

    -- Declaração do MUX2.
    component RV32_MUX2_32
    port (
        source_sel : in  std_logic;
        data_in_0  : in  std_logic_vector(31 downto 0);
        data_in_1  : in  std_logic_vector(31 downto 0);
        data_out   : out std_logic_vector(31 downto 0)
    );
    end component RV32_MUX2_32;

    -- Declaração do MUX4.
    component RV32_MUX4_32
    port (
        source_sel : in  std_logic_vector(1 downto 0);
        data_in_0  : in  std_logic_vector(31 downto 0);
        data_in_1  : in  std_logic_vector(31 downto 0);
        data_in_2  : in  std_logic_vector(31 downto 0);
        data_in_3  : in  std_logic_vector(31 downto 0);
        data_out   : out std_logic_vector(31 downto 0)
    );
    end component RV32_MUX4_32;

    -- Declaração do banco de registradores.
    component RV32_Registers
    port (
        clk, wren, rst  : in  std_logic;
        rs1, rs2, rd    : in  std_logic_vector(4  downto 0);
        data            : in  std_logic_vector(31 downto 0);
        ro1, ro2        : out std_logic_vector(31 downto 0)
    );
    end component RV32_Registers;

    -- Declaração da memória
    component RV32_Memory
    port (
        clock   : in  std_logic;
        wren    : in  std_logic;
        address : in  std_logic_vector(31 downto 0);
        datain  : in  std_logic_vector(31 downto 0);
        dataout : out std_logic_vector(31 downto 0)
    );
    end component RV32_Memory;

    -- Declaração da ULA
    component RV32_ALU
    port (
        opcode     : in  std_logic_vector(3 downto 0);
        A, B       : in  std_logic_vector(31 downto 0);
        ALU_Result : out std_logic_vector(31 downto 0);
        Zero       : out std_logic
    );
    end component;

    -- Declaração do gerador de imediatos.
    component RV32_ImmGen
    port (
        instr : in  std_logic_vector(31 downto 0);
        imm32 : out signed(31 downto 0)
    );
    end component;

    -- Declaração do controle.
    component RV32_Control
    port (
        Clock       : in  std_logic;
        Op          : in  std_logic_vector(6 downto 0);
        PCWriteCond : out std_logic;
        PCWrite     : out std_logic;
        IorD        : out std_logic;
        MemRead     : out std_logic;
        MemWrite    : out std_logic;
        MemtoReg    : out std_logic_vector(1 downto 0);
        IRWrite     : out std_logic;
        PCSource    : out std_logic;
        ALUOp       : out std_logic_vector(3 downto 0);
        ALUSrcB     : out std_logic_vector(1 downto 0);
        ALUSrcA     : out std_logic_vector(1 downto 0);
        RegWrite    : out std_logic;
        PCBackWren  : out std_logic;
        RDataWrite  : out std_logic;
        MemDataWrite: out std_logic;
        ALUOutWrite : out std_logic
    );
    end component RV32_Control;

    -- Sinais do Controle.
    signal Reset       : std_logic;
    signal Clock       : std_logic;
    signal Op          : std_logic_vector(6 downto 0);
    signal PCWriteCond : std_logic;
    signal PCWrite     : std_logic;
    signal IorD        : std_logic;
    signal MemRead     : std_logic;
    signal MemWrite    : std_logic;
    signal MemtoReg    : std_logic_vector(1 downto 0);
    signal IRWrite     : std_logic;
    signal PCSource    : std_logic;
    signal ALUOp       : std_logic_vector(3 downto 0);
    signal ALUSrcB     : std_logic_vector(1 downto 0);
    signal ALUSrcA     : std_logic_vector(1 downto 0);
    signal RegWrite    : std_logic;
    signal PCBackWren  : std_logic;
    -- Sinais de controles extras.
    signal RDataWrite  : std_logic;
    signal MemDataWrite: std_logic;
    signal ALUOutWrite : std_logic;

    -- Sinais do program counter.
    signal PCin        : std_logic_vector(31 downto 0);
    signal PC          : std_logic_vector(31 downto 0);
    signal PCWren      : std_logic;
    signal PCBack      : std_logic_vector(31 downto 0);

    -- Sinais da Memória.
    signal MemAddr     : std_logic_vector(31 downto 0);
    signal MemData     : std_logic_vector(31 downto 0);
    signal MemDataR    : std_logic_vector(31 downto 0);
    
    -- Sinais do banco de Registradores.
    signal RegWriteData: std_logic_vector(31 downto 0);
    signal RdataApre   : std_logic_vector(31 downto 0);
    signal RdataApos   : std_logic_vector(31 downto 0);
    signal RdataBpre   : std_logic_vector(31 downto 0);
    signal RdataBpos   : std_logic_vector(31 downto 0);
    signal rs1, rs2, rd: std_logic_vector(4  downto 0);
    signal Instruction : std_logic_vector(31 downto 0);

    -- Sinais do gerador de Imediatos.
    signal ImmGenOut   : std_logic_vector(31 downto 0);
    signal ImmGenOutSL1: std_logic_vector(31 downto 0);
    signal ImmGenOutINT: signed(31 downto 0);

    -- Sinais da ULA.
    signal ALUDataINA  : std_logic_vector(31 downto 0);
    signal ALUDataINB  : std_logic_vector(31 downto 0);
    signal ALUResult   : std_logic_vector(31 downto 0);
    signal ALUOut      : std_logic_vector(31 downto 0);
    signal ALUZero     : std_logic;

begin

    Op  <= Instruction(6  downto 0 );
    rs1 <= Instruction(19 downto 15);
    rs2 <= Instruction(24 downto 20);
    rd  <= Instruction(11 downto 7 );
    PCwren <= PCWrite and (PCWriteCond and ALUZero);
    ImmGenOut <= std_logic_vector(ImmGenOutINT);
    ImmGenOutSL1 <= ImmGenOut(31 downto 1) & '0'; -- ImmGenOut << 1

    PCreg: RV32_Register port map(
        wren      => PCWren,
        data_in   => PCin,
        data_out  => PC
    );

    PCBACKreg: RV32_Register port map(
        wren      => PCBackWren,
        data_in   => PC,
        data_out  => PCBack
    );

    MemAddrMux: RV32_MUX2_32 port map(
        source_sel  => IorD,
        data_in_0   => PC,
        data_in_1   => ALUOut,
        data_out    => MemAddr
    );

    Memory : RV32_Memory port map(
        clock   => MemRead,
        wren    => MemWrite,
        address => MemAddr,
        datain  => RdataBpos,
        dataout => MemData
    );

    MemoryDataRegister: RV32_Register port map(
        wren      => MemDataWrite,
        data_in   => MemData,
        data_out  => MemDataR
    );

    InstructionRegister: RV32_Register port map(
        wren      => IRWrite,
        data_in   => MemData,
        data_out  => Instruction
    );

    RegWriteMux: RV32_MUX4_32 port map(
        source_sel  => MemtoReg,
        data_in_0   => ALUOut,
        data_in_1   => PC,
        data_in_2   => MemDataR,
        data_in_3   => x"00000004",
        data_out    => RegWriteData
    );

    Registers: RV32_Registers port map(
        clk  => Clock,
        wren => RegWrite,
        rst  => Reset,
        rs1  => rs1,
        rs2  => rs2,
        rd   => rd,
        data => RegWriteData,
        ro1  => RdataApre,
        ro2  => RdataBpre
    );

    RdataA: RV32_Register port map(
        wren      => RDataWrite,
        data_in   => RdataApre,
        data_out  => RdataApos
    );

    RdataB: RV32_Register port map(
        wren      => RDataWrite,
        data_in   => RdataBpre,
        data_out  => RdataBpos
    );

    ImmGen: RV32_ImmGen port map(
        instr => Instruction,
        imm32 => ImmGenOutINT
    );

    ALU_SRC_A_MUX: RV32_MUX4_32 port map(
        source_sel  => ALUSrcA,
        data_in_0   => PCBack,
        data_in_1   => RdataApos,
        data_in_2   => PC,
        data_in_3   => x"00000000",
        data_out    => ALUDataINA
    );

    ALU_SRC_B_MUX: RV32_MUX4_32 port map(
        source_sel  => ALUSrcB,
        data_in_0   => RdataBpos,
        data_in_1   => x"00000004",
        data_in_2   => ImmGenOut,
        data_in_3   => ImmGenOutSL1, -- Imm << 1
        data_out    => ALUDataINB
    );

    ALU: RV32_ALU port map (
        opcode     => ALUOp,
        A          => ALUDataINA,
        B          => ALUDataINB,
        ALU_Result => ALUResult,
        Zero       => ALUZero
    );

    ALUOutR: RV32_Register port map(
        wren      => ALUOutWrite,
        data_in   => ALUResult,
        data_out  => ALUOut
    );

    PC_WRITE_MUX: RV32_MUX2_32 port map(
        source_sel  => PCSource,
        data_in_0   => ALUResult,
        data_in_1   => ALUOut,
        data_out    => PCin
    );

    Control: RV32_Control port map (
        Clock       => Clock,
        Op          => Op,
        PCWriteCond => PCWriteCond,
        PCWrite     => PCWrite,
        IorD        => IorD,
        MemRead     => MemRead,
        MemWrite    => MemWrite,
        MemtoReg    => MemtoReg,
        IRWrite     => IRWrite,
        PCSource    => PCSource,
        ALUOp       => ALUOp,
        ALUSrcB     => ALUSrcB,
        ALUSrcA     => ALUSrcA,
        RegWrite    => RegWrite,
        PCBackWren  => PCBackWren,
        RDataWrite  => RDataWrite;
        MemDataWrite=> MemDataWrite;
        ALUOutWrite => ALUOutWrite
    );

end RV32_ARCH;