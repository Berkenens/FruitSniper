-- ServerHop Module (Optimized)
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local module = {}

-- State
local visitedServers = {}
local cursor = nil
local hopping = false
local currentPlaceId = nil
local teleportPending = false

-- Config
local REQUEST_DELAY    = 1.5
local TELEPORT_DELAY   = 3
local REFRESH_INTERVAL = 15
local lastRefresh      = 0

-- Safe JSON decode
local function safeJSONDecode(str)
    local ok, result = pcall(HttpService.JSONDecode, HttpService, str)
    if ok then return result end
    warn("[SNIPER] JSON decode hatasi")
    return nil
end

-- Sunucu listesini cek
local function getServers(placeId)
    local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. cursor
    end

    local ok, response = pcall(game.HttpGet, game, url)
    if not ok or not response then
        warn("[SNIPER] HTTP istegi basarisiz")
        task.wait(REQUEST_DELAY)
        return nil
    end

    return safeJSONDecode(response)
end

-- Asil hop dongusu
local function hopLoop(placeId)
    hopping      = true
    teleportPending = false
    currentPlaceId  = placeId

    while hopping do
        task.wait(REQUEST_DELAY)

        -- Belirli aralikta cache temizle
        if tick() - lastRefresh > REFRESH_INTERVAL then
            cursor        = nil
            visitedServers = {}
            lastRefresh   = tick()
            print("[SNIPER] Sunucu listesi yenilendi")
        end

        local data = getServers(placeId)
        if not data or not data.data then continue end

        cursor = data.nextPageCursor or ""

        for _, server in ipairs(data.data) do
            -- Dolu olmayan, ozel olmayan, ziyaret edilmemis sunucuyu sec
            if  server.playing < server.maxPlayers
            and not server.accessCode
            and not visitedServers[server.id]
            then
                visitedServers[server.id] = true
                print("[SNIPER] Sunucuya atlanıyor:", server.id)

                teleportPending = true
                local ok = pcall(
                    TeleportService.TeleportToPlaceInstance,
                    TeleportService, placeId, server.id, player
                )

                if ok then
                    -- Teleport istegi gonderildi, confirm bekle
                    task.wait(TELEPORT_DELAY)
                    if teleportPending then
                        -- Teleport gelmedi, devam et
                        teleportPending = false
                        warn("[SNIPER] Teleport yanitlanmadi, baska sunucu deneniyor")
                    else
                        hopping = false
                        return
                    end
                else
                    teleportPending = false
                    warn("[SNIPER] TeleportToPlaceInstance cagrisi basarisiz")
                    task.wait(TELEPORT_DELAY)
                end
            end
        end

        -- Tüm sayfa bitti, cursor yoksa bastan baslat
        if cursor == "" or cursor == nil then
            cursor        = nil
            visitedServers = {}
            print("[SNIPER] Tüm sunucular denendi, bastan baslanıyor")
        end
    end
end

-- Teleport basari olayi
TeleportService.TeleportInitFailed:Connect(function(plr, result)
    if plr ~= player then return end
    warn("[SNIPER] Teleport basarisiz:", result.Name)
    teleportPending = false

    if currentPlaceId and hopping then
        task.wait(2)
        -- Zaten dongu devam ediyor, mudahale etme
    end
end)

-- Public API
function module:Teleport(placeId)
    if hopping then
        warn("[SNIPER] Zaten sunucu atlaniyor")
        return
    end
    task.spawn(hopLoop, placeId)
end

function module:Stop()
    hopping = false
    currentPlaceId = nil
    cursor = nil
    visitedServers = {}
    print("[SNIPER] ServerHop durduruldu")
end

return module
