-- ==========================================================
-- File              : pc_mapV.vhd
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

entity pc_mapV is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a : in  complex_int_range_vector(0 to nbin-1); 
        b : out pc_add_T(0 to nbin-1)
    );
end pc_mapV;

architecture rtl of pc_mapV is
    
    -- Function to be mapped
    -- > mapV :: (a -> b)
    component pc_applyFilter is
        port (
            value  : in complex_int_vector(0 to nbin-1);
            outval : out complex_pc_add_T    
        );
    end component pc_applyFilter;

begin

    -- Instantiate 1 function per vector element
    map_generate : for i in 0 to a'LENGTH-1 generate
        f_instance : pc_applyFilter
        port map(
            value  => a(i),
            outval => b(i)
        );
    end generate map_generate;
      
end rtl;