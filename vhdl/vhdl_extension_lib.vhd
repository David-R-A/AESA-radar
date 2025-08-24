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
    function unary_or (slv : std_logic_vector) return std_logic;
end package vhdl_extension_lib;

package body vhdl_extension_lib is

    -- ============================================================================
    --  Function:    unary_and
    --  Description: Performs a bitwise AND reduction on the input std_logic_vector.
    --               Returns '1' if all bits in the vector are '1', otherwise returns '0'.
    --               If the input vector is empty, the function returns '1'.
    --  Arguments:
    --      slv : std_logic_vector
    --          The input vector to be reduced using AND operation.
    --  Returns:
    --      std_logic
    --          The result of the AND reduction ('1' if all bits are '1', else '0').
    -- ============================================================================
    function unary_and(slv : std_logic_vector) return std_logic is
        variable res_v : std_logic := '1';  -- Null slv vector will also return '1'
    begin
        for i in slv'range loop
            res_v := res_v and slv(i);
        end loop;
        return res_v;
    end function unary_and;

    -- ============================================================================
    --  Function:    unary_or
    --  Description: Performs a bitwise OR reduction on the input std_logic_vector.
    --               Returns '1' if any bit in the vector is '1', otherwise returns '0'.
    --               If the input vector is empty, the function returns '0'.
    --  Arguments:
    --      slv : std_logic_vector
    --          The input vector to be reduced using OR operation.
    --  Returns:
    --      std_logic
    --          The result of the OR reduction ('1' if any bit is '1', else '0').
    -- ============================================================================
    function unary_or(slv : std_logic_vector) return std_logic is
        variable res_v : std_logic := '0';  -- Null slv vector will also return '0'
    begin
        for i in slv'range loop
            res_v := res_v or slv(i);
        end loop;
        return res_v;
    end function unary_or;
end package body vhdl_extension_lib;

