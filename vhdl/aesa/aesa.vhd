-- ==========================================================
-- File              : aesa.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : AESA Radar Top-Level Module
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity aesa is
    port (
        -- CLOCKS
        hps_clk    : in std_logic;
        fpga_clk   : in std_logic;     

        -- HPS-TO-FPGA AXI-BUS
        h2f_addr   : in std_logic_vector ( 3 downto 0);
        h2f_data   : in std_logic_vector (31 downto 0);
        h2f_bus_en : in std_logic;
        h2f_rw     : in std_logic;
        h2f_ack    : out std_logic;

        -- FPGA-TO-HPS AXI-BUS
        f2h_addr   : out std_logic_vector(29 downto 0);
        f2h_be     : out std_logic_vector( 7 downto 0);
        f2h_read   : out std_logic;
        f2h_write  : out std_logic;
        f2h_data   : out std_logic_vector(63 downto 0);
        f2h_ack    : in  std_logic;

        -- HPS_TO_FPGA AXI_LW_BUS
        axilw_hps  : in  std_logic_vector( 3 downto 0);
        axilw_fpga : out std_logic_vector( 3 downto 0)
    );
end aesa;

architecture rtl of aesa is

    signal rst              : std_logic;

    signal in_mem_rd_data   : complex_in_vector(0 to nA-1);
    signal in_mem_rd_read   : std_logic;
    signal in_mem_full_v    : std_logic_vector(nA-1 downto 0);
    signal in_mem_rd_empty  : std_logic;

    signal fdbf_out         : complex_int_vector(0 to nB-1);

    signal int_mem_wr_req   : std_logic;
    signal int_mem_rd_req   : std_logic;
    signal int_mem_pc_data  : complex_int_vector(0 to nbin-1);
    signal int_mem_rd_empty : std_logic;
    signal int_mem_wr_full  : std_logic;
    signal int_mem_usedw    : std_logic_vector(7 downto 0);
    signal int_mem_count    : std_logic_vector(2 downto 0);

    signal fpc_out          : complex_int_vector(0 to nbin-1);

    signal out_mem_wr_req   : std_logic;
    signal out_mem_usedw    : std_logic_vector(8 downto 0);

    signal fpga_done        : std_logic;

    signal rst_fast         : std_logic;

    component input_memory is
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
    end component input_memory;

    component fDBF is
        port (
            antennas : in  complex_in_vector(0 to nA-1);  
            beams    : out complex_int_vector(0 to nB-1)        
        );
    end component fDBF;

    component int_connect is
        port (
            -- RESET
            rst           : in std_logic := '0';
            clk           : in  std_logic;
            
            -- fDBF 
            dbf_data      : in  complex_int_vector(0 to nB-1);
            dbf_wr_req    : in  std_logic;
            
            -- fPC
            pc_rd_req     : in  std_logic;
            pc_data       : out complex_int_vector(0 to nbin-1);
            
            -- FSM 
            rd_empty      : out std_logic;
            wr_full       : out std_logic;
            usedw         : out std_logic_vector(7 downto 0);
            mem_count     : out std_logic_vector(2 downto 0)
        );
    end component int_connect;

    component fPC is 
        port (
            ranges : in  complex_int_vector(0 to nbin-1);
            fPC_o  : out complex_int_vector(0 to nbin-1)         
        );
    end component fPC;

    component sys_output is
        port (
            -- FSM side
            fpga_done : out std_logic;

            -- PC side
            pc_wr_clk : in  std_logic;
            rst       : in  std_logic;
            rst_fast  : in  std_logic;
            pc_wr_req : in  std_logic;
            pc_data   : in  complex_int_vector(0 to nbin-1);
            pc_used_w : out std_logic_vector(8 downto 0);

            -- HPS side
            hps_clk          : in  std_logic;
            hps_bridge_addr  : out std_logic_vector(29 downto 0);
            hps_bridge_be    : out std_logic_vector( 7 downto 0);
            hps_bridge_read  : out std_logic;
            hps_bridge_write : out std_logic;
            hps_bridge_data  : out std_logic_vector(63 downto 0);
            hps_bridge_ack   : in  std_logic
        );
    end component sys_output;

    component aesa_control is
        port(
            clk              : in  std_logic;
            clk_fast         : in  std_logic;
            rst_out          : out std_logic;
            rst_fast_out     : out std_logic;

            axilw_hps        : in  std_logic_vector(3 downto 0);
            axilw_fpga       : out std_logic_vector(3 downto 0);

            in_mem_rd_read   : out std_logic;
            in_mem_full_v    : in  std_logic_vector(nA-1 downto 0);
            in_mem_rd_empty  : in  std_logic;

            int_mem_wr_req   : out std_logic;
            int_mem_rd_req   : out std_logic;
            int_mem_rd_empty : in  std_logic;
            int_mem_wr_full  : in  std_logic;
            int_mem_usedw    : in  std_logic_vector(7 downto 0);
            int_mem_count    : in  std_logic_vector(2 downto 0);
            
            out_mem_wr_req   : out std_logic;
            out_mem_usedw    : in  std_logic_vector(8 downto 0);

            sysout_fpga_done : in  std_logic
        );
    end component aesa_control;

begin

    input_memory_inst : input_memory 
    port map(
        fifo_arst        => rst,
        wr_clk           => hps_clk,
        wr_addr          => h2f_addr,
        wr_data          => h2f_data,
        wr_bus_en        => h2f_bus_en,
        wr_rw            => h2f_rw,
        wr_ack           => h2f_ack,
        rd_clk           => fpga_clk,
        rd_data          => in_mem_rd_data,
        rd_read          => in_mem_rd_read,
        wr_full_v        => in_mem_full_v,
        rd_empty         => in_mem_rd_empty
    );

    fDBF_inst : fDBF
    port map(
        antennas         => in_mem_rd_data,
        beams            => fdbf_out
    );

    int_connect_inst : int_connect
    port map(
        rst              => rst,
        clk              => fpga_clk,
        dbf_data         => fdbf_out,
        dbf_wr_req       => int_mem_wr_req,
        pc_rd_req        => int_mem_rd_req,
        pc_data          => int_mem_pc_data,
        rd_empty         => int_mem_rd_empty,
        wr_full          => int_mem_wr_full,
        usedw            => int_mem_usedw,
        mem_count        => int_mem_count
    );

    fPC_inst : fPC
    port map(
        ranges           => int_mem_pc_data,
        fPC_o            => fpc_out
    );

    sys_output_inst : sys_output
    port map(
        fpga_done        => fpga_done,
        pc_wr_clk        => fpga_clk,
        rst              => rst,
        rst_fast         => rst_fast,
        pc_wr_req        => out_mem_wr_req,
        pc_data          => fpc_out,
        pc_used_w        => out_mem_usedw,
        hps_clk          => hps_clk,
        hps_bridge_addr  => f2h_addr,
        hps_bridge_be    => f2h_be,
        hps_bridge_read  => f2h_read,
        hps_bridge_write => f2h_write,
        hps_bridge_data  => f2h_data,
        hps_bridge_ack   => f2h_ack
    );

    aesa_control_inst : aesa_control
    port map(
        clk              => fpga_clk,
        clk_fast         => hps_clk,
        rst_out          => rst,
        rst_fast_out     => rst_fast,
        axilw_hps        => axilw_hps,
        axilw_fpga       => axilw_fpga,
        in_mem_rd_read   => in_mem_rd_read,
        in_mem_full_v    => in_mem_full_v,
        in_mem_rd_empty  => in_mem_rd_empty,
        int_mem_wr_req   => int_mem_wr_req,
        int_mem_rd_req   => int_mem_rd_req,
        int_mem_rd_empty => int_mem_rd_empty,
        int_mem_wr_full  => int_mem_wr_full,
        int_mem_usedw    => int_mem_usedw,
        int_mem_count    => int_mem_count,
        out_mem_wr_req   => out_mem_wr_req,
        out_mem_usedw    => out_mem_usedw,
        sysout_fpga_done => fpga_done
    );

end rtl;