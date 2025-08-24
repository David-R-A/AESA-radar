-- ==========================================================
-- File              : mapSY.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-06-02
-- Last modified     : 2025-06-03
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow mapSY implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- -- | The process constructor 'mapSY' takes a combinational function as
-- -- argument and returns a process with one input signal and one output
-- -- signal.
-- --
-- -- >>> mapSY (+1) $ signal [1,2,3,4]
-- -- {2,3,4,5}
-- mapSY :: (a -> b) -> Signal a -> Signal b
-- mapSY _ NullS   = NullS
-- mapSY f (x:-xs) = f x :- (mapSY f xs)
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity <mapSY> is -- Update entity name on instantation
    port (
        <a> : in  <a_type>; -- Input  vector a 
        <b> : out <b_type>  -- Output vector b
    );
end <mapSY>;

architecture rtl of <mapSY> is
    
    -- Function to be mapped
    -- > mapV :: (a -> b)
    component <function> is
        port (
            <f_a> : in  <a_type>; -- Element of a
            <f_b> : out <b_type> -- Element of b   
        );
    end component <function>;

begin

    f_instance : <function>
    port map(
        <f_a> => <a>,
        <f_b> => <b>
    );
      
end rtl;