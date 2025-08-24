library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity dbf is -- Update entity name on instantation
    port (
        -- Type of should be modified depending on the application
        dbf_in  : in  input_cube(0 to nA-1); -- Input  vector a 
        dbf_out : out dbf_out_cube(0 to nFFT-1)  -- Output vector b
    );
end dbf;

architecture rtl of dbf is

    component dbf_combSY is
        port (
            -- Type of should be modified depending on the application
            a : in  input_cube(0 to nA-1); -- Input  vector a 
            b : out dbf_out_cube(0 to nFFT-1)  -- Output vector b
        );
    end component dbf_combSY;

begin

    dbf_combSY_f : dbf_combSY
        port map(
            a => dbf_in,
            b => dbf_out
        );

end rtl ; -- rtl