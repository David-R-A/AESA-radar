-- ==========================================================
-- File              : fDBF.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-13
-- Last modified     : 2025-05-13
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : DBF Top module
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > fPC :: Range CpxData -- ^ input range bin     
-- >     -> Range CpxData -- ^ output pulse-compressed bin
-- > fPC = mav (mkPcCoefs 5)
--
-- ==== </ HASKELL CODE > =======================================

-- The module implementes the ```fDBF``` function

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;
use work.params_pkg.all; 

-- Using ForSyDe.Atom.Skel.Vector.DSP adapte to work with ForSyDe-Shallow instructions
-- https://forsyde.github.io/forsyde-atom/api/src/ForSyDe.Atom.Skel.Vector.DSP.html#fir
-- fir

entity fPC is -- Actually implementing 'fir'
    port (
        ranges : in  complex_int_vector(0 to nbin-1); -- Input ranges vector
        fPC_o  : out complex_int_vector(0 to nbin-1)         
    );
end fPC;

architecture rtl of fPC is

    component pc_mav is -- Update entity name on instantation
        port (
            ranges : in  complex_int_vector(0 to nbin-1);  -- Output vector
            mav_o  : out complex_int_vector(0 to nbin-1)
            -- Length of <a_vector> = <a>'length + 1     
        );
    end component pc_mav;

begin

    mav_f : pc_mav
    port map(
        ranges => ranges,
        mav_o  => fPC_o
    );

end rtl ; -- rtl