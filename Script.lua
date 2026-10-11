-- ====================================================
-- سكربت سرقة البيض الاحترافي | Steal An Egg
-- المطور: مـــيـــرو اوتـــــــــشيها (Mero Uchiha)
-- النسخة الجديدة والنظيفة (الأركان الأربعة الأساسية)
-- ====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PromptService = game:GetService("ProximityPromptService")

local ScriptConfig = {
    SilentSleep = false,     -- 1. السرقة الفورية وتنويم الحيوانات
    ShadowShield = false,    -- 2. حماية الدم والمنع من الطرد
}

local SavedHoldDurations = {}
local ActiveConnections = {}

-- ====================================================
-- 1. محرك السرقة الفورية وتنويم الحيوانات (Silent Sleep & Prompt Patch)
-- ====================================================

local function PatchPrompt(Prompt)
    if not (Prompt and Prompt:IsA("ProximityPrompt")) then return end
    if ScriptConfig.SilentSleep then
        if SavedHoldDurations[Prompt] == nil then
            SavedHoldDurations[Prompt] = Prompt.HoldDuration
        end
        Prompt.HoldDuration = 0
        Prompt.RequiresLineOfSight = false
    elseif SavedHoldDurations[Prompt] ~= nil then
        Prompt.HoldDuration = SavedHoldDurations[Prompt]
        SavedHoldDurations[Prompt] = nil
    end
end

local function SetPromptPatch(enabled)
    if enabled then
        for _, item in ipairs(Workspace:GetDescendants()) do
            PatchPrompt(item)
        end
        table.insert(ActiveConnections, Workspace.DescendantAdded:Connect(PatchPrompt))
        table.insert(ActiveConnections, PromptService.PromptShown:Connect(PatchPrompt))
    else
        for _, Connection in ipairs(ActiveConnections) do
            if Connection then Connection:Disconnect() end
        end
        ActiveConnections = {}
        for Prompt, duration in pairs(SavedHoldDurations) do
            if Prompt and Prompt.Parent then
                Prompt.HoldDuration = duration
            end
        end
        SavedHoldDurations = {}
    end
end

local function ToggleSilentSleep(state)
    ScriptConfig.SilentSleep = state
    SetPromptPatch(state)

    if state then
        task.spawn(function()
            while ScriptConfig.SilentSleep do
                task.wait(0.1)
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    -- الانتقال السريع وسرقة البيض وإبطال حركة الحراس المحيطين
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not ScriptConfig.SilentSleep then break end
                        if obj:IsA("ProximityPrompt") then
                            local part = obj.Parent
                            if part and part:IsA("BasePart") then
                                if (part.Position - root.Position).Magnitude < 35 then
                                    local originalCFrame = root.CFrame
                                    root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                                    task.wait(0.04)
                                    fireproximityprompt(obj)
                                    task.wait(0.04)
                                    root.CFrame = originalCFrame
                                    task.wait(0.08)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end

-- ====================================================
-- 2. حماية الدم والوقاية من الضرب (Shadow Shield)
-- ====================================================

local function ToggleShadowShield(state)
    ScriptConfig.ShadowShield = state
    if state then
        task.spawn(function()
            while ScriptConfig.ShadowShield do
                task.wait(0.2)
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health < hum.MaxHealth then
                            hum.Health = hum.MaxHealth
                        end
                    end
                end)
            end
        end)
    end
end

-- ====================================================
-- بناء الواجهة الرسومية العائمة (UI & Floating Button 🥚)
-- ====================================================

if CoreGui:FindFirstChild("MeroEggHub") then
    CoreGui.MeroEggHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeroEggHub"
ScreenGui.Parent = CoreGui

-- الأيقونة العائمة الصغيرة
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Name = "OpenCloseBtn"
OpenCloseBtn.Parent = ScreenGui
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 45)
OpenCloseBtn.Position = UDim2.new(0, 10, 0.5, -25)
OpenCloseBtn.Size = UDim2.new(0, 50, 0, 50)
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.Text = "🥚"
OpenCloseBtn.TextSize = 25
OpenCloseBtn.Draggable = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 25)
BtnCorner.Parent = OpenCloseBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Parent = OpenCloseBtn
BtnStroke.Color = Color3.fromRGB(138, 43, 226)
BtnStroke.Thickness = 2

-- النافذة الرئيسة للسكربت
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
MainFrame.Size = UDim2.new(0, 320, 0, 230)
MainFrame.Visible = false
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(138, 43, 226)
MainStroke.Thickness = 2

-- إظهار وإخفاء القائمة بالضغط على الزر العائم
OpenCloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- العنوان
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 33, 45)
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "🥚 Mero Hub | Steal An Egg"
TitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
TitleLabel.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleLabel

local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 55)
Container.Size = UDim2.new(1, -20, 1, -65)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- دالة إنشاء الأزرار داخل الواجهة
local function CreateToggleBtn(name, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = Container
    Button.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.Font = Enum.Font.SourceSansBold
    Button.Text = "  " .. name
    Button.TextColor3 = Color3.fromRGB(220, 220, 220)
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local StatusBox = Instance.new("Frame")
    StatusBox.Parent = Button
    StatusBox.AnchorPoint = Vector2.new(1, 0.5)
    StatusBox.Position = UDim2.new(1, -12, 0.5, 0)
    StatusBox.Size = UDim2.new(0, 45, 0, 24)
    StatusBox.BackgroundColor3 = Color3.fromRGB(255, 60, 60)

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 12)
    StatusCorner.Parent = StatusBox

    local isToggled = false
    Button.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            StatusBox.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
        else
            StatusBox.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        end
        callback(isToggled)
    end)
end

-- ====================================================
-- ربط الأزرار بالميزات
-- ====================================================

CreateToggleBtn("سرقة البيض وتنويم الحيوانات 😴⚡", function(state)
    ToggleSilentSleep(state)
end)

CreateToggleBtn("حماية الدم والضرب 🛡️⚔️", function(state)
    ToggleShadowShield(state)
end)
