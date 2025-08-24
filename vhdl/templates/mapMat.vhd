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

entity <mapMat> is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        <a> : in  <a_type_matrix>; -- Input matrix 
        <b> : out <b_type_matrix>  -- Output matrix
    );
end <mapMat>;

architecture rtl of <mapMat> is
    component <function>
        port (
            -- Antenna CpxData
            <f_a> : in  <a_type>; -- Input antenna vector
            --  Beam CpxData    
            <f_b> : out <b_type> -- Output beam vector        
        );
    end component <function>;
begin

    map_generate_i : for i in 0 to <a>'LENGTH-1 generate
        map_generate_j : for j in 0 to <a>(0)'LENGTH-1 generate
            function_f : <function>
                port map (
                    <f_a> => <a>(i)(j),
                    <f_b> => <b>(i)(j)
                );
        end generate map_generate_j;
    end generate map_generate_i;

end rtl ;