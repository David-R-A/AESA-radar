-- ==========================================================
-- File              : zipWithV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow zipWithV implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | The higher-order function 'zipWithV' applies a function pairwise on two vectors.
-- > zipWithV :: (a -> b -> c)
-- >          -> Vector a  -- ^ /length/ = @la@
-- >          -> Vector b  -- ^ /length/ = @lb@
-- >          -> Vector c  -- ^ /length/ = @minimum [la,lb]@
-- > zipWithV f (x:>xs) (y:>ys) = f x y :> (zipWithV f xs ys)
-- > zipWithV _ _ _ = NullV
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity <zipWithV> is -- Replace <zipWithV> with the desired entity name
    port (
        -- Type of should be modified depending on the application
        <a> : in  <a_type_vector>; -- Input  vector a
        <b> : in  <b_type_vector>; -- Input  vector b   
        <c> : out <c_type_vector>  -- Output vector c
    );
end <zipWithV>;

architecture rtl of <zipWithV> is
    -- Zipping element/function
    component <function> is   -- Replace with function name
        port ( -- Add variable names and types
            <f_a> : in  <a_type>; -- Element of a
            <f_b> : in  <b_type>; -- Element of b   
            <f_c> : out <c_type>  -- Element of c
        );
    end component <function>;

begin

    -- Instantiate the operation for all the vector elements
    -- Using c'length as reference

    zip_generate : for i in 0 to <c>'LENGTH-1 generate
        f_instance : <function>
        port map(
            <f_a> => <a>(i),
            <f_b> => <b>(i),
            <f_c> => <c>(i)
        );
    end generate zip_generate;
      
end rtl;