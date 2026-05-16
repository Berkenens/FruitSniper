--=============================================================================
-- ADMINUS FRUIT SNIPER - MAIN ORCHESTRATOR
--=============================================================================

-- 1. KULLANICI ARAYÜZÜNÜ (UI) İNTERNETTEN ÇEKME
local AdminusUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Berkenens/whitelist/refs/heads/main/Ui.lua"
))()

-- 2. AYARLAR VE HEDEF MEYVELER (Kullanıcı Ayarları)
local SETTINGS = _G.FruitSniperSettings or {
    Team = "Pirates",
    Fruits = {
        ["Kitsune Fruit"] = true,
        ["Dragon Fruit"] = true,
        ["Dough Fruit"] = true,
        ["Leopard Fruit"] = true, -- Ekstra değerli meyveler eklenebilir
    }
}

-- 3. OTOMATİK TAKIM SEÇME (Oyun Başlangıç Kilidini Kırma)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 10)

if CommF then
    pcall(function()
        CommF:InvokeServer("SetTeam", SETTINGS.Team)
    end)
end

-- 4. GEREKLİ ROBLOX SERVİSLERİ VE DEĞİŞKENLER
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart", 10)

-- UI Element Köprüleri (Çökme hatası veren 'self' yapıları düzeltildi)
local Status = AdminusUI.Status
local TweenStatus = AdminusUI.TweenStatus
local StoreStatus = AdminusUI.StoringStatus
local FruitType = AdminusUI.FruitType
local DistanceText = AdminusUI.FruitDistance

-- Sniper Hız ve ESP Ayarları
local TWEEN_SPEED = 250
local ENABLE_ESP = true

-- 5. YARDIMCI FONKSİYONLAR
local function IsAllowedFruit(fruitName)
    -- Eğer _G tablosu boşsa veya tüm meyveler toplansın isteniyorsa koruma
    if not next(SETTINGS.Fruits) then return true end 
    return SETTINGS.Fruits[fruitName] == true
end

local function ServerHop()
    -- Hafıza hatası düzeltilmiş yeni ServerHop modülünü çağırıyoruz
    local success, hop = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Berkenens/whitelist/refs/heads/main/Svhop.lua"))()
    end)
    
    if success and hop then
        hop:Teleport(game.PlaceId)
    else
        warn("[ADMINUS] - Server Hop linki yuklenemedi, yerel deneme yapiliyor.")
        -- Alternatif yedek hop mantığı (Link çökme ihtimaline karşı)
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
end

local function IsFruit(tool)
    return tool:IsA("Tool")
        and tool:FindFirstChild("Handle")
        and string.find(tool.Name, "Fruit")
end

local function GetAllFruits()
    local fruits = {}
    for _, v in ipairs(Workspace:GetChildren()) do
        if IsFruit(v) then
            table.insert(fruits, v)
        end
    end
    return fruits
end

local function GetBestFruit(fruits)
    for _, fruit in ipairs(fruits) do
        if IsAllowedFruit(fruit.Name) then
            return fruit
        end
    end
    return nil
end

-- ESP SİSTEMİ (Meyvelerin Yerini İşaretler)
local function CreateESP(fruit)
    if not ENABLE_ESP then return end
    if fruit:FindFirstChild("FruitESP") or not fruit:FindFirstChild("Handle") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FruitESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = fruit.Handle

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 100, 255)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = fruit.Name
    label.Parent = billboard
end

-- Gelişmiş Uçma (Tween) Fonksiyonu
local function TweenTo(position)
    if not HRP then return end
    local distance = (HRP.Position - position).Magnitude
    local time = distance / TWEEN_SPEED

    local tween = TweenService:Create(
        HRP,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    
    DistanceText.Text = 'Fruit Distance: <font color="rgb(255,255,255)" weight="Regular">' .. math.floor(distance) .. '</font>'
    TweenStatus.Text = 'Tweening Status: <font color="rgb(0,170,255)" weight="Regular">Tweening...</font>'
    
    tween:Play()
    tween.Completed:Wait()
    
    TweenStatus.Text = 'Tweening Status: <font color="rgb(0,255,0)" weight="Regular">Tweening done</font>'
end

-- Meyveyi Depolama (Envantere Atma)
local function StoreFruit(fruit)
    if not CommF then return end
    
    StoreStatus.Text = 'Storing Status: <font color="rgb(255,255,0)" weight="Regular">Storing...</font>'
    
    local success, err = pcall(function()
        CommF:InvokeServer(
            "StoreFruit",
            fruit:GetAttribute("OriginalName") or fruit.Name,
            fruit
        )
    end)

    if success then
        StoreStatus.Text = 'Storing Status: <font color="rgb(0,255,0)" weight="Regular">Fruit Stored</font>'
    else
        StoreStatus.Text = 'Storing Status: <font color="rgb(255,0,0)" weight="Regular">Failed: </font>' .. tostring(err)
    end
end

-- 6. ANA DÖNGÜ (Sistem Motoru)
local function Main()
    -- Karakter koruması (Doğduğundan emin oluyoruz)
    if not HRP or not Character:Parent() then
        Character = Player.Character or Player.CharacterAdded:Wait()
        HRP = Character:WaitForChild("HumanoidRootPart", 10)
    end

    Status.Text = 'Status: <font color="rgb(255,255,0)" weight="Regular">Searching fruit...</font>'
    task.wait(1)

    local fruits = GetAllFruits()

    -- Sunucuda hiç meyve yoksa direkt server hop at
    if #fruits == 0 then
        Status.Text = 'Status: <font color="rgb(255,0,0)" weight="Regular">No fruit found, server hopping...</font>'
        task.wait(1.5)
        ServerHop()
        return
    end

    -- Meyvelere ESP bas
    for _, fruit in ipairs(fruits) do
        CreateESP(fruit)
    end

    -- Ayarlarda izin verdiğin en iyi meyveyi seç
    local target = GetBestFruit(fruits)

    -- İzin verilen meyvelerden biri yoksa server hop at
    if not target then
        Status.Text = 'Status: <font color="rgb(255,0,0)" weight="Regular">No allowed fruits found, server hopping...</font>'
        task.wait(1.5)
        ServerHop()
        return
    end

    -- Meyveye kilitlen ve operasyonu başlat
    Status.Text = 'Status: <font color="rgb(0,255,0)" weight="Regular">Fruit found</font>'
    FruitType.Text = 'Fruit Type: <font color="rgb(0,255,0)" weight="Regular">' .. target.Name .. '</font>'

    -- Meyveye uç, ye/al ve envantere yükle
    TweenTo(target.Handle.Position)
    task.wait(0.5)
    
    -- Meyveyi yerden alabilmek için karaktere equip etme simülasyonu (Güvenlik Önlemi)
    pcall(function()
        Player.Character.Humanoid:EquipTool(target)
    end)
    task.wait(0.5)

    StoreFruit(target)
    task.wait(2)
    
    -- İşlem bitti, yeni sunucuya geç
    ServerHop()
end

-- Sistemi tetikle
task.spawn(Main)
