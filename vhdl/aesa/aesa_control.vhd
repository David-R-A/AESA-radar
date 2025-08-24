-- ==========================================================
-- File              : aesa_control.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : AESA control module for managing the state machine and communication between HPS and FPGA
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;
use work.vhdl_extension_lib.all;

entity aesa_control is
    port (
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
end aesa_control;

architecture rtl of aesa_control is 
    type state_type is (IDLE, WAIT_DATA, START, OPERATIONAL, DONE);
    signal state        : state_type := IDLE; 
    signal next_state   : state_type := IDLE;
	 
    signal axilw_hps_r   : std_logic_vector(3 downto 0);
    signal axilw_hps_rr  : std_logic_vector(3 downto 0);
    signal axilw_fpga_r  : std_logic_vector(3 downto 0);
    signal axilw_fpga_rr : std_logic_vector(3 downto 0);
    
    signal sysout_fpga_done_r  : std_logic;
    signal sysout_fpga_done_rr : std_logic;

    signal rst_fast_r   : std_logic;
    signal rst_fast_rr  : std_logic;

    alias hps_recived   : std_logic is axilw_hps_rr(3);
    alias hps_sent      : std_logic is axilw_hps_rr(2);
    alias hps_rstn      : std_logic is axilw_hps_rr(1);
    alias hps_active    : std_logic is axilw_hps_rr(0);

    alias fpga_done     : std_logic is axilw_fpga_rr(3);
    alias fpga_received : std_logic is axilw_fpga_rr(2);
    alias fpga_active   : std_logic is axilw_fpga_rr(1);
    alias fpga_idle     : std_logic is axilw_fpga_rr(0);
    
    signal rst : std_logic;
    signal in_mem_full  : std_logic; 

    signal int_mem_wr_req_cnt : std_logic_vector(7 downto 0);
    signal int_mem_wr_req_i   : std_logic;
    signal in_mem_rd_read_i   : std_logic;
    signal int_mem_rd_req_i   : std_logic;
    signal int_mem_rd_first   : std_logic;
    signal out_mem_wr_req_cnt : std_logic_vector(31 downto 0);
    signal out_mem_wr_req_i   : std_logic;
    signal in_mem_rd_stalled  : std_logic;

begin

    rst <= not hps_rstn;
    rst_out <= rst;
    rst_fast_out <= rst_fast_rr;

    in_mem_full <= unary_and(in_mem_full_v);

    in_mem_rd_read_i <= '1' when (((state = OPERATIONAL) and (int_mem_usedw < x"F9") and ((int_mem_count = "111") or (in_mem_rd_stalled = '1')) and (in_mem_rd_empty = '0') and (int_mem_wr_full = '0')) or (state = START)) else '0';

    -- Generate int_mem_wr_req for 8 pulses
    process (clk, rst)
        variable int_count : std_logic_vector(7 downto 0) := x"00";
    begin 
        if rst = '1' then
            int_count := x"00";
        elsif rising_edge(clk) then
            int_count(0) := in_mem_rd_read_i;
            for i in 1 to int_count'length-1 loop
                int_count(i) := int_mem_wr_req_cnt(i-1);
            end loop;

            if ((int_mem_usedw >= x"F9") and (int_mem_count = "000")) then
                in_mem_rd_stalled <= '1';
            else
                in_mem_rd_stalled <= '0';
            end if;
                
        end if;
        int_mem_wr_req_cnt <= int_count;
    end process;

    int_mem_wr_req_i <= unary_or(int_mem_wr_req_cnt);

    --------------------------------------
    int_mem_rd_req_i <= '1' when ((state = OPERATIONAL) and (out_mem_usedw < "011100001") and (int_mem_rd_empty = '0') and ((out_mem_wr_req_cnt(31) = '1') or (int_mem_rd_first = '1'))) else '0';

    --Generate int_mem_wr_req for 32 pulses
    process (clk, rst)
        variable out_count : std_logic_vector(31 downto 0) := x"00000000";
    begin 
        if rst = '1' then
            out_count := x"00000000";
            int_mem_rd_first <= '1';
        elsif rising_edge(clk) then
            out_count(0) := int_mem_rd_req_i;
            for i in 1 to out_count'length-1 loop
                out_count(i) := out_mem_wr_req_cnt(i-1);
            end loop;
            if out_count(0) = '1' then
                int_mem_rd_first <= '0';
            elsif out_count(31) = '1' then
                int_mem_rd_first <= '1';
            end if;
        end if;
        out_mem_wr_req_cnt <= out_count;
    end process;

    out_mem_wr_req_i <= unary_or(out_mem_wr_req_cnt);
    --------------------------------------
    -- Finite State Machine (FSM) for AESA control
    process (clk, rst) 
    begin
        if rst = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process(state, hps_active, hps_sent, in_mem_full, in_mem_rd_read_i, int_mem_wr_req_i, int_mem_rd_req_i, out_mem_wr_req_i, sysout_fpga_done_rr)
    begin 
        case state is
            when IDLE =>
                in_mem_rd_read   <= '0';
                int_mem_wr_req   <= '0';
                int_mem_rd_req   <= '0';
                out_mem_wr_req   <= '0';

                fpga_done        <= '0';
                fpga_received    <= '0';
                fpga_active      <= '0';
                fpga_idle        <= '1';

                if (hps_active = '1') then
                    next_state <= WAIT_DATA;
                else
                    next_state <= IDLE;
                end if;

            when WAIT_DATA =>
                in_mem_rd_read   <= '0';
                int_mem_wr_req   <= '0';
                int_mem_rd_req   <= '0';
                out_mem_wr_req   <= '0';

                fpga_done        <= '0';
                fpga_received    <= '0';
                fpga_active      <= '1';
                fpga_idle        <= '0';

                if (hps_sent = '1') and (in_mem_full = '1') then
                    next_state   <= START;
                else
                    next_state   <= WAIT_DATA;
                end if;

            when START => 
                in_mem_rd_read   <= '1';
                int_mem_wr_req   <= '0';
                int_mem_rd_req   <= '0';
                out_mem_wr_req   <= '0';

                fpga_done        <= '0';
                fpga_received    <= '1';
                fpga_active      <= '1';
                fpga_idle        <= '0';

                next_state       <= OPERATIONAL;

            when OPERATIONAL =>
                in_mem_rd_read   <= in_mem_rd_read_i;
                int_mem_wr_req   <= int_mem_wr_req_i;
                int_mem_rd_req   <= int_mem_rd_req_i;
                out_mem_wr_req   <= out_mem_wr_req_i;

                fpga_done        <= '0';
                fpga_received    <= '1';
                fpga_active      <= '1';
                fpga_idle        <= '0';

                if (sysout_fpga_done_rr = '1') then
                    next_state       <= DONE;
                else
                    next_state       <= OPERATIONAL;
                end if;

            when DONE =>
                in_mem_rd_read   <= '0';
                int_mem_wr_req   <= '0';
                int_mem_rd_req   <= '0';
                out_mem_wr_req   <= '0';

                fpga_done        <= '1';
                fpga_received    <= '1';
                fpga_active      <= '1';
                fpga_idle        <= '0';

                next_state       <= DONE;

            when others =>
                in_mem_rd_read   <= '0';
                int_mem_wr_req   <= '0';
                int_mem_rd_req   <= '0';
                out_mem_wr_req   <= '0';

                fpga_done        <= '0';
                fpga_received    <= '0';
                fpga_active      <= '0';
                fpga_idle        <= '0';

                next_state       <= IDLE;
        end case;
    end process;

    -- Clock Domain Crossing
    -- Fast to slow
    process(clk)
    begin
        if rising_edge(clk) then
            axilw_hps_r  <= axilw_hps;
            axilw_hps_rr <= axilw_hps_r;

            sysout_fpga_done_r  <= sysout_fpga_done;
            sysout_fpga_done_rr <= sysout_fpga_done_r;
        end if;    
    end process; 
    
    -- Slow to fast
    process(clk_fast)
    begin
        if rising_edge(clk_fast) then
            axilw_fpga_r <= axilw_fpga_rr;
            axilw_fpga   <= axilw_fpga_r;

            rst_fast_r  <= not axilw_hps(1);
            rst_fast_rr <= rst_fast_r;
        end if;
    end process;

end rtl; -- rtl