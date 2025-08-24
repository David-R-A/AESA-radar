-- ==========================================================
-- File              : initV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow initV implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | The function 'initV' returns all but the last elements of a vector.
-- > initV :: Vector a  -- ^ /length/ = @la@
-- >       -> Vector a  -- ^ /length/ = @la-1@
-- > initV NullV  = error "initV: Vector is empty"
-- > initV (_:>NullV) = NullV
-- > initV (v:>vs)    = v :> initV vs
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity <initV> is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        <a> : in  <a_type_vector>; -- Input  vector
        <b> : out <a_type_vector>  -- Output vector 
        -- Length of <b> = <a>'length - 1     
    );
end <initV>;

architecture rtl of <initV> is
begin
    <b> <= <a>(0 to <a>'length-2);  
end rtl;