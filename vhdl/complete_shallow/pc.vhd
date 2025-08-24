-- ==========================================================
-- File              : pc.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-29
-- Last modified     : 2025-06-10
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : PC function top-level module
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > pc :: Signal (Window (Range (Beam  CpxData))) 
-- >    -> Signal (Window (Beam  (Range CpxData)))
-- > pc = combSY (mapV (mapV fPC . transposeMat))
-- > 
-- > fPC :: Range CpxData -- ^ input range bin     
-- >     -> Range CpxData -- ^ output pulse-compressed bin
-- > fPC = mav (mkPcCoefs 5)
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity pc is
    port (
        pc_in  : in  dbf_out_cube(0 to nFFT-1);
        pc_out : out output_cube(0 to nFFT-1)
    );
end pc;

architecture rtl of pc is

    component pc_combSY is
        port(
            a : in  dbf_out_cube(0 to nFFT-1);
            b : out output_cube(0 to nFFT-1)
        );
    end component pc_combSY;

begin 

    pc_combSY_f : pc_combSY
        port map(
            a => pc_in,
            b => pc_out
        );

end rtl;