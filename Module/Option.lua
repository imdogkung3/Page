local _ENV = (getgenv or getrenv or getfenv)()

local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat

local Module = {}

Module.Connect = (function()
    local Connections = _ENV.Connections or {}

    for i = 1, #Connections do
        Connections[i]:Disconnect()
    end

    table.clear(Connections)
    _ENV.Connections = Connections

    return function(Instance, Callback)
        local Connection = Instance:Connect(Callback)

        table.insert(Connections, Connection)

        return Connection
    end
end)()

local Connect = Module.Connect

function Module.NewOption(Function, Interval)
    Interval = Interval or 0.1

    Connect(Heartbeat, function()
        task.wait(Interval)

        if Function then
            local Success, Error = pcall(Function)

            if not Success then
                print(Error)
            end
        end
    end)
end

return Module
