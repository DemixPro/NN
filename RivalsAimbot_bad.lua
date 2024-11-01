local MinimizeMenuBind = Enum.KeyCode.LeftControl

nn_FOV = Drawing.new("Circle")
nn_FOV.Visible = false
nn_FOV.Radius = 33
nn_FOV.Color = Color3.fromRGB(255,255,255)
nn_FOV.Position = Vector2.new(25, 2)

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
    Title = "Aimbot",
    SubTitle = "ода аим из шедевротайкона - nnhub",
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
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
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

local function hasForceField(player)
    if Options.ForceFieldCheck.Value then
        for k,v in ipairs(player.Character:GetChildren()) do
            if v:IsA("ForceField") then
                return true
            end
        end

        return false
    end

    return false
end

game:GetService("RunService").RenderStepped:Connect(function()
    nn_FOV.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
    nn_FOV.Visible = Options.Aimbot.Value

    if Options.Aimbot.Value then
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and isPlayerInCircle(player) and isRightMouseDown and table.find(FriendList, player.Name:lower()) == nil and not hasForceField(player) and isToolEquiped() then
                game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.Camera.CFrame.Position, player.Character[_G.nn_AimPart].Position)
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
    _G.nn_AimPart = Value
end)

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

local ForceFieldCheck = Tabs.Aimbot:AddToggle("ForceFieldCheck", {Title = "Force Field Check", Default = false })

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

queue_on_teleport("https://raw.githubusercontent.com/DemixPro/NN/refs/heads/main/RivalsAimbot_bad.lua")
