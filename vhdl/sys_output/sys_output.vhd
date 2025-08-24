-- ==========================================================
-- File              : sys_output.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-06-05
-- Last modified     : 2025-06-13
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : System output module:
--                     This module reads data from the PC side, stores it in a FIFO,
--                     and writes it to the HPS side. It handles the synchronization.
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.devkit_lib.all;

entity sys_output is
    port (
        -- FSM side
        fpga_done        : out std_logic;

        -- PC side
        pc_wr_clk        : in  std_logic;
        rst              : in  std_logic;
        rst_fast         : in  std_logic;
        pc_wr_req        : in  std_logic;
        pc_data          : in  complex_int_vector(0 to nbin-1);
        pc_used_w        : out std_logic_vector(8 downto 0);

        -- HPS side
        hps_clk          : in  std_logic;
        hps_bridge_addr  : out std_logic_vector(29 downto 0);
        hps_bridge_be    : out std_logic_vector( 7 downto 0);
        hps_bridge_read  : out std_logic;
        hps_bridge_write : out std_logic;
        hps_bridge_data  : out std_logic_vector(63 downto 0);
        hps_bridge_ack   : in  std_logic
    );
end sys_output;

architecture rtl of sys_output is

    -- Constants
    constant COUNTER_WIDTH : integer := integer(ceil(log2(real(nbin))));
    constant ADDRESS_WIDTH : integer := integer(ceil(log2(real(nB*nbin*nFFT))));
    
    constant BASE_ADDR     : std_logic_vector(10 downto 0) := "11100000000"; -- Address(29 downto 19) --> 0x38000000
    
    -- Signals
    signal fifo_empty  : std_logic;
    signal fifo_rd_req : std_logic;
    signal fifo_data   : std_logic_vector(39 downto 0);
    signal fifo_q      : std_logic_vector(39 downto 0);  
    signal hps_data    : std_logic_vector(63 downto 0);
    
    signal count       : std_logic_vector(COUNTER_WIDTH-1 downto 0);
    signal address     : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    signal addr_en     : std_logic;

    type state_type is (IDLE, FIFO_RD, REQUEST, ACK);
    signal state       : state_type := IDLE;

    component counter is
        generic (
            WIDTH : integer := 4  
        );
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;  
            en    : in  std_logic;  
            count : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component counter;

    component out_fifo
        port
        (
            aclr		: in std_logic := '0';
            data		: in std_logic_vector (39 downto 0);
            rdclk		: in std_logic;
            rdreq		: in std_logic;
            wrclk		: in std_logic;
            wrreq		: in std_logic;
            q		    : out std_logic_vector (39 downto 0);
            rdempty		: out std_logic;
            wrusedw		: out std_logic_vector (8 downto 0)
        );
    end component;

begin
    
    -- PC data multiplexer controller
    counter_inst : counter
    generic map (
        WIDTH => COUNTER_WIDTH 
    )
    port map (
        clk   => pc_wr_clk,
        rst   => rst,  
        en    => pc_wr_req,  
        count => count
    );

    -- PC data multiplexer
    fifo_data(19 downto  0) <= pc_data(to_integer(unsigned(count))).i;
    fifo_data(39 downto 20) <= pc_data(to_integer(unsigned(count))).r;

    -- FIFO instantiation
    out_fifo_inst : out_fifo 
    port map (
        aclr     => rst_fast,
		data	 => fifo_data,
		rdclk	 => hps_clk,
		rdreq	 => fifo_rd_req,
		wrclk	 => pc_wr_clk,
		wrreq	 => pc_wr_req,
		q	     => fifo_q,
		rdempty	 => fifo_empty,
		wrusedw	 => pc_used_w
	);    

    -- Fix FIFO output to 64 bits to be sent to HPS
    -- Memory alignment: 32 bits for real and 32 bits for imaginary
    hps_data (19 downto  0) <= fifo_q(19 downto  0);
    hps_data (31 downto 20) <= (others => '0');
    hps_data (51 downto 32) <= fifo_q(39 downto 20);
    hps_data (63 downto 52) <= (others => '0');

    -- Memory address counter
    addr_counter_inst : counter
    generic map (
        WIDTH => ADDRESS_WIDTH 
    )
    port map (
        clk   => hps_clk,
        rst   => rst_fast,  
        en    => addr_en,  
        count => address
    );

    -- HPS physical address generation
    hps_bridge_addr <= BASE_ADDR & address & "000";
    hps_bridge_be   <= x"FF";    -- Byte enable for 64 bits (8 bytes)
    hps_bridge_read <= '0';      -- Write only design
    hps_bridge_data <= hps_data; -- Assign data to output
    
    -- Write FSM
    process(hps_clk, rst_fast)
    begin
        if rst_fast = '1' then 
            state <= IDLE;
            hps_bridge_write <= '0';
            fpga_done <= '0';
        elsif (rising_edge(hps_clk)) then
            case state is
                when IDLE => 
                    hps_bridge_write <= '0';
                    fifo_rd_req      <= '0';
                    addr_en          <= '0';
                    if(fifo_empty /= '1') then
                        state <= FIFO_RD;
                    end if;
                
                when FIFO_RD =>
                    hps_bridge_write <= '0';
                    fifo_rd_req      <= '1';
                    addr_en          <= '0';
                    state <= REQUEST;

                when REQUEST =>
                    hps_bridge_write <= '1';
                    fifo_rd_req      <= '0';
                    addr_en          <= '0';
                    if(hps_bridge_ack = '1') then
                        state <= ACK;
                        hps_bridge_write <= '0';
                        if (address = x"FFFF") then
                            fpga_done <= '1';
                        end if;
                    end if;
                
                when ACK =>
                    hps_bridge_write <= '0';
                    fifo_rd_req      <= '0';
                    addr_en          <= '1';
                    if(fifo_empty /= '1') then
                        state <= FIFO_RD;
                    else
                        state <= IDLE;
                    end if;
                when others => 
                    hps_bridge_write <= '0';
                    fifo_rd_req      <= '0';
                    addr_en          <= '0';
                    state            <= IDLE;
            end case;
        end if;
    end process;
end rtl ; -- rtl

-- ADDRESS TO HPS PHYSICAL ADDRESS
-- 2^29 = 512 MiB
-- 2^28 = 256 MiB
-- 2^27 = 128 MiB
-- 2^26 = 64  MiB
-- 2^25 = 32  MiB
-- 2^24 = 16  MiB
-- 2^23 = 8   MiB
-- 2^22 = 4   MiB
-- 2^21 = 2   MiB
-- 2^20 = 1   MiB
-- 2^19 = 512 kiB
-- 2^18 = 256 kiB        15
-- 2^17 = 128 kiB        14
-- 2^16 = 64  kiB        13
-- 2^15 = 32  kiB        12
-- 2^14 = 16  kiB        11
-- 2^13 = 8   kiB        10
-- 2^12 = 4   kiB         9
-- 2^11 = 2   kiB         8
-- 2^10 = 1   kiB         7
-- 2^09 = 512   B         6
-- 2^08 = 256   B         5
-- 2^07 = 128   B         4
-- 2^06 = 64    B         3
-- 2^05 = 32    B         2        
-- 2^04 = 16    B         1
-- 2^03 = 8     B = 64 b  0
-- 2^02 = 4     B = 32 b
-- 2^01 = 2     B = 16 b
-- 2^00 = 1     B =  8 b