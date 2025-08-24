-- ==========================================================
-- File              : pc_applyFilter.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
--
-- Description       : ForSyDe-Shallow applyFilter implementation for the PC stage
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | applied in reverse order (more optimized)
-- > -- >>> let v = vector [0,0,0,0,0,1]
-- > -- >>> let c = vector [1,2,1]
-- > -- >>> mav c v
-- > -- <0,0,0,1,2,1>
-- > mav :: Num a
-- >     => Vector a  -- ^ vector of coefficients
-- >     -> Vector a  -- ^ input vector of numbers; /size/ = @n@
-- >     -> Vector a  -- ^ output vector of numbers; /size/ = @n@
-- > mav coefs = mapV applyFilter . initV . tailsV
-- >   where
-- >     applyFilter = reduceV (+) . zipWithV (*) coefs 
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;
use work.params_pkg.all;

entity pc_applyFilter is 
    port (
        value  : in complex_int_vector(0 to nbin-1);
        outval : out complex_pc_add_T    
    );
end pc_applyFilter;

architecture rtl of pc_applyFilter is
    signal zipWithV_i : pcMult_T(0 to PC_TAPS-1);

    component pc_zipWithV is -- Update entity name on instantation
        port (
            a : in  complex_in_vector(0 to PC_TAPS-1); -- Input  vector a
            b : in  complex_int_vector(0 to nbin-1); -- Input  vector b   
            c : out pcMult_T(0 to PC_TAPS-1)  -- Output vector c
        );
    end component pc_zipWithV;

    component pc_reduceV is -- Update entity name on instantation
        port (
            a_vector : in  pc_add_T(0 to PC_TAPS-1); -- Input vector type a 
            a        : out complex_pc_add_T         -- Output element type a
        );
    end component pc_reduceV;
begin

    zipWithV_f : pc_zipWithV
    port map(
        a => PC_PARAMS,
        b => value,
        c => zipWithV_i
    );

    reduceV_f : pc_reduceV
    port map(
        a_vector => to_complex_pc_add(zipWithV_i),
        a => outval
    );
end rtl;