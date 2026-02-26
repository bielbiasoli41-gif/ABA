-- ABA PROTEÇÃO - Godzilla Hub
return function(ContentContainer, LocalPlayer, RunService)
    
    local godModeEnabled = true
    local godModeConnection = nil
    local antiFlingEnabled = false
    local antiVoidEnabled = false
    local antiLagEnabled = false
    local antiRouboEnabled = false
    
    local function createSpacer(height, parent)
        local spacer = Instance.new("Frame")
        spacer.Size = UDim2.new(1, 0, 0, height)
        spacer.BackgroundTransparency = 1
        spacer.Parent = parent
        return spacer
    end
    
    local function createToggle(text, parent, defaultState, callback)
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(1, -20, 0, 40)
        toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggle.BorderSizePixel = 0
        toggle.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = toggle
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggle
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0.3, -10, 1, 0)
        status.Position = UDim2.new(0.7, 0, 0, 0)
        status.BackgroundTransparency = 1
        status.Text = defaultState and "On" or "Off"
        status.TextColor3 = defaultState and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        status.Font = Enum.Font.GothamBold
        status.TextSize = 14
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.Parent = toggle
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = toggle
        
        button.MouseButton1Click:Connect(function()
            local newState = callback()
            status.Text = newState and "On" or "Off"
            status.TextColor3 = newState and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        end)
        
        return toggle, status
    end
    
    -- GodMode Melhorado (ativado automaticamente)
    local function enableGodMode()
        if godModeConnection then
            godModeConnection:Disconnect()
        end
        
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not godModeEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                -- Proteção 1: Desabilitar estados de morte
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                
                -- Proteção 2: Manter vida no máximo
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Proteção 3: Manter HumanoidRootPart sem anchor
                hrp.Anchored = false
            end
        end)
    end
    
    enableGodMode()
    
    createToggle("GodMode", ContentContainer, true, function()
        godModeEnabled = not godModeEnabled
        if godModeEnabled then
            enableGodMode()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Godzilla Hub",
                Text = "GodMode ativado!",
                Duration = 2
            })
        else
            if godModeConnection then
                godModeConnection:Disconnect()
                godModeConnection = nil
            end
            
            -- Reativar estados normais
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = LocalPlayer.Character.Humanoid
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "Godzilla Hub",
                Text = "GodMode desativado!",
                Duration = 2
            })
        end
        return godModeEnabled
    end)
    
    createSpacer(10, ContentContainer)
    
    -- Anti Fling
    local antiFlingConnection = nil
    createToggle("Anti Fling", ContentContainer, false, function()
        antiFlingEnabled = not antiFlingEnabled
        if antiFlingEnabled then
            antiFlingConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            if antiFlingConnection then
                antiFlingConnection:Disconnect()
            end
        end
        return antiFlingEnabled
    end)
    
    createSpacer(10, ContentContainer)
    
    -- Anti Void
    local antiVoidConnection = nil
    local lastSafePosition = nil
    createToggle("Anti Void", ContentContainer, false, function()
        antiVoidEnabled = not antiVoidEnabled
        if antiVoidEnabled then
            antiVoidConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    
                    if hrp.Position.Y > -50 then
                        lastSafePosition = hrp.CFrame
                    end
                    
                    if hrp.Position.Y < -50 and lastSafePosition then
                        hrp.CFrame = lastSafePosition
                    end
                end
            end)
        else
            if antiVoidConnection then
                antiVoidConnection:Disconnect()
            end
        end
        return antiVoidEnabled
    end)
    
    createSpacer(10, ContentContainer)
    
    -- Anti Lag
    createToggle("Anti Lag", ContentContainer, false, function()
        antiLagEnabled = not antiLagEnabled
        if antiLagEnabled then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
        return antiLagEnabled
    end)
    
    createSpacer(10, ContentContainer)
    
    -- Anti Roubo (Anti Ragdoll)
    local antiRouboConnection = nil
    createToggle("Anti Roubo", ContentContainer, false, function()
        antiRouboEnabled = not antiRouboEnabled
        if antiRouboEnabled then
            antiRouboConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local humanoid = LocalPlayer.Character.Humanoid
                    
                    if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end
            end)
        else
            if antiRouboConnection then
                antiRouboConnection:Disconnect()
            end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end
        end
        return antiRouboEnabled
    end)
    
    print("Aba Proteção carregada!")
end
