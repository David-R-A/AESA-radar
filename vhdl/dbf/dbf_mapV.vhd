-- ==========================================================
-- File              : dbf_mapV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow copyV implementation for the DBF stage
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

entity dbf_mapV is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a : in  complex_in_vector(0 to nA-1); -- Input  vector a 
        b : out elMatrix_T(0 to nA-1)         -- Output vector b
    );
end dbf_mapV;

architecture rtl of dbf_mapV is

    component dbf_copyV is
        generic(
            a : integer
        );
        port (
            b        : in  complex_in;
            vector_b : out complex_in_vector(a-1 downto 0)     
        );
    end component dbf_copyV;

begin
    -- > elMatrix = mapV (copyV nB) antennas
    map_generate : for i in 0 to a'LENGTH-1 generate
        f_instance : dbf_copyV
        generic map(
            a => nB
        )
        port map(
            b        => a(i),
            vector_b => b(i)
        );
    end generate map_generate;
      
end rtl;