-- ==========================================================
-- File              : zipWithSY.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-06-02
-- Last modified     : 2025-06-03
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow zipWithSY implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- -- | The process constructor 'zipWithSY' takes a combinational
-- -- function as argument and returns a process with two input signals
-- -- and one output signal.
-- --
-- -- >>> zipWithSY (+) (signal [1,2,3,4]) (signal [11,12,13,14,15,16,17])
-- -- {12,14,16,18}
-- zipWithSY :: (a -> b -> c) -> Signal a -> Signal b -> Signal c
-- zipWithSY _ NullS   _   = NullS
-- zipWithSY _ _   NullS   = NullS
-- zipWithSY f (x:-xs) (y:-ys) = f x y :- (zipWithSY f xs ys)
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity <zipWithSY> is -- Update entity name on instantation
    port (
        <a> : in  <a_type>; -- Input  vector a 
        <b> : in  <b_type>; -- Input  vector b
        <c> : out <c_type> 
    );
end <zipWithSY>;

architecture rtl of <zipWithSY> is
    
    component <function> is
        port (
            <f_a> : in  <a_type>; -- Element of a
            <f_b> : in  <b_type>; -- Element of b   
            <f_c> : out <c_type>
        );
    end component <function>;

begin

    f_instance : <function>
    port map(
        <f_a> => <a>,
        <f_b> => <b>,
        <f_c> => <c>
    );
      
end rtl;