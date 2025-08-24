-- ==========================================================
-- File              : dbf_transposeCube.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow transposeCube implementation for the DBF stage
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- transposeCube :: Cube a -- ^ dimensions @(Z,Y,X)@
--               -> Cube a -- ^ dimensions @(Y,X,Z)@
-- transposeCube = mapV transposeMat . transposeMat
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf_transposeCube is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a : in  input_cube(0 to nA-1); 
        b : out input_cube_trans_trans(0 to nFFT-1) -- Output vector b
    );
end dbf_transposeCube;

architecture rtl of dbf_transposeCube is

    signal transpose_1_i : input_cube_trans(0 to nFFT-1);

    component dbf_transposeMat_1 is -- Update entity name on instantation
        port (
            a : in  input_cube(0 to nA-1); -- Input antenna vector
            b : out input_cube_trans(0 to nFFT-1)
        );
    end component dbf_transposeMat_1;

    component dbf_transpose_mapV is -- Update entity name on instantation
        port (
            -- Type of should be modified depending on the application
            a : in  input_cube_trans(0 to nFFT-1); -- Input  vector a 
            b : out input_cube_trans_trans(0 to nFFT-1)  -- Output vector b
        );
    end component dbf_transpose_mapV;

begin
    
    transposeMat_1_f : dbf_transposeMat_1
        port map(
            a => a,
            b => transpose_1_i
        );

    mapV_f : dbf_transpose_mapV
        port map(
            a => transpose_1_i,
            b => b
        );
      
end rtl;