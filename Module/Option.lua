local _ENV = (getgenv or getrenv or getfenv)()

local RUNSERVICE = game:GetService("RunService")
local HEARTBEAT = RUNSERVICE.Heartbeat

local MODULE = {}

MODULE.CONNECT = (function()
    local CONNECTIONS = _ENV.Connections or {}

    for I = 1, #CONNECTIONS do
        CONNECTIONS[I]:Disconnect()
    end

    table.clear(CONNECTIONS)
    _ENV.Connections = CONNECTIONS

    return function(INSTANCE, CALLBACK)
        local CONNECTION = INSTANCE:Connect(CALLBACK)

        table.insert(CONNECTIONS, CONNECTION)

        return CONNECTION
    end
end)()

local CONNECT = MODULE.CONNECT

function MODULE.NEWOPTION(FUNCTION, INTERVAL)
    INTERVAL = INTERVAL or 0.1

    CONNECT(HEARTBEAT, function()
        task.wait(INTERVAL)

        if FUNCTION then
            local SUCCESS, ERROR = pcall(FUNCTION)

            if not SUCCESS then
                print(ERROR)
            end
        end
    end)
end

return MODULE
