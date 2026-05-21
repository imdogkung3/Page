local Env = (getgenv or getrenv or getfenv)()

local Utils = {}
local Settings = {}
local Threads = {}
local Fallback = {}

local Owner = "imdogkung3"
local Repository = "Page"

local thread = tostring(os.clock() + math.random()) do
    Env.thread = thread
    Env.settings = {}
end

local function fetch(file)
    local URL = string.format(
        "https://raw.githubusercontent.com/%s/%s/main/%s",
        Owner,
        Repository,
        file
    )
    return loadstring(game:HttpGet(URL))()
end

local function AddModule(Name, Module)
    do
        Utils[Name] = Module()
        return Utils[Name]
    end
end

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

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
            writefile(
                Configurations.FullPaths,
                HttpService:JSONEncode(Settings)
            )
        end
        function Configurations:Load()
            if not isfile(Configurations.FullPaths) then
                self:Save()
            end
            local Success, Result = pcall(function()
                return HttpService:JSONDecode(
                    readfile(Configurations.FullPaths)
                )
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

AddModule("Parallels", function()
    local Parallels = {}
    local Options = {}
    local clonedEnabled = {}
    local Functions = Env.FUNCTIONS or {}
    local FarmFunctions = Env.FARM_FUNCTIONS or {}
    local Enabled_Toggle_Debounce = false
    local Enabled_New_Values = {}
    do
        local function RunQueue(Options)
            while task.wait() do
                if Env.thread ~= thread then
                    break
                end
                for _, Option in Options do
                    local Success, ErrorMessage = pcall(function()
                        Env.RunningOption = Option.Name
                        local Method = Option.Function()
                        if Method then
                            Env.OnFarm = true
                        end
                    end)
                    if not Success then
                        warn(ErrorMessage)
                    end
                end
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
        local Enabled = Env.ENABLED_OPTIONS or setmetatable({}, {
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
            Env.FUNCTIONS = Functions
            Env.ENABLED_OPTIONS = Enabled
            Env.FARM_FUNCTIONS = FarmFunctions
            task.spawn(RunQueue, FarmFunctions)
        end
        local function NewOption(Tag, Function)
            local Data = {
                ["Name"] = Tag,
                ["Function"] = Function
            }
            table.insert(Functions, Data)
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
    local Enabled = Parallels.Options()
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
        Library:ToggleTransparency(false)
        self["Base"] = Window
        return Window
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
    function Plugins:Dialog(Info, Buttons)
        local DialogButtons = {}
        for i, v in pairs(Buttons) do
            table.insert(DialogButtons, {
                Title = v.Title,
                Callback = function()
                    if type(v.Callback) == "function" then
                        v.Callback()
                    end
                end
            })
        end
        return self.Base:Dialog({
            Title = Info[1],
            Content = Info[2],
            Buttons = DialogButtons
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
            Settings[Flag] = value
            Configurations:Save(Flag, value)
            Env.settings[Flag] = value
            Enabled[Flag] = value
            if value then
                Thread = task.spawn(function()
                    if Callback then
                        Callback(value)
                    end
                end)
            else
                if Thread then
                    task.cancel(Thread)
                    Thread = nil
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
            Placeholder = Info[2],
            Default = Settings[Flag],
            Numeric = false
        })
        Input:OnChanged(function(value)
            Settings[Flag] = value
            Configurations:Save(Flag, value)
            if Callback then
                Callback(value)
            end
        end)
        return Input
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
