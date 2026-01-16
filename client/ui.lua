-- Client UI Functions


function ShowUI(arg, data)
    -- SetNuiFocus(arg, arg)
    SendNUIMessage({
        action = 'setVisible',
        data = arg,
    })
    SendNUIMessage({
        action = 'setUiData',
        data = data
    })
end

RegisterNUICallback('hide-ui', function(_, cb)
    OpenNui(false)
    cb({})
end)

RegisterNUICallback('getConfig', function(_, cb)
    cb({
        primaryColor = Config.PrimaryColor,
        primaryShade = Config.PrimaryShade
    })
end)
