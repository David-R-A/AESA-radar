-- ==========================================================
-- File              : mapSY.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
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

use work.devkit_lib.all;

entity pc_combSY is -- Update entity name on instantation
    port(
        a : in  dbf_out_cube(0 to nFFT-1);
        b : out output_cube(0 to nFFT-1)
    );
end pc_combSY;

architecture rtl of pc_combSY is
    
    -- Function to be mapped
    -- > mapV :: (a -> b)
    component pc_mapV_1 is
        port (
            a : in  dbf_out_cube(0 to nFFT-1); -- Element of a
            b : out output_cube(0 to nFFT-1) -- Element of b   
        );
    end component pc_mapV_1;

begin

    f_instance : pc_mapV_1
    port map(
        a => a,
        b => b
    );
      
end rtl;