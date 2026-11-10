

library ieee;
use ieee.std_logic_1164.all;

entity serialiser is
  port (
    i_rst		: in	std_logic;
    i_clk		: in	std_logic;
    i_enb		: in    std_logic;
    i_data		: in 	std_logic_vector(7 downto 0);
    o_serial_clk	: out	std_logic;
    o_serial_data	: out	std_logic;
    o_serial_eob	: out	std_logic
  );
end serialiser;


architecture rtl of serialiser is
  signal r_data		: std_logic_vector(7 downto 0);

  type	 t_SM_state is (s_START, s_SHIFTING, s_EOB);
  signal r_state	: t_SM_state;

  signal r_so_i	: integer range 0 to 9; -- shift out iterator count

  -- internal output signals
  signal r_serial_clk_active	: std_logic;
  signal r_serial_out		: std_logic;
  signal r_eob_out		: std_logic;


begin
  p_SERIALISE : process (i_clk)
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
	r_data <= (others => '0');
        r_serial_clk_active <= '0';
        r_serial_out <= '0';
        r_eob_out <= '0';
        r_state <= s_START;
        r_so_i <= 0;
        
      elsif i_enb = '1' then
        case r_state is
          when s_START=>
            r_data <= i_data;
            r_serial_clk_active <= '0';
            r_serial_out <= '0';
            r_eob_out <= '0';
            r_so_i <= 0;
            r_state <= s_SHIFTING;   

          when s_SHIFTING =>
            r_serial_clk_active <= '1';
            r_eob_out <= '0';
            r_serial_out <= r_data(7 - r_so_i);
            r_so_i <= r_so_i + 1;
            if r_so_i > 6 then
              r_state <= s_EOB;
            end if;

          when s_EOB =>
            r_data <= i_data;
            r_eob_out <= '1';
            r_serial_clk_active <= '0';
            r_serial_out <= '0';
            r_so_i <= 0;
            r_state <= s_SHIFTING;

          when others =>
            r_state <= s_START;
        end case;
      end if;
    end if;

  end process p_SERIALISE;
    
    o_serial_clk <= (not i_clk) when r_serial_clk_active = '1' else '0';
    o_serial_data <= r_serial_out;
    o_serial_eob <= r_eob_out;    
      
end rtl;
