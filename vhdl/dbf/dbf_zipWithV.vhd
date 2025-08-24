-- ==========================================================
-- File              : dbf_zipWithV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow zipWithV implementation for the DBF stage
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | The higher-order function 'zipWithV' applies a function pairwise on two vectors.
-- > zipWithV :: (a -> b -> c)
-- >          -> Vector a  -- ^ /length/ = @la@
-- >          -> Vector b  -- ^ /length/ = @lb@
-- >          -> Vector c  -- ^ /length/ = @minimum [la,lb]@
-- > zipWithV f (x:>xs) (y:>ys) = f x y :> (zipWithV f xs ys)
-- > zipWithV _ _ _ = NullV
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf_zipWithV is     -- Updated entity name on instantation
    port (
        a : in  beams_v_T; -- Input  vector a
        b : in  beams_v_T; -- Input  vector b   
        c : out beams_v_T  -- Output vector c
    );
end dbf_zipWithV;

architecture rtl of dbf_zipWithV is

    component complex_add is
        port (
            a : in  complex_beams; -- Operand A 
            b : in  complex_beams; -- Operand B
            y : out complex_beams  -- Result        
        );
    end component;

begin

    -- Instantiate the operation for all the vector elements
    -- > beams = reduceV (zipWithV (+)) beamMatrix
    zip_generate : for i in 0 to c'LENGTH-1 generate
        f_instance : complex_add
        port map(
            a => a(i),
            b => b(i),
            y => c(i)
        );
    end generate zip_generate;
      
end rtl;