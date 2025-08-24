-- ==========================================================
-- File              : delaySY.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-06-02
-- Last modified     : 2025-06-03
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow delaySY implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- -- | The process constructor 'delaySY' delays the signal one event
-- -- cycle by introducing an initial value at the beginning of the
-- -- output signal.  Note, that this implies that there is one event
-- -- (the first) at the output signal that has no corresponding event at
-- -- the input signal.  One could argue that input and output signals
-- -- are not fully synchronized, even though all input events are
-- -- synchronous with a corresponding output event. However, this is
-- -- necessary to initialize feed-back loops.
-- -- 
-- -- >>> delaySY 1 $ signal [1,2,3,4]
-- -- {1,1,2,3,4}
-- delaySY :: a        -- ^Initial state
--         -> Signal a -- ^Input signal
--         -> Signal a -- ^Output signal
-- delaySY e es = e:-es
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity <delaySY> is -- Update entity name on instantation
    port (
        clk : in  std_logic;
        rst : in  std_logic;

        <a> : in  <a_type>; -- Input  vector a 
        <b> : out <a_type>  -- Output vector b
    );
end <delaySY>;

-- Active HIGH asynchronous reset
architecture delaySY_arst of <delaySY> is
    constant reset_value : <a_type> := <rst_value>;

    signal b_i : <a_type> := reset_value;
begin

    process(clk, rst)
    begin
        if rst = '1' then
            b_i <= reset_value;
        elsif rising_edge(clk) then
            b_i <= a;
        end if;
    end process;
    
    b <= b_i;
end delaySY_arst;

-- Active LOW asynchronous reset
architecture delaySY_arstn of <delaySY> is
    constant reset_value : <a_type> := <rst_value>;

    signal b_i : <a_type> := reset_value;
begin

    process(clk, rst)
    begin
        if rst = '0' then
            b_i <= reset_value;
        elsif rising_edge(clk) then
            b_i <= a;
        end if;
    end process;
    
    b <= b_i;
end delaySY_arstn;

-- Active HIGH synchronous reset
architecture delaySY_srst of <delaySY> is
    constant reset_value : <a_type> := <rst_value>;

    signal b_i : <a_type> := reset_value;
begin

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                b_i <= reset_value;
            else
                b_i <= a;
            end if;
        end if;
    end process;
    
    b <= b_i;
end delaySY_srst;

-- Active LOW synchronous reset
architecture delaySY_srstn of <delaySY> is
    constant reset_value : <a_type> := <rst_value>;

    signal b_i : <a_type> := reset_value;
begin

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                b_i <= reset_value;
            else
                b_i <= a;
            end if;
        end if;
    end process;
    
    b <= b_i;
end delaySY_srstn;