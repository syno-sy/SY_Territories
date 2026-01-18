<!-- How To -->

``` lua
-- qb-ambulancejob/server.lua
RegisterNetEvent('hospital:server:SetLaststandStatus', function(bool)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData('inlaststand', bool)
		TriggerEvent("SY_Territories:Server:OnPlayerDead", src)
	end
end)
```


start war through ui
- options 
  - zone
  - defender
  - attacker
  - time
- click confirm
  - 30 sec cool off time (ui should show)
  - if influence of the defender not 100 then set it to 100 
  - war started announcement after 30sec cool off time
  - get the total member from defender and attacker then from the total if any player dead while on war in the ui it should show like dead member gang total-1.
  - show ui when inside the zone.
  - update timer frequently.
  - 