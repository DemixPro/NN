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

local Window = Fluent:CreateWindow({
    Title = "War Tycoon - 1.3",
    SubTitle = "ода шедевротайкон - nnhub",
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
    Aimbot = Window:AddTab({ Title = "Combat", Icon = "sword"}),
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
                if Tycoon:FindFirstChild("PurchasedObjects") then
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
                Content = "Medkit doesnt found.",
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
    Title = "Loop hide nickname",
    Description = "",
    Callback = function()
        game:GetService("RunService").RenderStepped:Connect(function()
            if game.Players.LocalPlayer.Character:FindFirstChild("Head"):FindFirstChild("NameTag") then
                game.Players.LocalPlayer.Character:FindFirstChild("Head"):FindFirstChild("NameTag"):Remove()
            end
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "Remove fall damage",
    Description = "",
    Callback = function()
        if game:GetService("ReplicatedStorage").ACS_Engine.Events:FindFirstChild("FDMG") then
            game:GetService("ReplicatedStorage").ACS_Engine.Events:FindFirstChild("FDMG"):Remove()

            Event = Instance.new("RemoteEvent")
            Event.Name = "FDMG"
            Event.Parent = game:GetService("ReplicatedStorage").ACS_Engine.Events
        end
    end
})

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
    for k,v in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") then
            return true
        end
    end
    
    return false
end

game:GetService("RunService").RenderStepped:Connect(function()
    nn_FOV.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
    nn_FOV.Visible = Options.Aimbot.Value

    if Options.Aimbot.Value then
        if isToolEquiped() and not game.Players.LocalPlayer.Character.Humanoid.Sit then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and isPlayerInCircle(player) and isRightMouseDown and table.find(FriendList, player.Name:lower()) == nil then
                    game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.Camera.CFrame.Position, player.Character[_G.nn_AimPart].Position)
                end
            end
        elseif game.Players.LocalPlayer.Character.Humanoid.Sit then
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
        nn_FOV.Radius = Value
    end
})

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

local HitboxExpander = Tabs.Aimbot:AddToggle("HitboxExpander", {Title = "Hitbox Expander", Default = false})

game:GetService("RunService").RenderStepped:Connect(function()
    if Options.HitboxExpander.Value then
        for _,Player in ipairs(game.Players:GetChildren()) do
            if Player ~= nil then
                if table.find(FriendList, Player.Name) == nil and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid").Health ~= 0 and Player ~= game.Players.LocalPlayer then
                    if true then
                        if Player.Character.Humanoid.SeatPart == nil then
                            Player.Character.HumanoidRootPart.Size = Vector3.new(_G.nn_HitboxSize, _G.nn_HitboxSize, _G.nn_HitboxSize)
                            Player.Character.HumanoidRootPart.Transparency = 0
                        else
                            Player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                            Player.Character.HumanoidRootPart.Transparency = 1
                        end
                    end
                end
            end
        end
    else
        for _,Player in ipairs(game.Players:GetChildren()) do
            if Player ~= nil then
                if table.find(FriendList, Player.Name) == nil and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid").Health ~= 0 and Player ~= game.Players.LocalPlayer then
                    Player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    Player.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end
    end
end)

local HitboxSize = Tabs.Aimbot:AddSlider("HitboxSize", {
    Title = "Hitbox Size",
    Description = "",
    Default = 2,
    Min = 1,
    Max = 25,
    Rounding = 1,
    Callback = function(Value)
        _G.nn_HitboxSize = Value
    end
})


local CrateFarm = Tabs.Farm:AddToggle("CrateFarm", {Title = "Crate Farm (Buggy)", Default = false})

CrateFarm:OnChanged(function()
    if Options.CrateFarm.Value then
        while wait() do
            for Index, Tycoon in ipairs(game.Workspace.Tycoon.Tycoons:GetChildren()) do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Tycoon.Floor.FloorOrigin.CFrame
                game.Players.LocalPlayer.Character:TranslateBy(Vector3.new(0, 1000, 0))
                wait(.2)
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
                wait(5)
        
                for k,v in ipairs(workspace["Game Systems"]["Crate Workspace"]:GetChildren()) do
                    game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Workspace.CurrentCamera.CameraSubject = v
                    wait(3)
                    fireproximityprompt(v.StealPrompt)
                    wait(2)
                    if v:FindFirstChild(v.StealPrompt) then
                        fireproximityprompt(v.StealPrompt)
                        wait(2)
                    end
                    game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Tycoon.Tycoons[game.Players.LocalPlayer.leaderstats.Team.Value].Floor.FloorOrigin.CFrame
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Players.LocalPlayer.Character:TranslateBy(Vector3.new(0, 1000, 0))
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    wait(.25)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    wait(5)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Tycoon.Tycoons[game.Players.LocalPlayer.leaderstats.Team.Value].Essentials["Oil Collector"].CratePromptPart.CFrame
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Workspace.CurrentCamera.CameraSubject = game.Workspace.Tycoon.Tycoons[game.Players.LocalPlayer.leaderstats.Team.Value].Essentials["Oil Collector"].CratePromptPart.SellPrompt
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    wait(.5)
                    fireproximityprompt(game.Workspace.Tycoon.Tycoons[game.Players.LocalPlayer.leaderstats.Team.Value].Essentials["Oil Collector"].CratePromptPart.SellPrompt)
                    wait(2)
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        Fluent:Notify({
                            Title = "Crate Farm",
                            Content = "Crate farm has been stopped",
                            SubContent = "",
                            Duration = 2
                        })
                        return
                    end
                    game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
                end
    
                if not Options.CrateFarm.Value then
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health == 0 or Options.CrateFarm.Value == false then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
                        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                    end

                    break
                end
            end
        end
    end
end)

Window:SelectTab(1)
