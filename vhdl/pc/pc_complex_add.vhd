-- ==========================================================
-- File              : pc_complex_add.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-04-30
-- Last modified     : 2025-04-30
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : Complex addition module
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity pc_complex_add is
    port (
        a : in  complex_pc_add_T; -- Operand A 
        b : in  complex_pc_add_T; -- Operand B
        y : out complex_pc_add_T  -- Output with, take into account the bit growth accros the stages        
    );
end pc_complex_add;

architecture rtl of pc_complex_add is
begin
    -- Addition of the real parts
    y.r <= std_logic_vector(signed(a.r) + signed(b.r));
    
    -- Addition of the imaginary parts
    y.i <= std_logic_vector(signed(a.i) + signed(b.i));
end rtl;