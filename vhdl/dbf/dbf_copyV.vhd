-- ==========================================================
-- File              : dbf_copyV.vhd
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
-- > -- | The function 'copyV' generates a vector with a given number of
-- > -- copies of the same element.
-- >
-- > -- >>> copyV 7 5 
-- > -- <5,5,5,5,5,5,5>
-- > copyV     :: (Num a, Eq a)
-- >          => a        -- ^ number of elements = @n@
-- >          -> b        -- ^ element to be copied
-- >          -> Vector b -- ^ /length/ = @n@
-- > copyV k x = iterateV k id x 
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf_copyV is
    generic(
        a : integer
    );
    port (
        -- Type of should be modified depending on the application
        b        : in  complex_in; -- Input value
        vector_b : out complex_in_vector(0 to a-1) -- Output b-type vector      
    );
end dbf_copyV;

architecture rtl of dbf_copyV is
begin
    -- Process to assing 'b' to all values of 'vector_b'
    -- elMatrix = mapV (copyV nB) antennas
    process (b)
    begin
        copyV_loop : for i in 0 to a-1 loop
            vector_b(i) <= b;
        end loop copyV_loop;
    end process;  
end rtl;