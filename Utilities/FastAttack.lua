do
    local W = {}
    local a = game:GetService('Players')
    local h = game:GetService("RunService")
    local h = game:GetService('ReplicatedStorage')
    local X = game:GetService("Workspace")
    local X = game:GetService("VirtualInputManager")
    local X = a.LocalPlayer
    local X = h:WaitForChild('Modules')
    local w = X:WaitForChild("Net")
    local X = w:WaitForChild("RE/RegisterAttack")
    local X = w:WaitForChild('RE/RegisterHit')
    local X = w:WaitForChild('RE/ShootGunEvent')
    local X = h:WaitForChild("Remotes"):WaitForChild('Validator2')
    local h = game.ReplicatedStorage.Modules
    local X = h.Net
    local h, h = X:WaitForChild("RE/RegisterHit"), X:WaitForChild('RE/RegisterAttack')
    local h = {}
    function GetAllBladeHits()
        bladehits = {}
        for X, X in pairs(workspace.Enemies:GetChildren()) do
            if X:FindFirstChild('Humanoid') and X:FindFirstChild('HumanoidRootPart') and X.Humanoid.Health > 0 and (X.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 65 then
                table.insert(bladehits, X)
            end
        end
        return bladehits
    end
    function Getplayerhit()
        bladehits = {}
        for X, X in pairs(workspace.Characters:GetChildren()) do
            if X.Name ~= game.Players.LocalPlayer.Name and X:FindFirstChild('Humanoid') and X:FindFirstChild('HumanoidRootPart') and X.Humanoid.Health > 0 and (X.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 65 then
                table.insert(bladehits, X)
            end
        end
        return bladehits
    end
    local X = (Services.ReplicatedStorage.Modules.Net)
    local w = require(X):RemoteEvent("RegisterAttack", true)
    local D = require(X):RemoteEvent("RegisterHit", true)
    function h:Attack()
        local X = {}
        for y, y in pairs(GetAllBladeHits()) do table.insert(X, y) end
        for y, y in pairs(Getplayerhit()) do table.insert(X, y) end
        if #X == 0 then return end
        local y = {[1] = nil, [2] = {}, [4] = "078da5141"}
        for L, L in pairs(X) do
            w:FireServer(0)
            if not y[1] then y[1] = L.Head end
            table.insert(y[2], {[1] = L, [2] = L.HumanoidRootPart})
            table.insert(y[2], L)
        end
        D:FireServer(unpack(y))
    end
    task.spawn(function()
        while task.wait() do if _G.FastAttack == os.time() then pcall(function() h:Attack() end) end end
    end)
    function W.Attack(h) pcall(function() _G.FastAttack = os.time() end) end
end
