-- ==========================================================
-- File              : copyV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow copyV implementation template
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

entity <copyV> is -- Update entity name on instantation
    generic(
        <a> : integer -- => a -- ^ number of elements = @n@
    );
    port (
        -- Type of should be modified depending on the application
        <b>        : in  <b_type>;       -- Input value
        <b_vector> : out <b_type_vector> -- Output b-type vector      
    );
end <copyV>;

architecture rtl of <copyV> is
begin
    -- Process to assing 'b' to all values of 'b_vector'
    process (<b>)
    begin
        copyV_loop : for i in 0 to <a>-1 loop
            <b_vector>(i) <= <b>;
        end loop copyV_loop;
    end process;  
end rtl;

-- ==== TEMPLATE WITHOUT GENERIC ================================

-- entity <copyV> is -- Update entity name on instantation
--     port (
--         <b>        : in  <b_type>;       -- Input value
--         <b_vector> : out <b_type_vector> -- Output b-type vector
--     );
-- end <copyV>;
--
-- architecture rtl of <copyV> is
-- begin
--     -- Process to assing 'b' to all values of 'b_vector'
--     <b_vector> <= (others => <b>);
-- end rtl;