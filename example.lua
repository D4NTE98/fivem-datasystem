RegisterNetEvent('playerLoaded', function(playerId)
    local player = ESX.GetPlayerFromId(playerId)
    exports.fivem-datasystem:setData(player, 'bank', 5000, { persist = true })
end)
