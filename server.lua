ESX = exports["es_extended"]:getSharedObject()
local pemainAFK = {}

-- Event names
local Events = {
    setAFK = 'bel-afk:setAFK',
    getAFKStatus = 'bel-afk:getAFKStatus',
    getSharedObject = 'esx:getSharedObject'
}

-- Event ketika pemain mengatur status AFK
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

-- Hapus pemain dari daftar AFK ketika mereka keluar
AddEventHandler('playerDropped', function()
    local _source = source
    if pemainAFK[_source] then
        pemainAFK[_source] = nil
    end
end)

-- Dapatkan status AFK dari pemain
ESX.RegisterServerCallback(Events.getAFKStatus, function(source, cb, target)
    cb(pemainAFK[target] == true)
end) 