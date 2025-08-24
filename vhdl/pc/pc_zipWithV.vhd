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

use work.devkit_lib.all;

entity pc_zipWithV is -- Update entity name on instantation
    port (
        a : in  complex_in_vector(0 to PC_TAPS-1); -- Input  vector a
        b : in  complex_int_vector(0 to nbin-1); -- Input  vector b   
        c : out pcMult_T(0 to PC_TAPS-1)  -- Output vector c
    );
end pc_zipWithV;

architecture rtl of pc_zipWithV is
    -- Zipping element/function
    component pc_mult is   -- Replace with function name
            port (
            dataa_imag   : in  std_logic_vector (15 DOWNTO 0);
            dataa_real   : in  std_logic_vector (15 DOWNTO 0);
            datab_imag   : in  std_logic_vector (19 DOWNTO 0);
            datab_real   : in  std_logic_vector (19 DOWNTO 0);
            result_imag  : out std_logic_vector (35 DOWNTO 0);
            result_real  : out std_logic_vector (35 DOWNTO 0)
        );
    end component pc_mult;

begin

    -- Instantiate the operation for all the vector elements
    -- Using c'length as reference

    zip_generate : for i in 0 to c'LENGTH-1 generate
        f_instance : pc_mult
        port map(
            dataa_imag  => a(i).i,
            dataa_real  => a(i).r,
            datab_imag  => b(i).i,
            datab_real  => b(i).r,
            result_imag => c(i).i,
            result_real => c(i).r
        );
    end generate zip_generate;
      
end rtl;