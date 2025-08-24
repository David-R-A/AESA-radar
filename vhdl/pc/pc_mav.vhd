-- ==========================================================
-- File              : pc_mav.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow mav implementation for the PC stage
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;
use work.params_pkg.all;

entity pc_mav is -- Update entity name on instantation
    port (
        ranges : in  complex_int_vector(0 to nbin-1);  -- Output vector
        mav_o  : out complex_int_vector(0 to nbin-1)
        -- Length of <a_vector> = <a>'length + 1     
    );
end pc_mav;

architecture rtl of pc_mav is

    constant S_INDEX : integer := IN_RESOLUTION + INT_RESOLUTION + PC_TAPS - 2; -- Start index for the reduced output
    constant N_T_LIMIT : integer := (IN_RESOLUTION - 1) + (INT_RESOLUTION - 1) - 1; -- Crop MSB index
    constant N_B_LIMIT : integer := (N_T_LIMIT + 1) - (INT_RESOLUTION - 1); -- Crop LSB index

    signal in_reverse_i : complex_int_vector(0 to nbin-1);
    signal tailsV_i     : complex_int_range_vector(0 to nbin);
    signal initV_i      : complex_int_range_vector(0 to nbin-1);
    signal mapV_i       : pc_add_T(0 to nbin-1); 
    signal crop_i       : complex_int_vector(0 to nbin-1);

    component pc_reverseV is
        port (
            a         : in  complex_int_vector(0 to nbin-1);
            a_reverse : out complex_int_vector(0 to nbin-1)
        );
    end component pc_reverseV;


    component pc_tailsV is
        port (
            a        : in  complex_int_vector(0 to nbin-1);   
            a_vector : out complex_int_range_vector(0 to nbin)      
        );
    end component pc_tailsV;

    component pc_initV is
        port (
            a : in  complex_int_range_vector(0 to nbin); 
            b : out complex_int_range_vector(0 to nbin-1)  
        );
    end component pc_initV;

    component pc_mapV is -- Update entity name on instantation
        port (
            -- Type of should be modified depending on the application
            a : in  complex_int_range_vector(0 to nbin-1); 
            b : out pc_add_T(0 to nbin-1)
        );
    end component pc_mapV;

begin

    reverseV_1_f : pc_reverseV
    port map(
        a         => ranges,
        a_reverse => in_reverse_i
    );

    tailsV_f : pc_tailsV
    port map(
        a => in_reverse_i,
        a_vector => tailsV_i
    );

    initV_f : pc_initV
    port map(
        a => tailsV_i,
        b => initV_i
    );

    mapV_f : pc_mapV
    port map(
        a => initV_i,
        b => mapV_i
    );

    gen_crop: for i in 0 to nbin-1 generate
    begin
        crop_i(i).r <= mapV_i(i).r(S_INDEX) & mapV_i(i).r(N_T_LIMIT downto N_B_LIMIT);
        crop_i(i).i <= mapV_i(i).i(S_INDEX) & mapV_i(i).i(N_T_LIMIT downto N_B_LIMIT);
    end generate;

    reverseV_2_f : pc_reverseV
    port map(
        a         => crop_i,
        a_reverse => mav_o
    );

end rtl;