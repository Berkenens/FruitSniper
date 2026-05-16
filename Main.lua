local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommF = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("CommF_")

local success, err = pcall(function()
    CommF:InvokeServer("SetTeam", "Pirates")
end)

if success then
    print("[SNIPER] Team: Pirates")
else
    warn("[SNIPER] Takim err:", err)
end
