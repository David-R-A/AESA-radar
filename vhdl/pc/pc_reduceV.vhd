-- ==========================================================
-- File              : reduceV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow reduceV implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | Reduces a vector of elements to a single element based on a
-- > -- binary function.
-- > --
-- > -- >>> reduceV (+) $ vector [1,2,3,4,5]
-- > -- 15
-- > reduceV :: (a -> a -> a) -> Vector a -> a
-- > reduceV _ NullV      = error "Cannot reduce a null vector"
-- > reduceV _ (x:>NullV) = x
-- > reduceV f (x:>xs)    = foldlV f x xs
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity pc_reduceV is -- Update entity name on instantation
    port (
        a_vector : in  pc_add_T(0 to PC_TAPS-1); -- Input vector type a 
        a        : out complex_pc_add_T         -- Output element type a
    );
end pc_reduceV;

architecture rtl of pc_reduceV is

    -- Holds the intermediate values of the reduce operation
    -- Length 1 unit less than a_vector
    signal reduce_v : pc_add_T(0 to a_vector'length-2);

    -- Reduction operation 
    -- > reduce :: (a -> a -> a) -> Vector a -> a
    -- Therefore all must be of the same type
    component pc_complex_add is
        port ( -- Modify port as needed
            a : in  complex_pc_add_T; -- Element of a
            b : in  complex_pc_add_T; -- Element of a
            y : out complex_pc_add_T  -- Element of a   
        );
    end component pc_complex_add;

begin

    -- First instance of the reduce operation
    f_instance_first : pc_complex_add
    port map(
        a => a_vector(0),
        b => a_vector(1),
        y => reduce_v(0)
    );

    -- Second to last instances
    reduce_generate : for i in 1 to a_vector'LENGTH-2 generate
        f_instance : pc_complex_add
        port map(
            a => a_vector(i+1),
            b => reduce_v(i-1),
            y => reduce_v(i)
        );
    end generate reduce_generate;

    -- Assing output
    a <= reduce_v(a_vector'length-2);
      
end rtl;