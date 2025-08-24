-- ==========================================================
-- File              : reverseV.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-15
-- Last modified     : 2025-05-15
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : ForSyDe-Shallow reverseV implementation template
-- ==========================================================

-- ==== < HASKELL CODE > ======================================
--
-- > -- | The function 'reverseV' reverses the order of elements in a vector. 
-- > reverseV  :: Vector a -> Vector a
-- > reverseV NullV   = NullV
-- > reverseV (v:>vs) = Vector a -> Vector a
--
-- ==== </ HASKELL CODE > =======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.devkit_lib.all;

entity <reverseV> is
    port (
        <a>         : in  <a_type>;
        <a_reverse> : out <a_type>
    );
end <reverseV>;

architecture rtl of <reverseV> is
begin

    process (<a>)
    begin
        for i in 0 to <a>'length-1 loop
            <a_reverse>(i) <= <a>(<a>'length-1-i);
        end loop;
    end process;
    
end rtl;