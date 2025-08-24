-- ==========================================================
-- File              : input_memory.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-06-05
-- Last modified     : 2025-06-13
-- University        : KTH - Royal Institute of Technology
--
-- Description       : Input memory module
--                     This module reads data from the HPS side, stores it in the input FIFOs,
--                     and provides the data to the fDBF. It handles the synchronization.
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;
use work.vhdl_extension_lib.all;

entity input_memory is
    port(
        -- RESET
        fifo_arst : in std_logic := '0';

        -- WRITE (HPS)
        wr_clk    : in std_logic;
        wr_addr   : in std_logic_vector (3 downto 0);
        wr_data   : in std_logic_vector (31 downto 0);
        wr_bus_en : in std_logic;
        wr_rw     : in std_logic;
        wr_ack    : out std_logic;

        -- READ (fDBF)
        rd_clk    : in std_logic;
        rd_data   : out complex_in_vector(0 to nA-1);

        -- FSM
        rd_read   : in  std_logic;
        wr_full_v : out std_logic_vector(nA-1 downto 0);
        rd_empty  : out std_logic
    );
end input_memory;

architecture rtl of input_memory is
    signal wr_request_v : std_logic_vector(nA-1 downto 0);
    signal rd_empty_v   : std_logic_vector(nA-1 downto 0);
    signal wr_full_v_i  : std_logic_vector(nA-1 downto 0);

    type state_type is (IDLE, FIFO_WR, ACK);
    signal state, next_state : state_type := IDLE;
    
    type q_array is array (natural range <>) of std_logic_vector(2*IN_RESOLUTION-1 downto 0);
    signal q_v : q_array(0 to nA-1);

    component input_fifo
        port
        (
            aclr	: in  std_logic := '0';
            data	: in  std_logic_vector (31 downto 0);
            rdclk	: in  std_logic;
            rdreq	: in  std_logic;
            wrclk	: in  std_logic;
            wrreq	: in  std_logic;
            q		: out std_logic_vector (31 downto 0);
            rdempty	: out std_logic;
            wrfull	: out std_logic
        );
    end component;
begin
    -- State register
    process(wr_clk, fifo_arst)
    begin
        if fifo_arst = '1' then
            state <= IDLE;
        else
            if rising_edge(wr_clk) then
                state <= next_state;
            end if ;
        end if;
    end process;

    -- Next state logic and output generation
    -- Manages the connection with the: Intel FPGA's Avalon to External Bus Bridge IP
    process(state, wr_bus_en, wr_rw, wr_addr)
    begin
        wr_request_v <= (others => '0');
        wr_ack <= '0';
        next_state <= state;

        case state is
            when IDLE =>
                if wr_bus_en = '1' and wr_rw = '0' then
                    next_state <= FIFO_WR;
                end if;

            when FIFO_WR =>
                wr_request_v(to_integer(unsigned(wr_addr))) <= '1';                    
                next_state <= ACK;

            when ACK =>
                wr_ack <= '1';
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- Transform from std_logic_vector to complex_in
    process(q_v)
    begin
        for i in 0 to nA-1 loop
            rd_data(i).r <= q_v(i)(2*IN_RESOLUTION-1 downto IN_RESOLUTION);
            rd_data(i).i <= q_v(i)(IN_RESOLUTION-1   downto 0);
        end loop;
    end process;

    -- FIFO full signal output
    wr_full_v <= wr_full_v_i;
    
    -- FIFO empty signal output
    rd_empty <= not (unary_and(not rd_empty_v));

    -- FIFO instance generation (16 x 8192 x 32-bit)
    fifo_generate : for i in 0 to nA-1 generate
        fifo_instance : input_fifo
            port map(
                aclr    => fifo_arst,
                data    => wr_data,
                rdclk   => rd_clk,
                rdreq   => rd_read,
                wrclk   => wr_clk,
                wrreq   => wr_request_v(i),
                q       => q_v(i),
                rdempty => rd_empty_v(i),
                wrfull  => wr_full_v_i(i)
            );
    end generate fifo_generate;

end rtl;
