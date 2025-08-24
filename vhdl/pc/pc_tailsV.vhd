-- ==========================================================
-- File              : pc_tailsV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow pc_tailsV implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | Returns a vector containing all the possible suffixes of an input
-- > -- vector.
-- > --
-- > -- >>> let v = vector [1,2,3,4,5,6]
-- > -- >>> tailsV v
-- > -- <<1,2,3,4,5,6>,<2,3,4,5,6>,<3,4,5,6>,<4,5,6>,<5,6>,<6>,<>>
-- > tailsV :: Vector a          -- ^ /length/ = @la@
-- >        -> Vector (Vector a) -- ^ /length/ = @la + 1@
-- > tailsV NullV = NullV
-- > tailsV v    = foldrV sel (unitV NullV) $ mapV (unitV . unitV) v
-- >   where sel x y = mapV (<+> headV y) x <+> y
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity pc_tailsV is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a        : in  complex_int_vector(0 to nbin-1);   
        a_vector : out complex_int_range_vector(0 to nbin)  
        -- Length of <a_vector> = <a>'length + 1     
    );
end pc_tailsV;

architecture rtl of pc_tailsV is
    constant zero_vec : complex_int_vector(0 to nbin-1) := (others => COMPLEX_INT_ZERO);
begin
    process (a)
    begin
        a_vector(0) <= a;
        tailsV_loop : for i in 1 to a'length-1 loop
            a_vector(i) <= a(i to a'length-1) & zero_vec(a'length-i to nbin-1);
        end loop tailsV_loop;
        a_vector(a_vector'length-1) <= zero_vec;
    end process;  
end rtl;