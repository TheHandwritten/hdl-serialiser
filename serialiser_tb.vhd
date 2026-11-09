library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serialiser_tb is
end serialiser_tb;

architecture behave of serialiser_tb is
  component serialiser is
    port (
      i_rst		: in	std_logic;
      i_clk		: in	std_logic;
      i_enb		: in    std_logic;
      i_data		: in 	std_logic_vector(7 downto 0);
      o_serial_clk	: out	std_logic;
      o_serial_data	: out	std_logic;
      o_serial_eob	: out	std_logic
    );
  end component serialiser;

  signal r_clk		: std_logic := '0';
  signal r_rst		: std_logic := '0';
  signal r_enb		: std_logic := '0';
  signal r_data		: std_logic_vector(7 downto 0) := (others => '0');
  signal w_srl_clk	: std_logic;
  signal w_srl_data	: std_logic;
  signal w_srl_eob	: std_logic; 

begin
  r_clk <= not r_clk after 500 ns;

  -- Instantiate serialiser
  SERIALISER_INST : serialiser
    port map (
      i_clk		=> r_clk,
      i_rst		=> r_rst,
      i_enb		=> r_enb,
      i_data		=> r_data,
      o_serial_clk	=> w_srl_clk,
      o_serial_data	=> w_srl_data,
      o_serial_eob	=> w_srl_eob
    );

  process is

  procedure TEST_SERIAL_OUT (
    r_t_data	: in std_logic_vector(7 downto 0)
    ) is
  begin
    r_data <= r_t_data;

    for ii in 0 to 7 loop
      wait until rising_edge(w_srl_clk);
      assert w_srl_data = r_data(7-ii)
        report "Output bit error";
    end loop;

    wait until w_srl_eob = '1';

  end procedure;

  begin

    r_rst <= '1';

    wait until rising_edge(r_clk);
    wait until rising_edge(r_clk);

    r_rst <= '0';
    r_enb <= '1';

    for jj in 0 to 255 loop
      report "Testing input:" & integer'image(jj);
      TEST_SERIAL_OUT(std_logic_vector(to_unsigned(jj,8)));
    end loop;
    wait;

  end process;
end behave;
