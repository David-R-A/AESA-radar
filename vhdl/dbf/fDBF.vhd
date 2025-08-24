-- ==========================================================
-- File              : fDBF.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-13
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : DBF Top module
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > fDBF :: Antenna CpxData -- ^ input antenna elements
-- >      -> Beam    CpxData -- ^ output beams
-- > fDBF antennas  = beams
-- >   where
-- >     beams      = reduceV (zipWithV (+)) beamMatrix
-- >     beamMatrix = zipWithMat (*) elMatrix beamConsts
-- >     elMatrix   = mapV (copyV nB) antennas
-- >     beamConsts = mkBeamConsts dElements waveLength nA nB
--
-- ==== </ HASKELL CODE > =======================================

-- The module implementes the ```fDBF``` function

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;
use work.params_pkg.all; 

-- fDBF antennas  = beams
entity fDBF is
    port (
        -- Antenna CpxData
        antennas : in  complex_in_vector(0 to nA-1); -- Input antenna vector
        --  Beam CpxData    
        beams    : out complex_int_vector(0 to nB-1) -- Output beam vector        
    );
end fDBF;

architecture rtl of fDBF is

    signal elMatrix   : elMatrix_T(0 to nA-1);
    signal beamMatrix : beamMatrix_T(0 to nA-1);
    signal beams_i    : beams_v_T(0 to nB-1);

    constant S_INDEX : integer := IN_RESOLUTION + INT_RESOLUTION + nA - 2; -- Start index for the reduced output
    constant N_T_LIMIT : integer := (IN_RESOLUTION - 1) + (INT_RESOLUTION - 1) - 1; -- Crop MSB index
    constant N_B_LIMIT : integer := (N_T_LIMIT + 1) - (INT_RESOLUTION - 1); -- Crop LSB index

    component dbf_mapV is -- Update entity name on instantation
        port (
            -- Type of should be modified depending on the application
            a : in  complex_in_vector(0 to nA-1); -- Input  vector a 
            b : out elMatrix_T(0 to nA-1)         -- Output vector b
        );
    end component dbf_mapV;

    component dbf_zipWithMat is -- Update entity name on instantation
        port (
            a : in  elMatrix_T; -- Input  matrix a
            b : in  complex_int_matrix(0 to nA-1, 0 to nB-1); -- Input  matrix b   
            c : out beamMatrix_T(0 to nA-1)  -- Output matrix c
        );
    end component dbf_zipWithMat;

    component dbf_reduceV is
        port (
            a_vector : in beams_T(0 to nA-1); -- Input  vector a 
            a : out beams_v_T(0 to nB-1)  -- Output vector b
        );
    end component dbf_reduceV;

begin

    -- > elMatrix   = mapV (copyV nB) antennas
    elMatrix_f : dbf_mapV
    port map(
        a => antennas,
        b => elMatrix
    );

    -- > beamMatrix = zipWithMat (*) elMatrix beamConsts
    beamMatrix_f : dbf_zipWithMat
    port map(
        a => elMatrix,
        b => DBF_PARAMS,
        c => beamMatrix
    );

    -- > beams = reduceV (zipWithV (+)) beamMatrix
    beams_f : dbf_reduceV
    port map(
        a_vector => to_complex_beams_std_v(beamMatrix),
        a => beams_i
    );

    process(beams_i) 
    begin
        for i in 0 to nB-1 loop     -- Sign index             -- Decimal values indexes
            beams(i).r <= beams_i(i).r(S_INDEX) & beams_i(i).r(N_T_LIMIT downto N_B_LIMIT);
            beams(i).i <= beams_i(i).i(S_INDEX) & beams_i(i).i(N_T_LIMIT downto N_B_LIMIT);
        end loop;
    end process;

end rtl;