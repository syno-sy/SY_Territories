QBCore = nil
Framework = Config.Framework

if Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    Wait(100)
    TriggerEvent('SY_Territories:Client:loadInfluenceUi')
end)


function Notification()

end
