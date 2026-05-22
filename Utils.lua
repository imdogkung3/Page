local _ENV = (getgenv or getrenv or getfenv)()

local Utils = {}
local Settings = {}
local Threads = {}
local Fallback = {}

local Owner = "imdogkung3"
local Repository = "Page"

local THREAD_HASH = tostring(os.clock() + math.random()) do
    _ENV.__THREAD_HASH = THREAD_HASH
    _ENV.GLOBALS_SETTINGS = {}
end

local function fetch(file)
    local URL = string.format(
        "https://raw.githubusercontent.com/%s/%s/main/%s",
        Owner,
        Repository,
        file
    )

    warn("Fetch :", file)

    return loadstring(game:HttpGet(URL))()
end

local function AddModule(Name, Module)
    do
        Utils[Name] = Module()
        return Utils[Name]
    end
end

local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

AddModule("Connections", function()
    local Connections = {}
    local Cached = _ENV.Connections or {}

    do
        _ENV.Connections = Cached

        for i = 1, #Cached do
            Cached[i]:Disconnect()
        end

        table.clear(Cached)
    end

    function Connections.Connect(Instance, Callback)
        local Connection = Instance:Connect(Callback)

        table.insert(Cached, Connection)

        return Connection
    end

    return Connections
end)

AddModule("Configurations", function()
    local Configurations = {}

    local Files = "Quertzy'Script"

    local makefolder = makefolder or function(...) return ... end
    local writefile = writefile or function(...) return ... end
    local isfolder = isfolder or function(...) return ... end
    local readfile = readfile or function(...) return ... end
    local isfile = isfile or function(...) return ... end

    Configurations.Set = `{Files}/Settings/{LocalPlayer.UserId}`

    Configurations.FullPaths = `{Configurations.Set}/{PlaceId}.json`

    Configurations.Paths = {
        Files,
        `{Files}/Settings`,
        Configurations.Set
    }

    do
        function Configurations:Folder()
            for i = 1, #self.Paths do
                local str = self.Paths[i]

                if not isfolder(str) then
                    makefolder(str)
                end
            end
        end

        function Configurations:Default(index, value)
            if Settings[index] == nil then
                Settings[index] = value
            end
        end

        function Configurations:Save(index, value)
            if index ~= nil then
                Settings[index] = value
            end

            if not isfolder(Files) then
                makefolder(Files)
            end

            if not isfolder(`${Files}/Settings`) then
                makefolder(`${Files}/Settings`)
            end

            if not isfolder(Configurations.Set) then
                makefolder(Configurations.Set)
            end

            writefile(
                Configurations.FullPaths,
                HttpService:JSONEncode(Settings)
            )
        end

        function Configurations:Load()
            if not isfile(Configurations.FullPaths) then
                self:Save()
            end

            local Reader = readfile(Configurations.FullPaths)

            local Success, Result = pcall(function()
                return HttpService:JSONDecode(Reader)
            end)

            if Success and type(Result) == "table" then
                return Result
            end

            return {}
        end
    end

    do
        Configurations:Folder()
    end

    return Configurations
end)

AddModule("Others", function()
    local Others = {}

    Others.Server = (function()
        local Server = {}

        function Server:Reversed(cursor)
            local url = `https://games.roblox.com/v1/games/{PlaceId}/servers/Public?sortOrder=Asc&limit=100`

            if cursor then
                url ..= `&cursor={cursor}`
            end

            return HttpService:JSONDecode(game:HttpGet(url))
        end

        function Server:Change()
            local Cursor, Next

            repeat
                local Servers = Server:Reversed(Next)

                Cursor = Servers and Servers.data and Servers.data[1]
                Next = Servers and Servers.nextPageCursor
            until Cursor

            if not Cursor or not Cursor.id then return end
            return TeleportService:TeleportToPlaceInstance(PlaceId, Cursor.id, LocalPlayer)
        end

        return Server
    end)()

    Others.Optimize = (function()
        local Optimize = {}

        local WhiteScreen = false

        function Optimize:Set3d(value)
            WhiteScreen = value

            if value then
                RunService:Set3dRenderingEnabled(false)
            else
                RunService:Set3dRenderingEnabled(true)
            end
        end

        function Optimize:Low()
            local Terrain = workspace:FindFirstChildOfClass("Terrain")

            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end

            game.Lighting.GlobalShadows = false
            game.Lighting.FogEnd = 9e9

            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
        end

        return Optimize
    end)()

    return Others
end)

AddModule("Parallels", function()
    local Parallels = {}

    local Options = {}
    local clonedEnabled = {}

    local Functions = _ENV.FUNCTIONS or {}
    local FarmFunctions = _ENV.FARM_FUNCTIONS or {}

    local Enabled_Toggle_Debounce = false
    local Enabled_New_Values = {}

    do
        local function ShowErrorMessage(ErrorMessage)
            _ENV.OnFarm = false

            local text = (`error [ { _ENV.RunningOption or "Null" } ] { ErrorMessage }`)

            warn(text)

            if _ENV.error_message then
                _ENV.error_message:Destroy()
                _ENV.error_message = nil
            end

            local Message = Instance.new("Message")
            Message.Parent = workspace
            Message.Text = text

            _ENV.error_message = Message

            task.delay(5, function()
                if _ENV.error_message == Message then
                    Message:Destroy()
                    _ENV.error_message = nil
                end
            end)
        end

        local function RunQueue(Options)
            local Success, ErrorMessage = pcall(function()

                local function GetQueue()
                    for _, Option in ipairs(Options) do
                        _ENV.RunningOption = Option.Name

                        local Method = Option.Function()

                        if Method then
                            _ENV.Runinge = true

                            if type(Method) == "string" then
                                _ENV.RunningMethod = Method
                            end

                            return Method
                        end
                    end

                    _ENV.RunningOption = nil
                    _ENV.RunningMethod = nil
                end

                while task.wait() do
                    if _ENV.__THREAD_HASH ~= THREAD_HASH then
                        _ENV.RunningOption = nil
                        _ENV.RunningMethod = nil
                        _ENV.OnFarm = false
                        warn("Break Old Queue")
                        break
                    end

                    _ENV.Runinge = false
                    _ENV.OnFarm = if GetQueue() then true else false
                end
            end)

            if not Success then
                ShowErrorMessage(ErrorMessage)

                task.delay(2, function()
                    if _ENV.error_message then
                        _ENV.error_message.Text = "Quertzy Shield\nHas been Disabled " .. _ENV.RunningOption
                        task.wait(2)

                        if _ENV.RunningOption and Fallback[_ENV.RunningOption] then
                            pcall(function()
                                Fallback[_ENV.RunningOption]:SetValue(false)
                            end)
                        end

                        if _ENV.error_message then
                            _ENV.error_message:Destroy()
                            _ENV.error_message = nil
                        end

                        _ENV.Runinge = false
                        _ENV.OnFarm = false
                        _ENV.RunningOption = nil
                        _ENV.RunningMethod = nil

                        task.spawn(RunQueue, FarmFunctions)
                    end
                end)
            end
        end

        local function UpdateEnabledOptions()
            table.clear(FarmFunctions)

            for index, value in pairs(Enabled_New_Values) do
                clonedEnabled[index] = value or nil
                Enabled_New_Values[index] = nil
            end

            for i = 1, #Functions do
                local funcData = Functions[i]

                if clonedEnabled[funcData.Name] then
                    table.insert(FarmFunctions, funcData)
                end
            end
        end

        local Enabled = _ENV.ENABLED_OPTIONS or setmetatable({}, {
            __newindex = function(self, index, value)
                Enabled_New_Values[index] = value or false

                if not Enabled_Toggle_Debounce then
                    Enabled_Toggle_Debounce = true

                    task.spawn(function()
                        UpdateEnabledOptions()

                        Enabled_Toggle_Debounce = false
                    end)
                end
            end,

            __index = clonedEnabled
        })

        do
            _ENV.FUNCTIONS = Functions
            _ENV.ENABLED_OPTIONS = Enabled
            _ENV.FARM_FUNCTIONS = FarmFunctions

            task.spawn(RunQueue, FarmFunctions)
        end

        do
            table.clear(Functions)
        end

        local function While(a, b, c, d)
            while a do
                local t = tick()

                if c then
                    c()
                end

                if d and d() then
                    break
                end

                repeat
                    RunService.Heartbeat:Wait()
                until tick() - t >= (b or 0.1)
            end
        end

        local function NewOption(Tag, Function, Time)
            if Time then
                Threads[Tag] = function(Value)
                    While(
                        Value,
                        Time or 0.1,
                        Function,
                        function()
                            return not Value or _ENV.__THREAD_HASH ~= THREAD_HASH
                        end
                    )
                end
            else
                local Data = {
                    ["Name"] = Tag,
                    ["Function"] = Function
                }

                table.insert(Functions, Data)
            end
        end

        Parallels.NewOption = NewOption

        Parallels.Options = function()
            return Enabled, Options
        end
    end

    return Parallels
end)

AddModule("Plugins", function()
    local Plugins = {}

    local Configurations = Utils.Configurations
    local Parallels = Utils.Parallels
    local Others = Utils.Others

    local Enabled, Options = Parallels.Options()

    local Library = fetch("Library/Fluent")

    function Plugins:Window()
        local Window = Library:CreateWindow({
            Title = "Quertzy Hub |",
            SubTitle = "By i.m_Dog Editions",
            Search = true,
            Icon = "rbxassetid://125058182299499",
            TabWidth = 160,
            Size = UDim2.fromOffset(515, 300),
            Theme = "Quertzy",
            Transparency = true,
            MinimizeKey = Enum.KeyCode.LeftControl,
        })

        Library:CreateMinimizer({
            Icon = "rbxassetid://125058182299499",
            Size = UDim2.fromOffset(44, 44),
            Position = UDim2.new(0, 343, 0, 5),
            Acrylic = true,
            Corner = 10,
            Transparency = 0,
            Draggable = false,
            Visible = true
        })

        self.Base = Window

        return Window
    end

    function Plugins:NewPage(Info)
        return self.Base:AddTab({
            Title = Info[1],
            Icon = Info[2]
        })
    end

    function Plugins:Section(Page, Info)
        return Page:AddSection(Info[1])
    end

    function Plugins:Paragraph(Page, Info)
        return Page:AddParagraph({
            Title = Info[1],
            Content = Info[2]
        })
    end

    function Plugins:Notify(Info)
        return Library:Notify({
            Title = Info[1],
            Content = Info[2],
            Duration = Info[3]
        })
    end

    function Plugins:Button(Page, Info, Callback)
        return Page:AddButton({
            Title = Info[1],
            Description = Info[2],

            Callback = function()
                if type(Callback) == "function" then
                    Callback()
                end
            end
        })
    end

    function Plugins:Toggle(Page, Info, Flag, Callback)
        local Thread = nil

        Configurations:Default(Flag, false)

        Fallback[Flag] = Page:AddToggle(Flag, {
            Title = Info[1],
            Description = Info[2],
            Default = Settings[Flag]
        })

        Fallback[Flag]:OnChanged(function(value)
            _ENV.GLOBALS_SETTINGS[Flag] = value

            Settings[Flag] = value

            Configurations:Save(Flag, value)

            Enabled[Flag] = value

            if value then
                Thread = task.spawn(function()
                    if Threads[Flag] then
                        Threads[Flag](Settings[Flag])
                    end

                    if Callback then
                        Callback(value)
                    end
                end)
            else
                if Thread then
                    task.cancel(Thread)
                    Thread = nil
                end

                if Callback then
                    Callback(false)
                end
            end
        end)

        return Fallback[Flag]
    end

    function Plugins:Slider(Page, Info, Value, Flag, Callback)
        Configurations:Default(Flag, Value[1])

        local Slider = Page:AddSlider(Flag, {
            Title = Info[1],
            Description = Info[2],
            Min = Value[1],
            Max = Value[2],
            Rounding = Value[3],
            Default = Settings[Flag]
        })

        Slider:OnChanged(function(value)
            Settings[Flag] = value

            Configurations:Save(Flag, value)

            _ENV.GLOBALS_SETTINGS[Flag] = value

            if Callback then
                Callback(value)
            end
        end)

        return Slider
    end

    function Plugins:Dropdown(Page, Info, List, Multi, Flag, Callback)
        Configurations:Default(Flag, Multi and {} or "")

        local Dropdown = Page:AddDropdown(Flag, {
            Title = Info[1],
            Description = Info[2],
            Values = List,
            Multi = Multi,
            Default = Settings[Flag]
        })

        Dropdown:OnChanged(function(value)
            Settings[Flag] = value

            Configurations:Save(Flag, value)

            _ENV.GLOBALS_SETTINGS[Flag] = value

            if Callback then
                Callback(value)
            end
        end)

        return Dropdown
    end

    function Plugins:Input(Page, Info, Flag, Callback)
        Configurations:Default(Flag, "")

        local Input = Page:AddInput(Flag, {
            Title = Info[1],
            Default = Settings[Flag],
            Numeric = false
        })

        Input:OnChanged(function(value)
            Settings[Flag] = value

            Configurations:Save(Flag, value)

            _ENV.GLOBALS_SETTINGS[Flag] = value

            if Callback then
                Callback(value)
            end
        end)

        return Input
    end

    function Plugins:Managers()
        local Managers = Plugins:NewPage({
            "Managers",
            "rbxassetid://10734950020"
        })

        do
            local _1 = Plugins:Section(Managers, {
                "Optimization"
            })

            Plugins:Toggle(_1, {
                "White Screen",
                "Disable 3D rendering to improve performance and reduce lag."
            }, "White Screen", function(value)
                Others.Optimize:Set3d(value)
            end)

            Plugins:Button(_1, {
                "Fast Mode",
                "Lower graphics settings for better FPS and smoother farming."
            }, function()
                Others.Optimize:Low()
            end)

            local _2 = Plugins:Section(Managers, {
                "Configurations"
            })

            Configurations:Default("Theme", "Quertzy")
            Configurations:Default("Transparency", false)

            Plugins:Dropdown(_2, {
                "Theme",
                "Customize the appearance and colors of the interface."
            }, Library.Themes, false, "Theme", function(value)
                Library:SetTheme(value)
            end)

            Plugins:Toggle(_2, {
                "Transparency",
                "Enable an acrylic-style transparency effect with smoother visuals and a more modern interface appearance."
            }, "Transparency", function(value)
                Library:ToggleTransparency(value)
            end)

            Plugins:Button(_2, {
                "Remove Workspace",
                "Delete all saved configurations, reset every setting to its default value, and clear stored preferences for this game."
            }, function()
                local delfile = delfile or function(...) return ... end

                local Files = Configurations.FullPaths

                if Files and isfile(Files) then
                    pcall(delfile, Files)

                    warn("Remove Success")
                else
                    warn("File not found")
                end
            end)

        end

        return Managers
    end

    return Plugins
end)

do
    Plugins = Utils.Plugins
    Parallels = Utils.Parallels

    Settings = Utils.Configurations:Load()

    Utils.Settings = Settings
end

return Utils
