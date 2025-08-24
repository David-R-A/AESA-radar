-- ==========================================================
-- File              : pc_transposeMat.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow transposeMat implementation for the PC stage
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- -- | Transposes a matrx.
-- transposeMat :: Matrix a -- ^ /size/ = @(x,y)@
--              -> Matrix a -- ^ /size/ = @(y,x)@
-- transposeMat NullV = NullV
-- transposeMat (NullV:>xss) = transposeMat xss
-- transposeMat rows = (mapV headV rows) :> transposeMat (mapV tailV rows)
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity pc_transposeMat is -- Update entity name on instantation
    port (
        a : in  dbf_out_matrix(0 to nbin-1); -- Element of a
        b : out complex_int_range_vector(0 to nB-1) -- Element of b   
    );
end pc_transposeMat;

architecture rtl of pc_transposeMat is
begin
    
    gen_i : for i in 0 to nbin-1 generate
        gen_j : for j in 0 to nB-1 generate
            b(j)(i) <= a(i)(j);
        end generate;
    end generate;

end rtl;