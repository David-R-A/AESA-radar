-- ==========================================================
-- File              : devkit_lib.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-04-02
-- Last modified     : 2025-05-29
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : Development Library, stores common datatypes and functions to be used accross the modules
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package devkit_lib is
    -- Constants
    constant nA   : integer := 16;  -- Number of antennas
    constant nB   : integer := 8;   -- Number of beams
    constant nbin : integer := 32;  -- Number of bins
    constant nFFT : integer := 256; -- Number of pulses

    constant IN_RESOLUTION  : integer := 16; -- Input resolution in bits
    constant INT_RESOLUTION : integer := 20; -- Internal resolution in bits

    constant PC_TAPS : integer := 5; -- Parameter vector length @ PC
    
    -- Types
    subtype in_type is std_logic_vector(IN_RESOLUTION - 1 downto 0);   -- Real input type
    subtype int_type is std_logic_vector(INT_RESOLUTION - 1 downto 0); -- Real internal type

    type complex_in is record -- Complex input type
        r : in_type; -- Real part
        i : in_type; -- Imaginary part
    end record complex_in;

    type complex_int is record -- Complex internal type
        r : int_type; -- Real part
        i : int_type; -- Imaginary part
    end record complex_int;

    constant COMPLEX_IN_ZERO  : complex_in := ( -- Complex input type zero constant
        r => (others => '0'),
        i => (others => '0')
    );

    constant COMPLEX_INT_ZERO : complex_int := ( -- Complex internal type zero constant
        r => (others => '0'),
        i => (others => '0')
    );

    type complex_in_vector is array (natural range <>) of complex_in; -- Vector of complex input types
    type complex_int_vector is array (natural range <>) of complex_int; -- Vector of complex internal types

    type complex_int_matrix is array (natural range <>, natural range <>) of complex_int; -- Matrix of complex internal types

    -- DBF types
    type elMatrix_T is array (natural range <>) of complex_in_vector(0 to nB-1);

    type complex_beamMatrix is record
        r: std_logic_vector(IN_RESOLUTION + INT_RESOLUTION - 1 downto 0);
        i: std_logic_vector(IN_RESOLUTION + INT_RESOLUTION - 1 downto 0);
    end record complex_beamMatrix;
    type beamMatrix_v_T is array (natural range <>) of complex_beamMatrix;
    type beamMatrix_T is array (natural range <>) of beamMatrix_v_T(0 to nB-1);

    subtype beams_std_v is std_logic_vector(IN_RESOLUTION + INT_RESOLUTION + nA - 2 downto 0);

    type complex_beams is record 
        r : beams_std_v; -- Real part
        i : beams_std_v; -- Imaginary part
    end record complex_beams;

    type beams_v_T is array (natural range <>) of complex_beams; 
    type beams_T is array (natural range <>) of beams_v_T(0 to nB-1); 
    
    function to_complex_beams_std_v(input : beamMatrix_T) return beams_T;

    -- PC
    type complex_int_range_vector is array (natural range <>) of complex_int_vector(0 to nbin-1);

    type complex_pcMult is record
        r: std_logic_vector(IN_RESOLUTION + INT_RESOLUTION - 1 downto 0);
        i: std_logic_vector(IN_RESOLUTION + INT_RESOLUTION - 1 downto 0);
    end record complex_pcMult;
    type pcMult_T is array (natural range <>) of complex_pcMult;
    
    type complex_pc_add_T is record
        r: std_logic_vector(IN_RESOLUTION + INT_RESOLUTION + PC_TAPS - 2 downto 0);
        i: std_logic_vector(IN_RESOLUTION + INT_RESOLUTION + PC_TAPS - 2 downto 0);
    end record complex_pc_add_T;
    type pc_add_T is array (natural range <>) of complex_pc_add_T;

    function to_complex_pc_add(input : pcMult_T) return pc_add_T;

end package devkit_lib;

package body devkit_lib is

    -- Function to convert beamMatrix_T to beams_T with signed extension
    function to_complex_beams_std_v(input : beamMatrix_T) return beams_T is
        variable result : beams_T(0 to nA-1);
    begin
        -- Signed-extension of real and imaginary parts
        for i in 0 to nA-1 loop
            for j in 0 to nB-1 loop
                result(i)(j).r := std_logic_vector(resize(signed(input(i)(j).r), beams_std_v'length));
                result(i)(j).i := std_logic_vector(resize(signed(input(i)(j).i), beams_std_v'length));
            end loop;
        end loop;
        return result;

    end function to_complex_beams_std_v;
    
    -- Function to convert pcMult_T to pc_add_T with signed extension
    function to_complex_pc_add(input : pcMult_T) return pc_add_T is
        variable result : pc_add_T(0 to PC_TAPS-1);
    begin
        -- Signed-extension of real and imaginary parts
        for i in 0 to PC_TAPS-1 loop
            result(i).r := std_logic_vector(resize(signed(input(i).r), result(0).r'length));
            result(i).i := std_logic_vector(resize(signed(input(i).i), result(0).i'length));
        end loop;
        return result;

    end function to_complex_pc_add;
    
end package body devkit_lib;