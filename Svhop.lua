--=============================================================================

--=============================================================================
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local module = {}


local visitedServers = {}
local cursor = nil
local hopping = false
local currentPlaceId = nil


local REQUEST_DELAY = 1.5   
local TELEPORT_DELAY = 2.5  
local REFRESH_INTERVAL = 300 

local lastRefresh = os.clock()


local function safeJSONDecode(str)
    local success, result = pcall(HttpService.JSONDecode, HttpService, str)
    if success then
        return result
    else
        warn("[ADMINUS] - JSON decode basarisiz.")
        return nil
    end
end


local function getServers(placeId)
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not response then
        warn("[ADMINUS] - Sunucu listesi API'den cekilemedi.")
        task.wait(REQUEST_DELAY)
        return nil
    end

    return safeJSONDecode(response)
end


local function hop(placeId)
    if hopping then
        print("[ADMINUS] - Zaten isinlanma sirasindasiniz, tekrar tetikleme engellendi.")
        return
    end

    hopping = true
    currentPlaceId = placeId


    if game.JobId and game.JobId ~= "" then
        visitedServers[game.JobId] = true
    end

    while hopping do
        task.wait(REQUEST_DELAY)

       
        if os.clock() - lastRefresh > REFRESH_INTERVAL then
            cursor = nil
            visitedServers = {}
            lastRefresh = os.clock()
            print("[ADMINUS] - Sunucu hafizasi temizlendi.")
        end

        local data = getServers(placeId)
        if not data or not data.data then continue end

        cursor = data.nextPageCursor

        for _, server in ipairs(data.data) do
            
            if server.playing and server.maxPlayers and server.playing < server.maxPlayers and not server.accessCode then
                local id = server.id

                if not visitedServers[id] then
                    visitedServers[id] = true
                    print("[ADMINUS] - Yeni sunucuya gidiliyor: ", id)

                    local success = pcall(function()
                        TeleportService:TeleportToPlaceInstance(placeId, id, player)
                    end)

                    if success then
                        hopping = false
                        return
                    end

                    task.wait(TELEPORT_DELAY)
                end
            end
        end

       
        if not cursor then
            cursor = nil
        end
    end
end


TeleportService.TeleportInitFailed:Connect(function(plr, result)
    if plr ~= player then return end

    warn("[ADMINUS] - Isinlanma hatasi: ", tostring(result))

    if currentPlaceId then
        hopping = false
        task.wait(2)
        module.Teleport(module, currentPlaceId) 
    end
end)


function module:Teleport(placeId)
    hop(placeId)
end

return module
