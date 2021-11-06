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

    -- Declaração do MUX
    component RV32_MUX2_32
    port (
        source_sel : in  std_logic;
        data_in_0  : in  std_logic_vector(31 downto 0);
        data_in_1  : in  std_logic_vector(31 downto 0);
        data_out   : out std_logic_vector(31 downto 0);
    );
    end component RV32_MUX2_32;

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
        MemtoReg    : out std_logic;
        IRWrite     : out std_logic;
        PCSource    : out std_logic;
        ALUOp       : out std_logic;
        ALUSrcB     : out std_logic_vector(2 downto 0);
        ALUSrcA     : out std_logic;
        RegWrite    : out std_logic
    );
    end component RV32_Control;

    signal Reset       : std_logic;
    signal Clock       : std_logic;
    signal Op          : std_logic_vector(6 downto 0);
    signal PCWriteCond : std_logic;
    signal PCWrite     : std_logic;
    signal IorD        : std_logic;
    signal MemRead     : std_logic;
    signal MemWrite    : std_logic;
    signal MemtoReg    : std_logic;
    signal IRWrite     : std_logic;
    signal PCSource    : std_logic;
    signal ALUOp       : std_logic;
    signal ALUSrcB     : std_logic_vector(2 downto 0);
    signal ALUSrcA     : std_logic;
    signal RegWrite    : std_logic;

    signal RegWriteData: std_logic(31 downto 0);

    signal PCWrite     : std_logic;
    signal PCin        : std_logic_vector(31 downto 0);
    signal PC          : std_logic_vector(31 downto 0);
    signal MemAddr     : std_logic_vector(31 downto 0);

    signal MemDataWrite: std_logic;
    signal MemData     : std_logic_vector(31 downto 0);
    signal MemDataR    : std_logic_vector(31 downto 0);
    
    signal RDataWrite  : std_logic;
    signal RdataApre   : std_logic_vector(31 downto 0);
    signal RdataApos   : std_logic_vector(31 downto 0);
    signal RdataBpre   : std_logic_vector(31 downto 0);
    signal RdataBpos   : std_logic_vector(31 downto 0);
    
    signal rs1, rs2, rd: std_logic_vector(4  downto 0);

begin

    PC: RV32_Register port map(
        wren      => PCWrite,
        data_in   => PCin,
        data_out  => PC
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

    MemAddrMux: RV32_MUX2_32 port map(
        source_sel  => IorD,
        data_in_0   => PC,
        data_in_1   => ALUOut,
        data_out    => MemAddr
    );

    MemoryDataRegister: RV32_Register port map(
        wren      => MemDataWrite,
        data_in   => MemData,
        data_out  => MemDataR
    );

    Memory : RV32_Memory port map(
        clock   => MemRead,
        wren    => MemWrite,
        address => MemAddr,
        datain  => RdataBpos,
        dataout => MemData
    );

    RegWriteMux: RV32_MUX2_32 port map(
        source_sel  => MemtoReg,
        data_in_0   => ALUOut,
        data_in_1   => MemDataR,
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
        RegWrite    => RegWrite
    );

end RV32_ARCH;