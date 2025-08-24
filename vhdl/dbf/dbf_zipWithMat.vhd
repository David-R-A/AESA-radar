-- ==========================================================
-- File              : dbf_zipWithMat.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow zipWithMat implementation for the DBF stage
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | Maps a function on every value of a matrix.
-- > --
-- > -- __OBS:__ this function does not check if the output matrix is well-formed.
-- > mapMat :: (a -> b)
-- >        -> Matrix a -- ^ /size/ = @(xa,ya)@
-- >        -> Matrix b -- ^ /size/ = @(xa,ya)@
-- > mapMat = mapV . mapV
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf_zipWithMat is -- Update entity name on instantation
    port (
        a : in  elMatrix_T; -- Input  matrix a
        b : in  complex_int_matrix(0 to nA-1, 0 to nB-1); -- Input  matrix b   
        c : out beamMatrix_T(0 to nA-1)  -- Output matrix c
    );
end dbf_zipWithMat;

architecture rtl of dbf_zipWithMat is

    component complex_mult is
        port
        (
            dataa_imag	: in std_logic_vector (15 downto 0);
            dataa_real	: in std_logic_vector (15 downto 0);
            datab_imag	: in std_logic_vector (19 downto 0);
            datab_real	: in std_logic_vector (19 downto 0);
            result_imag	: out std_logic_vector (35 downto 0);
            result_real	: out std_logic_vector (35 downto 0)
        );
    end component complex_mult;

begin

    -- > beamMatrix = zipWithMat (*) elMatrix beamConsts
    zip_generate_1 : for i in 0 to c'LENGTH-1 generate
        zip_generate_2 : for j in 0 to c(0)'LENGTH-1 generate
            complex_mult_inst : complex_mult
            port map(
                dataa_imag	=> a(i)(j).i,
                dataa_real	=> a(i)(j).r,
                datab_imag	=> b(i, j).i,
                datab_real	=> b(i, j).r,
                result_imag	=> c(i)(j).i,
                result_real	=> c(i)(j).r
            );
        end generate zip_generate_2;
    end generate zip_generate_1;
      
end rtl;