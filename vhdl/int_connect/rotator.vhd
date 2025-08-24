-- ==========================================================
-- File              : rotator.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : Rotator module for shifting bits
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotator is
    generic (
        WIDTH : integer := 4
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        en    : in  std_logic;

        b_out : out std_logic_vector(WIDTH-1 downto 0)
    );
end rotator;

architecture rtl of rotator is
    signal b_out_i : std_logic_vector (WIDTH-1 downto 0);
begin

    process (clk, rst)
        variable last_bit : std_logic;
    begin
        if (rst = '1') then
                b_out_i <= (0 => '1', others => '0');
        elsif (rising_edge(clk)) then
            if (en = '1') then
                last_bit := b_out_i(WIDTH-1);
                b_out_i <= b_out_i(WIDTH-2 downto 0) & last_bit;
            end if;
        end if;
    end process;

    b_out <= b_out_i;
end rtl;