-- Made by DemixLuaher
local MinimizeMenuBind = Enum.KeyCode.RightShift

nn_FOV = Drawing.new("Circle")
nn_FOV.Visible = false
nn_FOV.Radius = 33
nn_FOV.Color = Color3.fromRGB(255,255,255)
nn_FOV.Position = Vector2.new(25, 2)

mouse = game:GetService("Players").LocalPlayer:GetMouse()
camera = workspace.CurrentCamera

game:GetService("UserInputService").InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, isProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = false
    end
end)
local FriendList = {}

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Options = Fluent.Options

local Window = Fluent:CreateWindow({
    Title = "Rivals Aimbot",
    SubTitle = "DemixLuaher - nnhub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = MinimizeMenuBind
})

local Tabs = { Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair"}) }

local Aim = Tabs.Aimbot:AddToggle("Aimbot", {Title = "Aimbot (RMB)", Default = false })

local function isPlayerInCircle(player)
    local character = player.Character
    if character and character:FindFirstChild(_G.AimPart) then
        local position = character[_G.AimPart].Position
        local screenPosition, onScreen = game.Workspace.CurrentCamera:WorldToScreenPoint(position)
        
        if onScreen then
            local distance = (nn_FOV.Position - Vector2.new(screenPosition.X, screenPosition.Y)).magnitude
            return distance <= tonumber(nn_FOV.Radius)
        end
    end
    return false
end

local function isToolEquiped()
    if _G.nnhub_ToolCheck then
        for k,v in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") then
                return true
            end
        end
        
        return false
    end
    return true
end

local function spectateCheck()
    if Options.SpectateDisable.Value then
        if game:GetService("Players").LocalPlayer.PlayerGui.MainGui.MainFrame.FighterInterfaces[game:GetService("Players").LocalPlayer.Name].Health.Spectators.Value.Text ~= "0" then
            return false
        end
        return true
    end
    
    return true
end

task.spawn(function()
    while task.wait() do
        nn_FOV.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
        nn_FOV.Visible = Options.Aimbot.Value

        if Options.Aimbot.Value then
            nn_FOV.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)

            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game:GetService("Players").LocalPlayer and isPlayerInCircle(player) and isRightMouseDown and table.find(FriendList, player.Name:lower()) == nil and spectateCheck() then
                    local Position = game.Workspace.CurrentCamera:WorldToScreenPoint(player.Character[_G.AimPart].Position)
                    
                    local mouseX = mouse.X
                    local mouseY = mouse.Y
                    
                    local centerX = Position.X
                    local centerY = Position.Y
                    
                    local smoothingFactor = 0.2
        
                    local deltaX = (centerX - mouseX) * smoothingFactor
                    local deltaY = (centerY - mouseY) * smoothingFactor

                    mousemoverel(deltaX, deltaY)
                end
            end
        end
    end
end)

local AimPart = Tabs.Aimbot:AddDropdown("AimPart", {
    Title = "Aim Part",
    Values = {"HitboxBody", "HitboxHead"},
    Multi = false,
    Default = 2
})

AimPart:OnChanged(function(Value)
    _G.AimPart = Value
end)

local RandomAim = Tabs.Aimbot:AddToggle("RandomAim", {Title = "Random Aim Part", Default = false })

task.spawn(function()
    while task.wait() do
        if Options.RandomAim.Value then
            if math.random(1,2) == 1 then
                _G.AimPart = "HitboxHead"
            else
                _G.AimPart = "HitboxBody"
            end

            wait(_G.aimSwapDelay)
        end
    end
end)

Tabs.Aimbot:AddSlider("Slider", {
    Title = "Aim Swap Delay",
    Description = "",
    Default = 4,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        _G.aimSwapDelay = Value
    end
})

Tabs.Aimbot:AddSlider("Slider", {
    Title = "Aim Size",
    Description = "",
    Default = 80,
    Min = 1,
    Max = 2000,
    Rounding = 1,
    Callback = function(Value)
        nn_FOV.Radius = Value
    end
})

local SpectateDisable = Tabs.Aimbot:AddToggle("SpectateDisable", {Title = "Spectate Disable", Default = false })

Tabs.Aimbot:AddInput("Input", {
    Title = "Friend list",
    Default = "",
    Placeholder = "Ebert54349",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if table.find(FriendList, Value:lower()) ~= nil then
            table.remove(FriendList, table.find(FriendList, Value:lower()))
            Fluent:Notify({
                Title = "FriendList",
                Content = "Friend has been removed.",
                SubContent = "You can see friend list in dev console (F9)",
                Duration = 2
            })
            print("-----")
            print("Friends:")
            for _,v in pairs(FriendList) do
                print(v)
            end
            print("-----")
        else
            table.insert(FriendList, Value:lower())
            Fluent:Notify({
                Title = "FriendList",
                Content = "Friend has been added.",
                SubContent = "You can see friend list in dev console (F9)",
                Duration = 2
            })
            print("-----")
            print("Friends:")
            for _,v in pairs(FriendList) do
                print(v)
            end
            print("-----")
        end
    end
})

Window:SelectTab(1)

queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/DemixPro/NN/refs/heads/main/rivals-aimbot.lua"))())
