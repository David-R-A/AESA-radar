-- ==========================================================
-- File              : vhdl_extension.vhd
-- Author            : David Ramón Alamán
-- Project           : Master's Thesis - Design of a Hardware Architecture for Parallel AESA Radar Signal Processing
-- Created on        : 2025-05-29
-- Last modified     : 2025-06-10
-- University        : KTH - Royal Institute of Technology
-- 
-- Description       : VHDL93 extension library
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vhdl_extension_lib is
    function unary_and(slv : std_logic_vector) return std_logic;
end package vhdl_extension_lib;

package body vhdl_extension_lib is
    function unary_and(slv : std_logic_vector) return std_logic is
        variable res_v : std_logic := '1';  -- Null slv vector will also return '1'
    begin
        for i in slv'range loop
            res_v := res_v and slv(i);
        end loop;
        return res_v;
    end function unary_and;
end package body vhdl_extension_lib;