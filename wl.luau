local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local whitelisted = {
 "greguiscool", 
}

if not table.find(whitelisted, LocalPlayer.Name) then
   LocalPlayer:Kick("Spunchbub says: not whitelisted you S-K-I-D")
end
