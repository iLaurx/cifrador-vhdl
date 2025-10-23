library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cifrador_lfsr is
end tb_cifrador_lfsr;

architecture sim of tb_cifrador_lfsr is
    constant N : integer := 128;

    signal clk, reset, start_cif, start_des : std_logic := '0';
    signal clave_in : std_logic_vector(15 downto 0);
    signal mensaje_in, cifrado_out, descifrado_out : std_logic_vector(N-1 downto 0);
    signal listo_cif, listo_des : std_logic;

    constant clk_period : time := 10 ns;

begin

    -- CIFRADOR
    C1: entity work.cifrador_lfsr
        generic map(N => N)
        port map(
            clk         => clk,
            reset       => reset,
            start       => start_cif,
            clave_in    => clave_in,
            mensaje_in  => mensaje_in,
            cifrado_out => cifrado_out,
            listo       => listo_cif
        );

    -- DESCIFRADOR (mismo módulo)
    D1: entity work.cifrador_lfsr
        generic map(N => N)
        port map(
            clk         => clk,
            reset       => reset,
            start       => start_des,
            clave_in    => clave_in,
            mensaje_in  => cifrado_out,
            cifrado_out => descifrado_out,
            listo       => listo_des
        );

    -- Reloj
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Estímulos
    stim_proc: process
        variable mensaje_ascii : string(1 to 16) := "HELLO_WORLD_1234";
        variable i : integer;
        variable ascii_val : integer;
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;

        clave_in <= x"1A2B";

        -- Cargar mensaje
        for i in 1 to 16 loop
            ascii_val := character'pos(mensaje_ascii(i));
            mensaje_in(8*(i-1)+7 downto 8*(i-1)) <= std_logic_vector(to_unsigned(ascii_val, 8));
        end loop;

        -- Inicia cifrado
        start_cif <= '1';
        wait for clk_period;
        start_cif <= '0';
        wait until listo_cif = '1';

        report "CIFRADO COMPLETADO";

        -- Inicia descifrado
        start_des <= '1';
        wait for clk_period;
        start_des <= '0';
        wait until listo_des = '1';

        report "DESCIFRADO COMPLETADO";

        wait;
    end process;

end sim;