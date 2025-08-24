-- ==========================================================
-- File              : tailsV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow tailsV implementation template
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

entity <tailsV> is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        <a>        : in  <a_type_vector>;       -- Input  vector
        <a_vector> : out <a_type_vector_vector> -- Output vector 
        -- Length of <a_vector> = <a>'length + 1     
    );
end <tailsV>;

architecture rtl of <tailsV> is
    constant null_vec : <a_type_vector> := (others => <a_type_null>); -- Null vector of the same type as <a>
begin
    process (<a>)
    begin
        <a_vector>(0) <= <a>; -- First element is the input vector itself
        tailsV_loop : for i in 1 to <a>'length-1 loop
            <a_vector>(i) <= <a>(i to <a>'length-1) & null_vec(0 to i-1);
        end loop tailsV_loop;
        <a_vector>(<a_vector>'length-1) <= null_vec; -- Last element is the null vector
    end process;  
end rtl;