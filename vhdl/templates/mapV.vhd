-- ==========================================================
-- File              : mapV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-06-03
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

entity <mapV> is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        <a> : in  <a_type_vector>; -- Input  vector a 
        <b> : out <b_type_vector>  -- Output vector b
    );
end <mapV>;

architecture rtl of <mapV> is
    
    -- Function to be mapped
    -- > mapV :: (a -> b)
    component <function> is
        port (
            <f_a> : in  <a_type>; -- Element of a
            <f_b> : out <b_type> -- Element of b   
        );
    end component <function>;

begin

    -- Instantiate 1 function per vector element
    map_generate : for i in 0 to <a>'LENGTH-1 generate
        f_instance : <function>
        port map(
            <f_a> => <a>(i),
            <f_b> => <b>(i)
        );
    end generate map_generate;
      
end rtl;