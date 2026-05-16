--=============================================================================
  Config
--=============================================================================
local HedefMeyveler = {
    "Kitsune", 
    "Dragon", 
    "Control", 
    "Venom", 
    "Yeti", 
    "Dough", 
    "Gas", 
    "Lightning", 
    "Tiger", 
    "T-Rex"
}
local SeciliTakim = "Pirates" -- "Pirates" or "Marines"

--=============================================================================

--=============================================================================
_G.FruitSniperSettings = {
    Team = SeciliTakim,
    Fruits = {}
}


for _, meyveAdi in ipairs(HedefMeyveler) do
    local tamIsim = string.find(meyveAdi, "Fruit") and meyveAdi or (meyveAdi .. " Fruit")
    _G.FruitSniperSettings.Fruits[tamIsim] = true
end

--=============================================================================

--=============================================================================
local AdminusUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/flerci42/Adminus_FruitSniper_V2/refs/heads/main/GraphicalUserInterface.lua"
))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")


local Status = (self and self.Status) or AdminusUI.Status or {Text = ""}
local TweenStatus = (self and self.TweenStatus) or AdminusUI.TweenStatus or {Text = ""}
local StoreStatus = (self and self.StoringStatus) or AdminusUI.StoringStatus or {Text = ""}
local FruitType = (self and self.FruitType) or AdminusUI.FruitType or {Text = ""}
local DistanceText = (self and self.FruitDistance) or AdminusUI.FruitDistance or {Text = ""}

local TWEEN_SPEED = 250
local ENABLE_ESP = true

--=============================================================================

--=============================================================================
local args = {
    [1] = "SetTeam",
    [2] = _G.FruitSniperSettings.Team
}
CommF:InvokeServer(unpack(args))

--=============================================================================

--=============================================================================
local function IsAllowedFruit(fruitName)
    return _G.FruitSniperSettings.Fruits[fruitName] == true
end

local function ServerHop()
    local success, hop = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/flerci42/Server-Hop/refs/heads/main/.lua"))()
    end)
    
    if success and hop then
        hop:Teleport(game.PlaceId)
    else
        warn("Server Hop scripti yüklenemedi!")
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

local function CreateESP(fruit)
    if not ENABLE_ESP or fruit:FindFirstChild("FruitESP") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FruitESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = fruit.Handle

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 100, 255)
    label.TextStrokeTransparency = 0.5 
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = fruit.Name
    label.Parent = billboard
end

local function TweenTo(position)
   
    local distance = (HRP.Position - position).Magnitude
    local time = distance / TWEEN_SPEED

    
    local safePosition = position + Vector3.new(0, 3, 0)

    local tween = TweenService:Create(
        HRP,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(safePosition)}
    )
    
    DistanceText.Text = 'Fruit Distance: <font color="rgb(255,255,255)">'..math.floor(distance)..'</font>'
    TweenStatus.Text = 'Tweening Status: <font color="rgb(0,170,255)">Tweening...</font>'
    
    
    local noclipConnection
    noclipConnection = RunService.Stepped:Connect(function()
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)

    tween:Play()
    tween.Completed:Wait()
    
    noclipConnection:Disconnect() 
    TweenStatus.Text = 'Tweening Status: <font color="rgb(0,255,0)">Tweening done</font>'
end

local function StoreFruit(fruit)
    local success, err = pcall(function()
        CommF:InvokeServer(
            "StoreFruit",
            fruit:GetAttribute("OriginalName") or fruit.Name, 
            fruit
        )
    end)

    if not success then
        StoreStatus.Text = 'Storing Status: <font color="rgb(255,255,0)">Failed storing fruit... </font>'..err
    end
end

--=============================================================================

--=============================================================================
local function Main()
    Status.Text = 'Status: <font color="rgb(255,255,0)">Searching fruit...</font>'

    local fruits = GetAllFruits()

    if #fruits == 0 then
        Status.Text = 'Status: <font color="rgb(255,0,0)">No fruit found, server hopping...</font>'
        task.wait(1.5)
        ServerHop()
        return
    end

    for _, fruit in ipairs(fruits) do
        CreateESP(fruit)
    end

    local target = GetBestFruit(fruits)

    if not target then
        Status.Text = 'Status: <font color="rgb(255,0,0)">No allowed fruits found, server hopping...</font>'
        task.wait(1.5)
        ServerHop()
        return
    end

    Status.Text = 'Status: <font color="rgb(0,255,0)">Fruit found</font>'
    FruitType.Text = 'Fruit Type: <font color="rgb(0,255,0)">'..target.Name..'</font>'

    TweenTo(target.Handle.Position)
    task.wait(0.5) 
    StoreFruit(target)
    StoreStatus.Text = 'Storing Status: <font color="rgb(0,255,0)">Fruit Stored</font>'
    
    task.wait(1.5)
    ServerHop()
end

Main()
