-- ==========================================================
-- File              : pc_mult.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-14
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : PC complex multiplier
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_mult IS
    PORT (
        dataa_imag   : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        dataa_real   : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        datab_imag   : IN  STD_LOGIC_VECTOR (19 DOWNTO 0);
        datab_real   : IN  STD_LOGIC_VECTOR (19 DOWNTO 0);
        result_imag  : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
        result_real  : OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
    );
END pc_mult;

architecture Behavioral OF pc_mult IS
    -- Signals for signed operands
    signal a_re_s, a_im_s : SIGNED(15 DOWNTO 0);
    signal b_re_s, b_im_s : SIGNED(19 DOWNTO 0);

    -- Signals for intermediate products
    signal p1, p2, p3, p4 : SIGNED(35 DOWNTO 0);
begin
    -- Cast inputs to signed
    a_re_s <= SIGNED(dataa_real);
    a_im_s <= SIGNED(dataa_imag);
    b_re_s <= SIGNED(datab_real);
    b_im_s <= SIGNED(datab_imag);

    -- Multiply real parts: p1 = a_re * b_re, with triple resize to 36 bits
    p1 <= RESIZE( RESIZE(a_re_s, 36) * RESIZE(b_re_s, 36), 36 );
    -- Multiply imaginary parts: p2 = a_im * b_im, with triple resize to 36 bits
    p2 <= RESIZE( RESIZE(a_im_s, 36) * RESIZE(b_im_s, 36), 36 );

    -- Combine products for complex result
    -- Real = p1 - p2
    result_real <= STD_LOGIC_VECTOR(p1);
    -- Imag = p3 + p4
    result_imag <= STD_LOGIC_VECTOR(p2);
end Behavioral;