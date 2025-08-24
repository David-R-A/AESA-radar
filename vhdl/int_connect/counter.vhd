library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic (
        WIDTH : integer := 4  -- ancho del contador en bits
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;  -- reset síncrono
        en    : in  std_logic;  -- habilitación
        count : out std_logic_vector(WIDTH-1 downto 0)
    );
end counter;

architecture rtl of counter is
    signal count_reg : unsigned(WIDTH-1 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_reg <= (others => '0');
            elsif en = '1' then
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;

    count <= std_logic_vector(count_reg);

end architecture;
