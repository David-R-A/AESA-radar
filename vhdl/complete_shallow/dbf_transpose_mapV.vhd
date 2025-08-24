-- ==========================================================
-- File              : dbf_transpose_mapV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow transpose_mapV implementation template
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

entity dbf_transpose_mapV is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a : in  input_cube_trans(0 to nFFT-1); -- Input  vector a 
        b : out input_cube_trans_trans(0 to nFFT-1)  -- Output vector b
    );
end dbf_transpose_mapV;

architecture rtl of dbf_transpose_mapV is
    
    -- Function to be mapped
    -- > mapV :: (a -> b)
    component dbf_transposeMat_2 is
        port (
            a : in  input_matrix(0 to nA-1); -- Element of a
            b : out input_matrix_trans(0 to nbin-1) -- Element of b   
        );
    end component dbf_transposeMat_2;

begin

    -- Instantiate 1 function per vector element
    map_generate : for i in 0 to a'LENGTH-1 generate
        f_instance : dbf_transposeMat_2
        port map(
            a => a(i),
            b => b(i)
        );
    end generate map_generate;
      
end rtl;