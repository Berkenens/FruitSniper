--[[
    Fruit Sniper - Optimize Edilmis Versiyon
    - Otomatik fruit arama ve store
    - ServerHop entegrasyonu
    - ESP sistemi
    - Sadece izin verilen fruitler alinir
--]]

-- ============================================================
--  AYARLAR
-- ============================================================
local SETTINGS = {
    Team = "Pirates",   -- "Pirates" veya "Marines"

    -- true = al, false / yok = alma
    Fruits = {
        ["Tiger Fruit"]     = true,
        ["Kitsune Fruit"]   = true,
        ["Dragon Fruit"]    = true,
        ["Lightning Fruit"] = true,
        ["Yeti Fruit"]      = true,
        ["Control Fruit"]   = true,
        ["Venom Fruit"]     = true,
        ["Dough Fruit"]     = true,
        ["Gas Fruit"]       = true,
    },

    TweenSpeed      = 300,  -- Karakter hizi (stud/sn)
    EnableESP       = true, -- Fruit etiketleri
    StoreDelay      = 0.8,  -- Store sonrasi bekleme
    ScanInterval    = 1.2,  -- Fruit tarama sikligı
    HopDelay        = 2,    -- Server hop oncesi bekleme
}

-- ============================================================
--  SERVISLER
-- ============================================================
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")

-- ============================================================
--  PLAYER / CHARACTER
-- ============================================================
local Player    = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP       = Character:WaitForChild("HumanoidRootPart")
local Humanoid  = Character:WaitForChild("Humanoid")

-- Karakter respawn oldugunda guncelle
Player.CharacterAdded:Connect(function(char)
    Character = char
    HRP       = char:WaitForChild("HumanoidRootPart")
    Humanoid  = char:WaitForChild("Humanoid")
end)

-- ============================================================
--  REMOTE
-- ============================================================
local CommF = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("CommF_")

-- ============================================================
--  UI (ui.txt'den yuklenir)
-- ============================================================
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/flerci42/Adminus_FruitSniper_V2/refs/heads/main/GraphicalUserInterface.lua"
))()

local StatusLabel   = UI.Status
local TweenLabel    = UI.TweenStatus
local StoreLabel    = UI.StoringStatus
local FruitTypeLbl  = UI.FruitType
local DistanceLabel = UI.FruitDistance

-- ============================================================
--  SERVER HOP (bir kez yukle, her hopda tekrar loadstring yapma)
-- ============================================================
local ServerHop = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Berkenens/whitelist/refs/heads/main/Svhop.lua"
))()

-- ============================================================
--  TAKIM AYARLA
-- ============================================================
local function setTeam()
    pcall(function()
        CommF:InvokeServer("SetTeam", SETTINGS.Team)
    end)
end
setTeam()

-- ============================================================
--  YARDIMCI FONKSIYONLAR
-- ============================================================

-- Zengin metin ile etiket guncelle
local function setLabel(label, key, value, color)
    label.Text = ('%s: <font color="rgb(%s)" weight="Regular">%s</font>')
        :format(key, color, value)
end

-- Fruit mi?
local function isFruit(obj)
    return obj:IsA("Tool")
        and obj:FindFirstChild("Handle")
        and obj.Name:find("Fruit")
end

-- Izin verilen fruit mi?
local function isAllowed(fruitName)
    return SETTINGS.Fruits[fruitName] == true
end

-- Karakter hayatta mi?
local function isAlive()
    return Character
        and Humanoid
        and Humanoid.Health > 0
end

-- Workspace'te (ve alt objelerde) tum fruitleri bul
local function getAllFruits()
    local fruits = {}
    -- Direkt Workspace cocuklari
    for _, obj in ipairs(Workspace:GetChildren()) do
        if isFruit(obj) then
            table.insert(fruits, obj)
        end
    end
    -- Mapin icerisindeki klasor/model icindekiler
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, obj in ipairs(folder:GetChildren()) do
                if isFruit(obj) then
                    table.insert(fruits, obj)
                end
            end
        end
    end
    return fruits
end

-- Izin verilen en iyi fruiti sec
local function getBestFruit(fruits)
    for _, fruit in ipairs(fruits) do
        if isAllowed(fruit.Name) then
            return fruit
        end
    end
    return nil
end

-- ============================================================
--  ESP
-- ============================================================
local function createESP(fruit)
    if not SETTINGS.EnableESP then return end
    if not fruit:FindFirstChild("Handle") then return end
    if fruit.Handle:FindFirstChild("FruitESP") then return end

    local billboard  = Instance.new("BillboardGui")
    billboard.Name   = "FruitESP"
    billboard.Size   = UDim2.new(0, 200, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.Parent = fruit.Handle

    local label = Instance.new("TextLabel")
    label.Size                  = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3            = Color3.fromRGB(255, 80, 255)
    label.TextStrokeTransparency = 0
    label.TextScaled            = true
    label.Font                  = Enum.Font.GothamBold
    label.Text                  = fruit.Name
    label.Parent                = billboard
end

local function removeESP(fruit)
    local handle = fruit:FindFirstChild("Handle")
    if handle then
        local esp = handle:FindFirstChild("FruitESP")
        if esp then esp:Destroy() end
    end
end

-- ============================================================
--  TWEEN (karakter fruita gider)
-- ============================================================
local activeTween = nil

local function tweenTo(targetPos)
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end

    local distance = (HRP.Position - targetPos).Magnitude
    local duration = math.max(distance / SETTINGS.TweenSpeed, 0.1)

    setLabel(DistanceLabel, "Fruit Distance", math.floor(distance) .. " studs", "255,255,255")
    setLabel(TweenLabel, "Tweening Status", "Tweening...", "0,170,255")

    local tween = TweenService:Create(
        HRP,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(targetPos) }
    )

    activeTween = tween
    tween:Play()
    tween.Completed:Wait()
    activeTween = nil

    setLabel(TweenLabel, "Tweening Status", "Done", "0,255,0")
end

-- ============================================================
--  STORE
-- ============================================================
local function storeFruit(fruit)
    -- OriginalName attribute yoksa fruit.Name'i kullan
    local fruitName = fruit:GetAttribute("OriginalName") or fruit.Name

    setLabel(StoreLabel, "Storing Status", "Storing " .. fruitName .. "...", "255,200,0")

    local ok, err = pcall(function()
        CommF:InvokeServer("StoreFruit", fruitName, fruit)
    end)

    if ok then
        setLabel(StoreLabel, "Storing Status", fruitName .. " stored!", "0,255,0")
        print("[SNIPER] Store basarili:", fruitName)
    else
        setLabel(StoreLabel, "Storing Status", "Store basarisiz: " .. tostring(err), "255,0,0")
        warn("[SNIPER] Store hatasi:", err)
    end

    return ok
end

-- ============================================================
--  SERVER HOP WRAPPER
-- ============================================================
local function doServerHop()
    setLabel(StatusLabel, "Status", "Server hopping...", "255,100,0")
    task.wait(SETTINGS.HopDelay)
    ServerHop:Teleport(game.PlaceId)
end

-- ============================================================
--  ANA DONGU
-- ============================================================
local running = true

-- Abort butonu
if UI.AbortButton and UI.AbortButton:FindFirstChild("Interact") then
    UI.AbortButton.Interact.MouseButton1Click:Connect(function()
        running = false
        if activeTween then activeTween:Cancel() end
        print("[SNIPER] Script durduruldu")
    end)
end

local function main()
    while running do
        task.wait(SETTINGS.ScanInterval)

        if not isAlive() then
            setLabel(StatusLabel, "Status", "Karakter bekleniyor...", "255,255,0")
            task.wait(3)
            continue
        end

        setLabel(StatusLabel, "Status", "Fruit aranıyor...", "255,255,0")

        local fruits = getAllFruits()

        if #fruits == 0 then
            setLabel(StatusLabel, "Status", "Fruit yok, hop yapılıyor...", "255,0,0")
            doServerHop()
            return  -- Teleport sonrasi script yeniden baslatilir
        end

        -- Tum fruitlere ESP ekle
        for _, fruit in ipairs(fruits) do
            createESP(fruit)
        end

        local target = getBestFruit(fruits)

        if not target then
            setLabel(StatusLabel, "Status", "Izinli fruit yok, hop yapılıyor...", "255,0,0")
            doServerHop()
            return
        end

        -- Hedef yokoldu mu kontrol et
        if not target.Parent then
            continue
        end

        setLabel(StatusLabel, "Status", target.Name .. " bulundu!", "0,255,0")
        setLabel(FruitTypeLbl, "Fruit Type", target.Name, "0,255,0")

        -- Fruita git
        tweenTo(target.Handle.Position)

        -- Gidis sirasinda fruit hala var mi?
        if not target.Parent or not target.Handle.Parent then
            setLabel(StatusLabel, "Status", "Fruit kayboldu, yeniden taranıyor...", "255,100,0")
            continue
        end

        task.wait(0.3)

        -- Store et
        local stored = storeFruit(target)
        removeESP(target)

        task.wait(SETTINGS.StoreDelay)

        if stored then
            -- Basariyla store edildi, yeni sunucuya gec
            doServerHop()
            return
        end
        -- Store basarisizsa donguye devam et, ayni sunucuda tekrar dene
    end
end

-- Scripti calistir
print("[SNIPER] Fruit Sniper baslatildi")
main()
