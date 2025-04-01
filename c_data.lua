local ClientData = {}
local _clientCache = LRU.new(500)
local _pendingRequests = {}

function ClientData.get(key)
    local cacheItem = _clientCache:get(key)
    if cacheItem then
        if os.time() - cacheItem.t < 300 then
            return cacheItem.v
        end
    end
    TriggerServerEvent('data:request', key)
    return nil
end

RegisterNetEvent('data:update', function(key, hash)
    _pendingRequests[key] = hash
end)

RegisterNetEvent('data:receive', function(key, encrypted)
    Citizen.CreateThreadNow(function()
        local hash = _pendingRequests[key]
        if not hash then return end
        
        TriggerServerEvent('data:verify', key, hash, function(valid)
            if valid then
                local success, data = pcall(json.decode, encrypted)
                if success then
                    _clientCache:set(key, {
                        v = data.v,
                        t = os.time()
                    })
                end
            end
        end)
    end)
end)

exports('setData', function(key, value)
    TriggerServerEvent('data:set', key, value)
end)

exports('getData', function(key)
    return ClientData.get(key)
end)

exports('transferData', function(key, value, target)
    TriggerServerEvent('data:transfer', key, value, target)
end)
