local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

CommF:InvokeServer("SetTeam", "Marines")
print("team : Marines")
