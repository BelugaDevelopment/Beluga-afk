ESX = exports["es_extended"]:getSharedObject()
local pemainAFK = {}

local Events = {
    setAFK = 'bel-afk:setAFK',
    getAFKStatus = 'bel-afk:getAFKStatus',
    getSharedObject = 'esx:getSharedObject'
}

RegisterServerEvent(Events.setAFK)
AddEventHandler(Events.setAFK, function(status)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if xPlayer then
        if status then
            pemainAFK[_source] = true
            TriggerClientEvent('esx:showNotification', -1, GetPlayerName(_source) .. " sedang dalam mode AFK")
        else
            pemainAFK[_source] = nil
            TriggerClientEvent('esx:showNotification', -1, GetPlayerName(_source) .. " telah kembali dari AFK")
        end
    end
end)

AddEventHandler('playerDropped', function()
    local _source = source
    if pemainAFK[_source] then
        pemainAFK[_source] = nil
    end
end)

ESX.RegisterServerCallback(Events.getAFKStatus, function(source, cb, target)
    cb(pemainAFK[target] == true)
end) 
