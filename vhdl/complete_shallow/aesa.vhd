library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity aesa is
    port (
        -- Signal (Antenna (Window (Range CpxData)))
        video : in  input_cube(0 to nA-1); -- Input antenna vector
        -- Signal (Window  (Range  (Beam  CpxData)))    
        oPc   : out output_cube(0 to nFFT-1) -- Output beam vector        
    );
end aesa;

architecture rtl of aesa is

    signal dbf_out_i : dbf_out_cube(0 to nFFT-1);

    component dbf is
        port (
            dbf_in  : in  input_cube(0 to nA-1); -- Input  vector a 
            dbf_out : out dbf_out_cube(0 to nFFT-1)  -- Output vector b
        );
    end component dbf;

    component pc is 
        port (
            pc_in  : in  dbf_out_cube(0 to nFFT-1);
            pc_out : out output_cube(0 to nFFT-1)
        );
    end component pc;

begin

    dbf_f : dbf
    port map(
        dbf_in  => video,
        dbf_out => dbf_out_i
    );

    pc_f : pc
    port map(
        pc_in  => dbf_out_i,
        pc_out => oPc
    );

end rtl;