library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf_combSY is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        a : in  input_cube(0 to nA-1); -- Input  vector a 
        b : out dbf_out_cube(0 to nFFT-1)  -- Output vector b
    );
end dbf_combSY;

architecture rtl of dbf_combSY is
    
    signal transposeCube_i : input_cube_trans_trans(0 to nFFT-1);

    component dbf_transposeCube is
        port (
            -- Type of should be modified depending on the application
            a : in  input_cube(0 to nA-1); 
            b : out input_cube_trans_trans(0 to nFFT-1) -- Output vector b
        );
    end component dbf_transposeCube;

    component dbf_mapMat is
        port (
            a : in  input_cube_trans_trans(0 to nFFT-1); -- Input  vector a 
            b : out dbf_out_cube(0 to nFFT-1)  -- Output vector b  
        );
    end component dbf_mapMat;

begin

    transposeCube_f : dbf_transposeCube
    port map(
        a => a,
        b => transposeCube_i
    );

    f_instance : dbf_mapMat
    port map(
        a => transposeCube_i,
        b => b
    );
      
end rtl;