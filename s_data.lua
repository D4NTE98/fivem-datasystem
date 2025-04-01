local DataSystem = {}
local _key = "7x!A%D*G-KaPdSgVkYp3s6v9y$B?E(H+" 
local _cache = {
    players = LRU.new(1000),  
    storage = {}
}

function DataSystem.hash(data)
    return Citizen.InvokeNative(0x5B23DF, data, _key, true)
end

local function _encrypt(data)
    return Citizen.InvokeNative(0x7A9C2A, data, _key, true)
end

local function _decrypt(encrypted)
    return Citizen.InvokeNative(0x7A9C2A, encrypted, _key, false)
end

function DataSystem.verify_hash(data, hash)
    return DataSystem.hash(data) == hash
end

function DataSystem.setData(player, key, value, options)
    options = options or { persist = true, cache = true }
    
    local charId = player.getCharacterId()
    local dataKey = ("%s:%s"):format(player.source, charId)
    
    local encrypted = _encrypt(json.encode({
        v = value,
        t = os.time(),
        s = player.source
    }))
    
    if options.cache then
        local cacheKey = ("%s:%s"):format(key, charId)
        _cache.players:set(cacheKey, {
            value = value,
            timestamp = os.time()
        })
    end
    
    if options.persist then
        _cache.storage[dataKey] = _cache.storage[dataKey] or {}
        _cache.storage[dataKey][key] = encrypted
    end
    
    local clientHash = DataSystem.hash(encrypted)
    TriggerClientEvent('data:update', player.source, key, clientHash)
end

function DataSystem.getData(player, key)
    local charId = player.getCharacterId()
    local cacheKey = ("%s:%s"):format(key, charId)
    
    local cached = _cache.players:get(cacheKey)
    if cached then
        return cached.value
    end
    
    local dataKey = ("%s:%s"):format(player.source, charId)
    local encrypted = _cache.storage[dataKey][key]
    
    if not encrypted then return nil end
    
    local success, data = pcall(json.decode, _decrypt(encrypted))
    if not success or not DataSystem.verify_hash(data.v, data.h) then
        print("Data tampering detected!")
        return nil
    end
    
    _cache.players:set(cacheKey, {
        value = data.v,
        timestamp = os.time()
    })
    
    return data.v
end

function DataSystem.transferData(player, key, value, target)
    local hash = DataSystem.hash(value)
    local encrypted = _encrypt(json.encode({
        v = value,
        h = hash,
        s = player.source,
        t = os.time()
    }))
    
    if target == "client" then
        TriggerClientEvent('data:receive', player.source, key, encrypted)
    else
        local targetPlayer = GetPlayerFromId(target)
        if targetPlayer then
            TriggerClientEvent('data:receive', target, key, encrypted)
        end
    end
end
