--5 by 5
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MedMaze is
    Port (CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  CLK_VGA : out STD_LOGIC;
           HSYNC : out  STD_LOGIC;
           VSYNC : out  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (2 downto 0);
			  KEYN : in STD_LOGIC;
			  KEYE : in STD_LOGIC;
			  KEYS : in STD_LOGIC;
			  KEYW : in STD_LOGIC);
			  
			  
end MedMaze;

architecture Behavioral of MedMaze is

	signal clk25 : std_logic := '0';
	
	constant HD : integer := 639;  --  639   Horizontal Display (640)
	constant HFP : integer := 16;         --   16   Right border (front porch)
	constant HSP : integer := 96;       --   96   Sync pulse (Retrace)
	constant HBP : integer := 48;        --   48   Left boarder (back porch)
	
	constant VD : integer := 479;   --  479   Vertical Display (480)
	constant VFP : integer := 10;       	 --   10   Right border (front porch)
	constant VSP : integer := 2;				 --    2   Sync pulse (Retrace)
	constant VBP : integer := 33;       --   33   Left boarder (back porch)
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	signal x1 : integer := 16;
	signal x2 : integer := 20;
	signal y1 : integer := 16;
	signal y2 : integer := 20;
	signal counter : std_logic_vector(28 downto 0);
	signal CLK_1Hz : std_logic;
	type T_2D is array (250 downto 0, 250 downto 0) of integer;
		signal a : T_2D;
	signal videoOn : std_logic := '0';
	
	
begin


clk_div:process(CLK)
begin
	if(CLK'event and CLK = '1')then
		clk25 <= not clk25;
	end if;
end process;
CLK_VGA <= clk25;
Horizontal_position_counter:process(clk25, RST)
begin
	if(RST = '1')then
		hpos <= 0;
	elsif(clk25'event and clk25 = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			hPos <= 0;
		else
			hPos <= hPos + 1;
		end if;
	end if;
end process;

Vertical_position_counter:process(clk25, RST, hPos)
begin
	if(RST = '1')then
		vPos <= 0;
	elsif(clk25'event and clk25 = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

Horizontal_Synchronisation:process(clk25, RST, hPos)
begin
	if(RST = '1')then
		HSYNC <= '0';
	elsif(clk25'event and clk25 = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			HSYNC <= '1';
		else
			HSYNC <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(clk25, RST, vPos)
begin
	if(RST = '1')then
		VSYNC <= '0';
	elsif(clk25'event and clk25 = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			VSYNC <= '1';
		else
			VSYNC <= '0';
		end if;
	end if;
end process;



video_on:process(clk25, RST, hPos, vPos)
begin
	if(RST = '1')then
		videoOn <= '0';
	elsif(clk25'event and clk25 = '1')then
		if(hPos <= HD and vPos <= VD)then
			videoOn <= '1';
		else
			videoOn <= '0';
		end if;
	end if;
end process;

Prescaler: process (clk25)
begin  -- process Prescaler
	if clk25'event and clk25 = '1' then  -- rising clock edge
		if counter < "1011111010111100001000" then
				counter <= counter + 1;
		else
				CLK_1Hz <= not CLK_1Hz;
				counter <= (others => '0');
		end if;
	end if;
end process Prescaler;

moveBlock:process(CLK_1Hz)
begin

if rising_edge(CLK_1Hz) then
	
	if((KEYS = '1')and (not(a(x1,y2) = 1)) and (not(a(x2,y2) = 1))) then
				y1 <= y1 + 2;
				y2 <= y2 + 2;				
	elsif((KEYN = '1')  and (not(a(x1,y1) = 1)) and (not(a(x2,y1) = 1))) then
				y1 <= y1 - 2;
				y2 <= y2 - 2;	
	elsif((KEYW = '1') and (not(a(x1,y1) = 1)) and (not(a(x1,y2) = 1))) then
				x1 <= x1 - 2;
				x2 <= x2 - 2;  
	elsif((KEYE = '1')   and (not(a(x2,y1) = 1)) and (not(a(x2,y2) = 1))) then
				x1 <= x1 + 2;
				x2 <= x2 + 2;
				end if;
				
	if(RST = '1')then
		x1 <= 16;
		x2 <= 20;
		y1 <= 16;
		y2 <= 20;
	end if;
	
end if;

end process moveBlock;


draw:process(clk25, RST, hPos, vPos, videoOn)
begin
		 if(RST = '1')then
		
		RGB <= "000";
		
	elsif(clk25'event and clk25 = '1')then
	
		if(videoOn = '1')then
		
		
				if((hPos >= 10 and hPos <= 14) AND (vPos >= 10 and vPos <= 205)) then 
					for X in 10 to 14 loop
					for Y in 10 to 205 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 201 and hPos <= 205) AND (vPos >= 10 and vPos <= 205)) then 
					for X in 201 to 205 loop
					for Y in 10 to 205 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 10 and hPos <= 205) AND (vPos >= 10 and vPos <= 14)) then 
					for X in 10 to 205 loop
					for Y in 10 to 14 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 10 and hPos <= 205) AND (vPos >= 201 and vPos <= 205)) then 
					for X in 10 to 205 loop
					for Y in 201 to 205 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 49 and hPos <= 53) AND (vPos >= 14 and vPos <= 53)) then 
					for X in 49 to 53 loop
					for Y in 14 to 53 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 49 and hPos <= 170) AND (vPos >= 49 and vPos <= 53)) then 
					for X in 49 to 170 loop
					for Y in 49 to 53 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 49 and hPos <= 53) AND (vPos >= 88 and vPos <= 170)) then 
					for X in 49 to 53 loop
					for Y in 88 to 170 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 88 and hPos <= 131) AND (vPos >= 88 and vPos <= 92)) then 
					for X in 88 to 131 loop
					for Y in 88 to 92 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 88 and hPos <= 92) AND (vPos >= 88 and vPos <= 131)) then 
					for X in 88 to 92 loop
					for Y in 88 to 131 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 49 and hPos <= 170) AND (vPos >= 166 and vPos <= 170)) then 
					for X in 49 to 170 loop
					for Y in 166 to 170 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				
				
				elsif((hPos >= 88 and hPos <= 170) AND (vPos >= 127 and vPos <= 131)) then 
					for X in 88 to 170 loop
					for Y in 127 to 131 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 166 and hPos <= 170) AND (vPos >= 49 and vPos <= 131)) then 
					for X in 166 to 170 loop
					for Y in 49 to 131 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif((hPos >= 166 and hPos <= 170) AND (vPos >= 166 and vPos <= 205)) then 
					for X in 166 to 170 loop
					for Y in 166 to 205 loop
						a(X,Y) <= 1;
					end loop;
					end loop;
				RGB <= "010";
				
				elsif ((hPos >= x1 and hPos <= x2) AND (vPos >= y1 and vPos <= y2)) then 
				RGB <= "100";
				
				elsif((hPos >= 185 and hPos <= 204) AND (vPos >= 185 and vPos <= 204))then		-- win condition
				for X in 185 to 204 loop
				for Y in 185 to 204 loop
					a(X,Y) <= 2;
				end loop;
				end loop;
				RGB <= "110";
				 
				
				
				else
					RGB <= "000";
					end if;
				
				
				if  (a(x2,y2) = 2) then 
					if (((hPos >= 240 and hPos <= 250) AND (vPos >= 240 and vPos <= 250)) or 
						  ((hPos >= 300 and hPos <= 310)and(vPos >= 240 and vPos <= 250)) or
						  ((hPos >= 230 and hPos <= 320)and(vPos >= 260 and vPos <= 264)) or
						  ((hPos >= 230 and hPos <= 240)and(vPos >= 254 and vPos <= 260)) or
						  ((hPos >= 310 and hPos <= 320)and(vPos >= 254 and vPos <= 260)))then
						RGB <= "011";
						
					
						else 
					RGB <= "000";
					end if;
					end if;	
					end if;
					

end if;

end process;

end Behavioral;
