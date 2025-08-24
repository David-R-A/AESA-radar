-- ==========================================================
-- File              : mapMat.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-06-03
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow mapMat implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | Maps a function on every value of a matrix.
-- > --
-- -- __OBS:__ this function does not check if the output matrix is well-formed.
-- > mapMat :: (a -> b)
-- >       -> Matrix a -- ^ /size/ = @(xa,ya)@
-- >       -> Matrix b -- ^ /size/ = @(xa,ya)@
-- > mapMat = mapV . mapV
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf_mapMat is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a : in  input_cube_trans_trans(0 to nFFT-1); -- Input  vector a 
        b : out dbf_out_cube(0 to nFFT-1)  -- Output vector b
    );
end dbf_mapMat;

architecture rtl of dbf_mapMat is
    component fDBF
        port (
            -- Antenna CpxData
            antennas : in  complex_in_vector(0 to nA-1); -- Input antenna vector
            --  Beam CpxData    
            beams    : out complex_int_vector(0 to nB-1) -- Output beam vector        
        );
    end component;
begin

    map_generate_i : for i in 0 to a'LENGTH-1 generate
        map_generate_j : for j in 0 to a(0)'LENGTH-1 generate
            dbf_f : fDBF
                port map (
                    antennas => a(i)(j),
                    beams   => b(i)(j)
                );
        end generate map_generate_j;
    end generate map_generate_i;

end rtl ;