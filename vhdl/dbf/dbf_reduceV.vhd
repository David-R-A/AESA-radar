-- ==========================================================
-- File              : dbf_reduceV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow reduceV implementation for the DBF stage
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | Reduces a vector of elements to a single element based on a
-- > -- binary function.
-- > --
-- > -- >>> reduceV (+) $ vector [1,2,3,4,5]
-- > -- 15
-- > reduceV :: (a -> a -> a) -> Vector a -> a
-- > reduceV _ NullV      = error "Cannot reduce a null vector"
-- > reduceV _ (x:>NullV) = x
-- > reduceV f (x:>xs)    = foldlV f x xs
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf_reduceV is -- Update entity name on instantation
    port (
        a_vector : in  beams_T(0 to nA-1);  -- Input  vector  type a 
        a        : out beams_v_T(0 to nB-1) -- Output element type a
    );
end dbf_reduceV;

architecture rtl of dbf_reduceV is

    signal reduce_v : beams_T(0 to a_vector'length -2);

    component dbf_zipWithV is
        port (
            a : in  beams_v_T; -- Input  vector a
            b : in  beams_v_T; -- Input  vector b   
            c : out beams_v_T  -- Output vector c
        );
    end component dbf_zipWithV;

begin

    -- > beams = reduceV (zipWithV (+)) beamMatrix
    f_instance_first : dbf_zipWithV
    port map(
        a => a_vector(0),
        b => a_vector(1),
        c => reduce_v(0)
    );

    reduce_generate : for i in 1 to a_vector'LENGTH-2 generate
        f_instance : dbf_zipWithV
        port map(
            a => a_vector(i+1),
            b => reduce_v(i-1),
            c => reduce_v(i)
        );
    end generate reduce_generate;

    a <= reduce_v(a_vector'length-2);
      
end rtl;