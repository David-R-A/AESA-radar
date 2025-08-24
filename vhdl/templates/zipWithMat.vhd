-- ==========================================================
-- File              : zipWithMat.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow zipWithMat implementation template
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

entity <zipWithMat> is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        <a> : in  <a_type_matrix>; -- Input  matrix a
        <b> : in  <b_type_matrix>; -- Input  matrix b   
        <c> : out <c_type_matrix>  -- Output matrix c
    );
end <zipWithMat>;

architecture rtl of <zipWithMat> is

    component <function> is
        port (
            <f_a> : in  <a_type>; -- Element of a
            <f_b> : in  <b_type>; -- Element of b   
            <f_c> : out <c_type>  -- Element of c
        );
    end component <function>;

begin

    zip_generate_1 : for i in 0 to <c>'LENGTH(1) generate
        zip_generate_2 : for j in 0 to <c>'LENGTH(2) generate
            f_instance : <function>
            port map(
                <f_a> => <a>(i, j),
                <f_b> => <b>(i, j),
                <f_c> => <c>(i, j)
            );
        end generate zip_generate_2;
    end generate zip_generate_1;
      
end rtl;