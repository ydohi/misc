----------------------------------------------------------------------------------
--Copyright (C) 2020 by DOHI, Yutaka <dohi@bedesign.jp>
--
--Permission to use, copy, modify, and/or distribute this software for any purpose
--with or without fee is hereby granted.
--
--THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
--REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
--FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
--INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
--OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
--TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
--THIS SOFTWARE.
----------------------------------------------------------------------------------
--(Zero Clause BSD license)

--Pseudo-Random Binary Sequence generator
--INIT_VALUE enables to change sequence start point. usually needless then stay at default. never set all '0'

library ieee;
use ieee.std_logic_1164.all;

entity prbs_gen is
    generic (
        -- choose one of following..can use any other polynomial if necessary
        -- see "Linear-feedback shift register" section in wikipedia for available polynomial
        -- also see ITU-T O.150/O.151/O.152/O.153
--        POLYNOMIAL  : std_logic_vector( 3 downto 1) := ( 3 => '1',  2 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector( 4 downto 1) := ( 4 => '1',  3 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector( 5 downto 1) := ( 5 => '1',  3 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector( 6 downto 1) := ( 6 => '1',  5 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector( 7 downto 1) := ( 7 => '1',  6 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector( 8 downto 1) := ( 8 => '1',  6 => '1',  5 => '1',  4 => '1', others => '0')
        POLYNOMIAL  : std_logic_vector( 9 downto 1) := ( 9 => '1',  5 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector(10 downto 1) := (10 => '1',  7 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector(11 downto 1) := (11 => '1',  9 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector(15 downto 1) := (15 => '1', 14 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector(20 downto 1) := (20 => '1', 17 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector(20 downto 1) := (20 => '1',  3 => '1', others => '0')    -- another virsion of PRBS20
--        POLYNOMIAL  : std_logic_vector(23 downto 1) := (23 => '1', 18 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector(29 downto 1) := (29 => '1', 27 => '1', others => '0')
--        POLYNOMIAL  : std_logic_vector(31 downto 1) := (31 => '1', 28 => '1', others => '0')
    );
    port (
        CLK         : in    std_logic;          -- base clock
        RESETn      : in    std_logic;          -- async reset
        INIT_SR     : in    std_logic := '0';   -- initial shift reg.
        INIT_VALUE  : in    std_logic_vector(POLYNOMIAL'high downto POLYNOMIAL'low) := (others => '1');
        ENB         : in    std_logic;          -- shift enable
        PRBS        : out   std_logic
    );
end prbs_gen;

    
architecture RTL of prbs_gen is

    -- linear feedback shift register
    signal  LFSR        : std_logic_vector(POLYNOMIAL'high downto POLYNOMIAL'low);

begin

    process (CLK, RESETn)
    begin
        if (RESETn = '0') then
            LFSR <= (others => '1');
        elsif (rising_edge(CLK)) then
            if (INIT_SR = '1') then
                LFSR <= INIT_VALUE;
            elsif (ENB = '1') then
                for i in POLYNOMIAL'low to POLYNOMIAL'high loop
                    if (i = POLYNOMIAL'high) then
                        LFSR(i) <= LFSR(POLYNOMIAL'low);
                    else
                        LFSR(i) <= LFSR(i+1) xor (POLYNOMIAL(i) and LFSR(POLYNOMIAL'low));
                    end if;
                end loop;
            end if;
        end if;
    end process;

    PRBS <= LFSR(POLYNOMIAL'low);

end RTL;
