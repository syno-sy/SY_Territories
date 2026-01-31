# SY_Territories V3.0

# Stable But WIP

# INFO
Territories will aim to provide gangs with "zones" to control.
Each zone will be controlled by influencing the area through various activites, including:
  - Killing other gang members.

The gang that controls the area will have access to the zones resources.


[def]: "https://youtu.be/TnzAuyMVpg8"

![SY_TerritoriesV3](./imgs/img1.png)
![SY_TerritoriesV3](./imgs/img2.png)
![SY_TerritoriesV3](./imgs/img3.png)



# Exports
```lua
-- Use it for other gang jobs for handling and accessing the job
local ZoneName = "eastv"
local zoneData = exports["SY_Territories"]:GetZoneData(ZoneName)
if not zoneData or not QBCore.Functions.GetPlayerData().gang then
    return
end
local canAccessZone = (zoneData.gang == QBCore.Functions.GetPlayerData().gang.name)
if canAccessZone then
    if IsControlJustReleased(0, 38) then
        --    Logic
        return
    end
else
    -- Logic for non-access
    return
end
```



