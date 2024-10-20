local MinimizeMenuBind = Enum.KeyCode.LeftControl

-- Aim Init
_G.nn_FOV = Drawing.new("Circle")
_G.nn_FOV.Visible = false
_G.nn_FOV.Radius = 33
_G.nn_FOV.Color = Color3.fromRGB(255,255,255)
_G.nn_FOV.Position = Vector2.new(25, 2)

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

local Window = Fluent:CreateWindow({
    Title = "War Tycoon",
    SubTitle = "ода шедевротайкон nnhub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = MinimizeMenuBind
})

local Options = Fluent.Options

local Tabs = {
    Credits = Window:AddTab({ Title = "Credits", Icon = "tags" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye"}),
    Others = Window:AddTab({ Title = "Others", Icon = "sword"}),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair"}),
    Misc = Window:AddTab({ Title = "Misc", Icon = "layout-list"}),
    Farm = Window:AddTab({ Title = "Farm", Icon = "truck"})
}

local function medkit()
    for Index, Tycoon in ipairs(game.Workspace.Tycoon.Tycoons:GetChildren()) do
        for Index2, Object in ipairs(Tycoon.PurchasedObjects:GetChildren()) do
            if Object.Name == "Medkit Giver" and Object:FindFirstChild("Prompt") ~= nil then
                return Object
            end
        end
    end

    return nil
end

Tabs.Misc:AddButton({
    Title = "Disable door lasers and electric fence",
    Description = "TIP:To disable it you need to rejoin. That rule also work for every button in script.",
    Callback = function()
        while wait(1) do
            for Index, Tycoon in ipairs(game.Workspace.Tycoon.Tycoons:GetChildren()) do
                for Index2, Object in ipairs(Tycoon.PurchasedObjects:GetChildren()) do
                    if Object:FindFirstChild("Laser") ~= nil and Object:FindFirstChild("Laser"):FindFirstChild("TouchInterest") ~= nil then
                        Object.Laser.Color = Color3.fromRGB(0, 255, 244)
                        Object.Laser.TouchInterest:Remove()
                    end
                    if Object:FindFirstChild("OwnerOnly") ~= nil and Object:FindFirstChild("OwnerOnly"):FindFirstChild("TouchInterest") ~= nil then
                        Object.OwnerOnly.Color = Color3.fromRGB(0, 255, 244)
                        Object.OwnerOnly.TouchInterest:Remove()
                    end
                    if Object.Name == "Electric Fence" and Object:FindFirstChild("Collision") then
                        Object.Collision:Remove()
                    end
                end
            end
        end
    end
})

Tabs.Misc:AddButton({
    Title = "Get medkit",
    Description = "Just give you medkit",
    Callback = function()
        local Position = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        local Medkit = medkit()

        if medkit == nil then
            Fluent:Notify({
                Title = "Exception",
                Content = "Cannot get medkit.",
                SubContent = "",
                Duration = 2
            })
        else
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Medkit.Prompt.CFrame
            wait(.25)
            Medkit.Prompt["Weapon Giver"].RequiresLineOfSight = false
            for i = 1,6 do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Medkit.Prompt.CFrame
                fireproximityprompt(Medkit.Prompt["Weapon Giver"])
                wait(0.1)
            end
            Medkit.Prompt["Weapon Giver"].RequiresLineOfSight = true
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Position
        end
    end
})

Tabs.Misc:AddButton({
    Title = "Hide nickname",
    Description = "What should i write here? just hide nickname",
    Callback = function()
        game:GetService("RunService").RenderStepped:Connect(function()
            if game.Players.LocalPlayer.Character:FindFirstChild("Head"):FindFirstChild("NameTag") then
                game.Players.LocalPlayer.Character:FindFirstChild("Head"):FindFirstChild("NameTag"):Remove()
            end
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "Fall Damage Bypass",
    Description = "Doesnt remove it full",
    Callback = function()
        game:GetService("RunService").RenderStepped:Connect(function()
            if game.Players.LocalPlayer.Character.Freefall.Falling.Value then
                game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
            end
        end)
    end
})

local Aim = Tabs.Aimbot:AddToggle("Aimbot", {Title = "Aimbot (RMB)", Default = false })

local function isPlayerInCircle(player)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        local screenPosition, onScreen = game.Workspace.CurrentCamera:WorldToScreenPoint(position)
        
        if onScreen then
            local distance = (_G.nn_FOV.Position - Vector2.new(screenPosition.X, screenPosition.Y)).magnitude
            return distance <= tonumber(_G.nn_FOV.Radius)
        end
    end
    return false
end

local function isToolEquiped()
    for k,v in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") then
            return true
        end
    end
    
    return false
end

game:GetService("RunService").RenderStepped:Connect(function()
    _G.nn_FOV.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
    _G.nn_FOV.Visible = Options.Aimbot.Value

    if Options.Aimbot.Value then
        if _G.nn_ToolCheck then
            if isToolEquiped() then
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and isPlayerInCircle(player) and isRightMouseDown and table.find(FriendList, player.Name:lower()) == nil then
                        game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.Camera.CFrame.Position, player.Character[_G.nn_AimPart].Position)
                    end
                end
            end
        else
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and isPlayerInCircle(player) and isRightMouseDown and table.find(FriendList, player.Name:lower()) == nil then
                    game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.Camera.CFrame.Position, player.Character[_G.nn_AimPart].Position)
                end
            end
        end
    end
end)

local AimPart = Tabs.Aimbot:AddDropdown("AimPart", {
    Title = "Aim Part",
    Values = {"Head", "HumanoidRootPart"},
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
        _G.nn_FOV.Radius = Value
    end
})

local ToolCheck = Tabs.Aimbot:AddToggle("ToolCheck", {Title = "Tool Check", Default = false})

ToolCheck:OnChanged(function()
    _G.nn_ToolCheck = Options.ToolCheck.Value
end)

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