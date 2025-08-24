-- ==========================================================
-- File              : pc_mapV_1.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow mapV implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | The higher-order function 'mapV' applies a function on all elements of a vector.
-- > mapV :: (a -> b)
-- >      -> Vector a  -- ^ /length/ = @la@
-- >      -> Vector b  -- ^ /length/ = @la@
-- > mapV f (x:>xs) = f x :> mapV f xs
-- > mapV _ NullV   = NullV
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity pc_mapV_1 is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a : in  dbf_out_cube(0 to nFFT-1); -- Input  vector a 
        b : out output_cube(0 to nFFT-1)  -- Output vector b
    );
end pc_mapV_1;

architecture rtl of pc_mapV_1 is
    
    signal transposeMat_i : output_cube(0 to nFFT-1);

    component pc_transposeMat is
        port (
            a : in  dbf_out_matrix(0 to nbin-1); -- Element of a
            b : out complex_int_range_vector(0 to nB-1) -- Element of b   
        );
    end component pc_transposeMat;

    component pc_mapV_2 is
        port (
            -- Type of should be modified depending on the application
            a : in  complex_int_range_vector(0 to nB-1); -- Input  vector a 
            b : out complex_int_range_vector(0 to nB-1)  -- Output vector b
        );
    end component pc_mapV_2;

begin

    -- Instantiate 1 function per vector element
    map_generate_1 : for i in 0 to a'LENGTH-1 generate
        f_instance : pc_transposeMat
        port map(
            a => a(i),
            b => transposeMat_i(i)
        );
    end generate map_generate_1;

    map_generate_2 : for i in 0 to a'LENGTH-1 generate
        pc_mapV_2_f : pc_mapV_2
        port map(
            a => transposeMat_i(i),
            b => b(i)
        );
    end generate map_generate_2;
      
end rtl;