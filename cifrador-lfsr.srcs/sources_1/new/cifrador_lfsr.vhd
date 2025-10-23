library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cifrador_lfsr is
    generic (
        N : integer := 128  -- número de bits del mensaje
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        start       : in  std_logic;
        clave_in    : in  std_logic_vector(15 downto 0);   -- semilla del LFSR
        mensaje_in  : in  std_logic_vector(N-1 downto 0);  -- mensaje a cifrar
        cifrado_out : out std_logic_vector(N-1 downto 0);  -- mensaje cifrado
        listo       : out std_logic
    );
end cifrador_lfsr;

architecture Behavioral of cifrador_lfsr is
    type state_type is (IDLE, BUSY, DONE);
    signal estado      : state_type := IDLE;
    signal lfsr_reg    : std_logic_vector(15 downto 0);
    signal msg_reg     : std_logic_vector(N-1 downto 0);
    signal out_reg     : std_logic_vector(N-1 downto 0) := (others => '0');
    signal bit_idx     : integer range 0 to N := 0;
begin

    process(clk, reset)
        variable feedback : std_logic;
    begin
        if reset = '1' then
            estado   <= IDLE;
            lfsr_reg <= (others => '0');
            msg_reg  <= (others => '0');
            out_reg  <= (others => '0');
            bit_idx  <= 0;
            listo    <= '0';

        elsif rising_edge(clk) then
            case estado is

                ----------------------------------------------------------------
                -- ESTADO: IDLE
                ----------------------------------------------------------------
                when IDLE =>
                    listo <= '0';
                    if start = '1' then
                        lfsr_reg <= clave_in;       -- inicializa con la clave
                        msg_reg  <= mensaje_in;
                        bit_idx  <= 0;
                        estado   <= BUSY;
                    end if;

                ----------------------------------------------------------------
                -- ESTADO: BUSY
                ----------------------------------------------------------------
                when BUSY =>
                    -- Generar el bit de retroalimentación (polinomio de 16 bits)
                    -- Ejemplo de polinomio: x^16 + x^14 + x^13 + x^11 + 1
                    feedback := lfsr_reg(15) xor lfsr_reg(13) xor lfsr_reg(12) xor lfsr_reg(10);

                    -- Cifrar bit a bit (XOR entre mensaje y bit LFSR)
                    out_reg(bit_idx) <= msg_reg(bit_idx) xor lfsr_reg(0);

                    -- Desplazar el LFSR
                    lfsr_reg <= feedback & lfsr_reg(15 downto 1);

                    -- Avanzar índice
                    if bit_idx = N-1 then
                        estado <= DONE;
                    else
                        bit_idx <= bit_idx + 1;
                    end if;

                ----------------------------------------------------------------
                -- ESTADO: DONE
                ----------------------------------------------------------------
                when DONE =>
                    listo <= '1';
                    estado <= IDLE;
            end case;
        end if;
    end process;

    cifrado_out <= out_reg;

end Behavioral;