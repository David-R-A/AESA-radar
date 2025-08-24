-- ==========================================================
-- File              : int_connect.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : Interconnection module between the DBF and PC modules
--                     Implements a FIFO structure that performs the matrix transpose
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.devkit_lib.all;
use work.vhdl_extension_lib.all;

entity int_connect is
    port (
        -- RESET
        rst          : in std_logic := '0';
        clk          : in  std_logic;
        
        -- fDBF 
        dbf_data     : in  complex_int_vector(0 to nB-1);
        dbf_wr_req   : in  std_logic;
        
        -- fPC
        pc_rd_req    : in  std_logic;
        pc_data      : out complex_int_vector(0 to nbin-1);
           
        -- FSM 
        rd_empty     : out std_logic;
        wr_full      : out std_logic;
        usedw        : out std_logic_vector(7 downto 0);
        mem_count    : out std_logic_vector(2 downto 0)
    );
end int_connect;

architecture rtl of int_connect is

    constant COUNTER_WIDTH : integer := integer(ceil(log2(real(nB))));

    signal fifo_sel   : std_logic_vector(nbin-1 downto 0);
    signal fifo_wre   : std_logic_vector(nbin-1 downto 0);
    signal full_v     : std_logic_vector(nbin-1 downto 0);
    signal empty_v    : std_logic_vector(nbin-1 downto 0);
    signal fifo_wrreq : std_logic_vector(nbin-1 downto 0);
    signal count      : std_logic_vector(COUNTER_WIDTH-1 downto 0);
    signal fifo_data  : std_logic_vector(2*INT_RESOLUTION-1 downto 0);
    
    type data_fifo_v is array (natural range <>) of std_logic_vector(2*INT_RESOLUTION-1 downto 0) ;
    signal q_v : data_fifo_v(nbin-1 downto 0);

    component int_fifo
        port (
            clock   : in  std_logic;
            data    : in  std_logic_vector(39 downto 0);
            rdreq   : in  std_logic;
            sclr    : in  std_logic;
            wrreq   : in  std_logic;
            empty   : out std_logic;
            full    : out std_logic;
            q       : out std_logic_vector(39 downto 0);
            usedw   : out std_logic_vector( 7 downto 0)  
        );
    end component;

    component counter
        generic (
            WIDTH : integer := 8
        );
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            en    : in  std_logic;
            count : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component rotator
        generic (
            WIDTH : integer := 4
        );
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            en    : in  std_logic;
            b_out : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

begin

    -- Process to convert the complex_int_vector to std_logic_vector
    -- and fifo data multiplexing
    process(dbf_data, count)
        variable dbf_data_fifo : data_fifo_v(0 to nB-1);
    begin
        for i in 0 to nB-1 loop
            dbf_data_fifo(i)(2*INT_RESOLUTION-1 downto INT_RESOLUTION) := dbf_data(i).r;
            dbf_data_fifo(i)(INT_RESOLUTION-1   downto              0) := dbf_data(i).i;
        end loop;
        fifo_data <= dbf_data_fifo(to_integer(unsigned(count)));
    end process;    

    -- Counter to perform the matrix transpose
    -- All values from a single DBF stage must be stored in the same FIFO
    -- before the next DBF stage is processed
    beam_counter : counter
        generic map (
            WIDTH => COUNTER_WIDTH
        )
        port map (
            clk   => clk,
            rst   => rst,
            en    => dbf_wr_req,
            count => count
        );

    mem_count <= count;

    -- Rotator to select the FIFO to write the data
    -- enabled after every 8 DBF writes (one DBF stage)
    range_rotator : rotator
        generic map (
            WIDTH => nbin
        )
        port map (
            clk   => clk,
            rst   => rst,
            en    => unary_and(count(2 downto 0)),
            b_out => fifo_sel
        );

    -- Transform from std_logic_vector to complex_int_vector
    -- and assign to the output port
    process(q_v)
    begin
        for i in 0 to nbin-1 loop
            pc_data(i).r <= q_v(i)(2*INT_RESOLUTION-1 downto INT_RESOLUTION);
            pc_data(i).i <= q_v(i)(INT_RESOLUTION-1   downto 0);
        end loop;
    end process;

    -- FIFO write request generation
    process(dbf_wr_req, fifo_sel)
    begin
        for i in 0 to nbin-1 loop
            fifo_wrreq(i) <= dbf_wr_req and fifo_sel(i);
        end loop;
    end process;

    wr_full  <= unary_and(full_v);
    rd_empty <= not (unary_and(not empty_v)); 

    -- FIFO instantiation (take usedw from the last FIFO)
    fifo_generate : for i in 0 to nbin-2 generate
        fifo_inst : int_fifo
            port map (
                clock   => clk,
                data    => fifo_data,
                rdreq   => pc_rd_req,
                sclr    => rst,
                wrreq   => fifo_wrreq(i),
                empty   => empty_v(i),
                full    => full_v(i),
                q       => q_v(i),
                usedw   => open
            );
    end generate fifo_generate;

    fifo_inst_l : int_fifo
        port map (
            clock   => clk,
            data    => fifo_data,
            rdreq   => pc_rd_req,
            sclr    => rst,
            wrreq   => fifo_wrreq(nbin-1),
            empty   => empty_v(nbin-1),
            full    => full_v(nbin-1),
            q       => q_v(nbin-1),
            usedw   => usedw
        );

end rtl;
