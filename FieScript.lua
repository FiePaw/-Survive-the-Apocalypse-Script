--[[
    FieScript v5.5 - Blutiger (English)
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adjustBackpackRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Tools") and ReplicatedStorage.Remotes.Tools:FindFirstChild("AdjustBackpack")
local pickUpItemRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Interaction") and ReplicatedStorage.Remotes.Interaction:FindFirstChild("PickUpItem")

local useItemRemote = nil
local function findUseRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end
    for _, name in ipairs({"UseItem","Use","Interact","EquipItem","Consume","Activate"}) do
        local r = remotes:FindFirstChild(name, true)
        if r then useItemRemote = r return end
    end
end
findUseRemote()

-- GUI Container
local guiContainer = CoreGui
local ok = pcall(function() return CoreGui:FindFirstChild("FieScript") end)
if not ok then guiContainer = LocalPlayer:WaitForChild("PlayerGui") end

-- ========== Theme Color ==========
local themeColor = Color3.fromRGB(0, 80, 200)
local themeCallbacks = {}
local function onThemeChange(cb) table.insert(themeCallbacks, cb) end
local function setTheme(color)
    themeColor = color
    for _, cb in ipairs(themeCallbacks) do pcall(cb, color) end
end

-- ========== Main GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FieScript"
ScreenGui.Parent = guiContainer
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- ========== HUD ScreenGui (separate — never hides with Insert) ==========
local HudScreenGui = Instance.new("ScreenGui")
HudScreenGui.Name = "FieScript_HUD"
HudScreenGui.Parent = guiContainer
HudScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HudScreenGui.ResetOnSpawn = false
HudScreenGui.DisplayOrder = 10

-- ========== HUD ==========
local HudFrame = Instance.new("Frame")
HudFrame.Name = "HUD"
HudFrame.Size = UDim2.new(0, 180, 0, 80)
HudFrame.Position = UDim2.new(0, 10, 1, -100)
HudFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
HudFrame.BorderSizePixel = 2
HudFrame.BorderColor3 = themeColor
HudFrame.Parent = HudScreenGui
onThemeChange(function(c) HudFrame.BorderColor3 = c end)

local hudTitle = Instance.new("TextLabel")
hudTitle.Size = UDim2.new(1, 0, 0, 18)
hudTitle.BackgroundTransparency = 1
hudTitle.Text = "FieScript"
hudTitle.TextColor3 = themeColor
hudTitle.Font = Enum.Font.GothamBold
hudTitle.TextSize = 12
hudTitle.Parent = HudFrame
onThemeChange(function(c) hudTitle.TextColor3 = c end)

local hudLine = Instance.new("Frame")
hudLine.Size = UDim2.new(1, 0, 0, 1)
hudLine.Position = UDim2.new(0, 0, 0, 18)
hudLine.BackgroundColor3 = themeColor
hudLine.BorderSizePixel = 0
hudLine.Parent = HudFrame
onThemeChange(function(c) hudLine.BackgroundColor3 = c end)

local function createHudRow(text, yPos)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 6, 0, yPos + 4)
    dot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dot.BorderSizePixel = 0
    dot.Parent = HudFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 16)
    label.Position = UDim2.new(0, 18, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = HudFrame
    return dot, label
end

local hudSpeedDot,  hudSpeedLabel  = createHudRow("Speed: Off",       22)
local hudPickupDot, hudPickupLabel = createHudRow("Auto Pickup: Off", 40)
local hudUseDot,    hudUseLabel    = createHudRow("Auto Use: Off",    58)

local function updateHud(dot, label, text, active)
    label.Text = text .. ": " .. (active and "On" or "Off")
    dot.BackgroundColor3 = active and themeColor or Color3.fromRGB(60, 60, 60)
end

-- ========== Main Frame ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 600)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = themeColor
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui
onThemeChange(function(c) MainFrame.BorderColor3 = c end)

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = themeColor
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = MainFrame
onThemeChange(function(c) Shadow.ImageColor3 = c end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local BlueLine = Instance.new("Frame")
BlueLine.Size = UDim2.new(1, 0, 0, 2)
BlueLine.Position = UDim2.new(0, 0, 1, -2)
BlueLine.BackgroundColor3 = themeColor
BlueLine.BorderSizePixel = 0
BlueLine.Parent = TopBar
onThemeChange(function(c) BlueLine.BackgroundColor3 = c end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FieScript v5.5"
Title.TextColor3 = themeColor
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = TopBar
onThemeChange(function(c) Title.TextColor3 = c end)

local CloseButton = Instance.new("ImageButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
CloseButton.BackgroundColor3 = themeColor
CloseButton.BorderSizePixel = 1
CloseButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.Image = "rbxassetid://10747383594"
CloseButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = TopBar
CloseButton.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)
onThemeChange(function(c) CloseButton.BackgroundColor3 = c end)

-- Drag
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 30)
StatusBar.Position = UDim2.new(0, 0, 1, -30)
StatusBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local BlueLineTop = Instance.new("Frame")
BlueLineTop.Size = UDim2.new(1, 0, 0, 2)
BlueLineTop.BackgroundColor3 = themeColor
BlueLineTop.BorderSizePixel = 0
BlueLineTop.Parent = StatusBar
onThemeChange(function(c) BlueLineTop.BackgroundColor3 = c end)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -15, 1, 0)
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Status: Ready"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.Parent = StatusBar

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 50)
TabContainer.Position = UDim2.new(0, 10, 0, 55)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local tabButtons, tabFrames = {}, {}
local tabs = {"Visuals", "Player", "Exploits", "Misc", "Info"}
local currentTab = "Visuals"

local function createTabButton(tabName, pos)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 130, 1, 0)
    button.Position = UDim2.new(0, (pos - 1) * 134, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    button.BorderSizePixel = 1
    button.BorderColor3 = themeColor
    button.Text = tabName
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Parent = TabContainer
    onThemeChange(function(c) if currentTab ~= tabName then button.BorderColor3 = c end end)
    button.MouseEnter:Connect(function()
        if currentTab ~= tabName then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play() end
    end)
    button.MouseLeave:Connect(function()
        if currentTab ~= tabName then TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play() end
    end)
    return button
end

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -170)
ContentContainer.Position = UDim2.new(0, 10, 0, 110)
ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ContentContainer.BorderSizePixel = 2
ContentContainer.BorderColor3 = themeColor
ContentContainer.Parent = MainFrame
onThemeChange(function(c) ContentContainer.BorderColor3 = c end)

for i, tabName in ipairs(tabs) do
    local btn = createTabButton(tabName, i)
    tabButtons[tabName] = btn
    local cf = Instance.new("ScrollingFrame")
    cf.Size = UDim2.new(1, -20, 1, -20)
    cf.Position = UDim2.new(0, 10, 0, 10)
    cf.BackgroundTransparency = 1
    cf.BorderSizePixel = 0
    cf.ScrollBarThickness = 8
    cf.ScrollBarImageColor3 = themeColor
    cf.CanvasSize = UDim2.new(0, 0, 0, 0)
    cf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    cf.Visible = false
    cf.Parent = ContentContainer
    tabFrames[tabName] = cf
    onThemeChange(function(c) cf.ScrollBarImageColor3 = c end)
end

tabFrames[currentTab].Visible = true
tabButtons[currentTab].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabButtons[currentTab].BorderColor3 = themeColor

for tabName, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        if currentTab == tabName then return end
        tabFrames[currentTab].Visible = false
        tabButtons[currentTab].BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        tabButtons[currentTab].BorderColor3 = themeColor
        currentTab = tabName
        tabFrames[currentTab].Visible = true
        tabButtons[currentTab].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        tabButtons[currentTab].BorderColor3 = themeColor
    end)
end

-- ========== Global State ==========
local connections = {}
local mobESPInstances, itemESPInstances = {}, {}
local originalValues = {walkSpeed = nil, infJumpActive = false}
local mobOptions = {ESP = false, Chams = false, Name = false, Distance = false}
local itemOptions = {ESP = false, Chams = false, Name = false, Distance = false}
local mobNames = {"Runner", "Crawler", "Riot", "Zombie"}
local itemNames = {
    "Bandage", "Barbed Wire", "Battery", "Battery Pack", "Beans", "Bloxiade", "Bloxy Cola",
    "Compound I", "Crowbar", "Dumbell", "Refined Fuel", "Fuel", "Grenade", "Knife",
    "Long Ammo", "Chips", "Medium Ammo", "Pistol Ammo", "Revolver", "Scrap",
    "Screws", "Shells", "Spatula", "Tray", "AC", "Satellite Dish", "Refined Metal",
    "Watch", "MRE", "TV", "Bucket"
}

-- Items stored in the game's CUSTOM inventory (not Roblox Backpack).
-- For these: only auto-collect if NOT already owned; never equip or fire a use remote.
local inventoryOnlyItems = {"Bandage", "Medkit"}

local autoUseItemNames = {
    "Bandage", "Medkit", "Beans", "Bloxiade", "Bloxy Cola",
    "Long Ammo", "Medium Ammo", "Pistol Ammo", "Shells"
}

local charactersFolder = Workspace:FindFirstChild("Characters")
local droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")

-- ========== Custom Inventory Check ==========
--[[
    ROOT CAUSE OF THE BUG:
    The game uses a custom inventory system (the slots panel shown in the screenshot:
    Backpack / Bat / Turret / Bandage). Items like Bandage and Medkit are stored
    somewhere under LocalPlayer as data/instances — NOT inside the Roblox
    LocalPlayer.Backpack service container.

    The old code checked:  backpack:FindFirstChild(name)
    That is the Roblox Backpack, which never contains these items, so the check
    always returned nil → the script treated the player as "not owning" the item
    every single tick → it spammed the pickup remote endlessly even with Bandage
    already in slot 4.

    THE FIX:
    isItemInCustomInventory() searches everywhere under LocalPlayer — including
    all common custom folder names — using FindFirstChild(name, true) (recursive).
    If the item exists anywhere as an Instance (e.g. a Tool, StringValue, or
    ObjectValue named "Bandage") the function returns true and the pickup is skipped.

    If the game stores inventory as pure data (IntValues, tables, etc.) with a
    different naming convention, this recursive search still covers the most common
    patterns. The `break` after one successful pickup also prevents multiple
    simultaneous pickup fires per tick.
]]
local function isItemInCustomInventory(itemName)
    -- Check character (equipped tool)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild(itemName) then return true end

    -- Recursive search through all of LocalPlayer's descendants.
    -- This covers Inventory/, Items/, Data/, PlayerData/, or any other
    -- custom folder the game uses to store the player's owned items.
    local found = LocalPlayer:FindFirstChild(itemName, true)
    if found then return true end

    return false
end

-- ========== ESP Helpers ==========
local function getItemMainPart(item)
    if item.PrimaryPart then return item.PrimaryPart end
    for _, c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then return c end end
end

local function removeMobESP(char)
    local esp = mobESPInstances[char]
    if not esp then return end
    if esp.Highlight then esp.Highlight:Destroy() end
    if esp.Billboard then esp.Billboard:Destroy() end
    if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
    mobESPInstances[char] = nil
end

local function removeItemESP(item)
    local esp = itemESPInstances[item]
    if not esp then return end
    if esp.Highlight then esp.Highlight:Destroy() end
    if esp.Billboard then esp.Billboard:Destroy() end
    if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
    itemESPInstances[item] = nil
end

local function createMobESP(char)
    if not char:IsA("Model") or mobESPInstances[char] then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then return end
    local t = {}
    if mobOptions.Chams then
        local h = Instance.new("Highlight")
        h.Adornee = char h.FillColor = Color3.fromRGB(220, 0, 0) h.FillTransparency = 0.3
        h.OutlineColor = Color3.fromRGB(255, 185, 185) h.OutlineTransparency = 0.8 h.Parent = char
        t.Highlight = h
    end
    if mobOptions.Name or mobOptions.Distance then
        local bb = Instance.new("BillboardGui")
        bb.Adornee = root bb.Size = UDim2.new(0, 200, 0, 50) bb.StudsOffset = Vector3.new(0, 3, 0) bb.AlwaysOnTop = true bb.Parent = char
        local f = Instance.new("Frame") f.Size = UDim2.new(1, 0, 1, 0) f.BackgroundTransparency = 1 f.Parent = bb
        local nl = Instance.new("TextLabel") nl.Size = UDim2.new(1, 0, 0.5, 0) nl.BackgroundTransparency = 1
        nl.Text = char.Name nl.TextColor3 = Color3.fromRGB(255, 200, 200) nl.TextStrokeTransparency = 0.3
        nl.Font = Enum.Font.GothamBold nl.TextSize = 14 nl.Visible = mobOptions.Name nl.Parent = f
        local dl = Instance.new("TextLabel") dl.Size = UDim2.new(1, 0, 0.5, 0) dl.Position = UDim2.new(0, 0, 0.5, 0)
        dl.BackgroundTransparency = 1 dl.Text = "0m" dl.TextColor3 = Color3.fromRGB(220, 220, 220)
        dl.TextStrokeTransparency = 0.3 dl.Font = Enum.Font.Gotham dl.TextSize = 12 dl.Visible = mobOptions.Distance dl.Parent = f
        t.Billboard = bb
        local conn conn = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent then conn:Disconnect() return end
            if dl.Visible then
                local mc = LocalPlayer.Character
                local mr = mc and (mc:FindFirstChild("HumanoidRootPart") or mc:FindFirstChild("Torso"))
                if mr then dl.Text = math.floor((mr.Position - root.Position).Magnitude) .. "m" end
            end
        end)
        t.DistanceConnection = conn table.insert(connections, conn)
    end
    mobESPInstances[char] = t
end

local function createItemESP(item)
    if not item:IsA("Model") or itemESPInstances[item] then return end
    local mp = getItemMainPart(item) if not mp then return end
    local t = {}
    if itemOptions.Chams then
        local h = Instance.new("Highlight")
        h.Adornee = item h.FillColor = Color3.fromRGB(255, 0, 255) h.FillTransparency = 0.4
        h.OutlineColor = Color3.fromRGB(200, 180, 255) h.OutlineTransparency = 0.8 h.Parent = item
        t.Highlight = h
    end
    if itemOptions.Name or itemOptions.Distance then
        local bb = Instance.new("BillboardGui")
        bb.Adornee = mp bb.Size = UDim2.new(0, 200, 0, 50) bb.StudsOffset = Vector3.new(0, 2, 0) bb.AlwaysOnTop = true bb.Parent = item
        local f = Instance.new("Frame") f.Size = UDim2.new(1, 0, 1, 0) f.BackgroundTransparency = 1 f.Parent = bb
        local nl = Instance.new("TextLabel") nl.Size = UDim2.new(1, 0, 0.5, 0) nl.BackgroundTransparency = 1
        nl.Text = item.Name nl.TextColor3 = Color3.fromRGB(200, 255, 200) nl.TextStrokeTransparency = 0.3
        nl.Font = Enum.Font.GothamBold nl.TextSize = 14 nl.Visible = itemOptions.Name nl.Parent = f
        local dl = Instance.new("TextLabel") dl.Size = UDim2.new(1, 0, 0.5, 0) dl.Position = UDim2.new(0, 0, 0.5, 0)
        dl.BackgroundTransparency = 1 dl.Text = "0m" dl.TextColor3 = Color3.fromRGB(220, 220, 220)
        dl.TextStrokeTransparency = 0.3 dl.Font = Enum.Font.Gotham dl.TextSize = 12 dl.Visible = itemOptions.Distance dl.Parent = f
        t.Billboard = bb
        local conn conn = RunService.RenderStepped:Connect(function()
            if not item or not item.Parent then conn:Disconnect() return end
            if dl.Visible then
                local mc = LocalPlayer.Character
                local mr = mc and (mc:FindFirstChild("HumanoidRootPart") or mc:FindFirstChild("Torso"))
                if mr then dl.Text = math.floor((mr.Position - mp.Position).Magnitude) .. "m" end
            end
        end)
        t.DistanceConnection = conn table.insert(connections, conn)
    end
    itemESPInstances[item] = t
end

local function refreshMobESP()
    for c in pairs(mobESPInstances) do removeMobESP(c) end
    if not mobOptions.ESP or not charactersFolder then return end
    for _, c in ipairs(charactersFolder:GetChildren()) do
        if table.find(mobNames, c.Name) then createMobESP(c) end
    end
end

local function refreshItemESP()
    for i in pairs(itemESPInstances) do removeItemESP(i) end
    if not itemOptions.ESP or not droppedItemsFolder then return end
    for _, c in ipairs(droppedItemsFolder:GetChildren()) do
        if table.find(itemNames, c.Name) then createItemESP(c) end
    end
end

if charactersFolder then
    table.insert(connections, charactersFolder.ChildAdded:Connect(function(c)
        if mobOptions.ESP and table.find(mobNames, c.Name) then createMobESP(c) end
    end))
    table.insert(connections, charactersFolder.ChildRemoved:Connect(removeMobESP))
end
if droppedItemsFolder then
    table.insert(connections, droppedItemsFolder.ChildAdded:Connect(function(c)
        if itemOptions.ESP and table.find(itemNames, c.Name) then createItemESP(c) end
    end))
    table.insert(connections, droppedItemsFolder.ChildRemoved:Connect(removeItemESP))
end

-- ========== GUI Helpers ==========
local function makeToggleBtn(parent, text, init, cb, yPos, width)
    width = width or 160
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = init and Color3.fromRGB(0, 50, 150) or Color3.fromRGB(20, 20, 20)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = themeColor
    btn.Text = text .. ": " .. (init and "On" or "Off")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = parent
    onThemeChange(function(c) btn.BorderColor3 = c end)
    local nc = btn.BackgroundColor3
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = nc:Lerp(Color3.fromRGB(0, 80, 200), 0.3)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = nc}):Play() end)
    local state = init
    local function apply()
        state = not state
        btn.Text = text .. ": " .. (state and "On" or "Off")
        nc = state and Color3.fromRGB(0, 60, 160) or Color3.fromRGB(20, 20, 20)
        btn.BackgroundColor3 = nc
        cb(state)
    end
    btn.MouseButton1Click:Connect(apply)
    return btn, state, apply
end

local function makeGroup(parent, title, yOff, h)
    local g = Instance.new("Frame")
    g.Size = UDim2.new(1, -20, 0, h)
    g.Position = UDim2.new(0, 10, 0, yOff)
    g.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    g.BorderSizePixel = 2
    g.BorderColor3 = themeColor
    g.Parent = parent
    onThemeChange(function(c) g.BorderColor3 = c end)
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -20, 0, 30) tl.Position = UDim2.new(0, 10, 0, 5)
    tl.BackgroundTransparency = 1 tl.Text = title tl.TextColor3 = Color3.fromRGB(220, 220, 220)
    tl.Font = Enum.Font.GothamBold tl.TextSize = 16 tl.TextXAlignment = Enum.TextXAlignment.Left tl.Parent = g
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1, -20, 0, 2) ln.Position = UDim2.new(0, 10, 0, 35)
    ln.BackgroundColor3 = themeColor ln.BorderSizePixel = 0 ln.Parent = g
    onThemeChange(function(c) ln.BackgroundColor3 = c end)
    local bc = Instance.new("Frame")
    bc.Size = UDim2.new(1, -20, 1, -45) bc.Position = UDim2.new(0, 10, 0, 40)
    bc.BackgroundTransparency = 1 bc.Parent = g
    return g, bc
end

local function makeKeybindBtn(parent, labelText, defaultKey, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 26)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = themeColor
    btn.Text = labelText .. " [" .. tostring(defaultKey):gsub("Enum.KeyCode.", "") .. "]  (click to rebind)"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = parent
    onThemeChange(function(c) btn.BorderColor3 = c end)
    return btn
end

local function makeRadiusInput(parent, yPos, defaultVal)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 65, 0, 26) lbl.Position = UDim2.new(0, 5, 0, yPos)
    lbl.BackgroundTransparency = 1 lbl.Text = "Radius:" lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.Gotham lbl.TextSize = 13 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = parent
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(0, 55, 0, 26) inp.Position = UDim2.new(0, 73, 0, yPos)
    inp.BackgroundColor3 = Color3.fromRGB(20, 20, 20) inp.BorderSizePixel = 1 inp.BorderColor3 = themeColor
    inp.Text = tostring(defaultVal) inp.TextColor3 = Color3.fromRGB(255, 255, 255)
    inp.Font = Enum.Font.Gotham inp.TextSize = 13 inp.Parent = parent
    onThemeChange(function(c) inp.BorderColor3 = c end)
    return inp
end

-- ========== Visuals Tab ==========
local visuals = tabFrames["Visuals"]
local yOff = 5

local mgH = 45 + 4 * 37
local mg, mc = makeGroup(visuals, "Mob ESP", yOff, mgH) yOff = yOff + mgH + 10
makeToggleBtn(mc, "Mob ESP", false, function(s) mobOptions.ESP = s refreshMobESP() StatusText.Text = s and "Mob ESP enabled" or "Mob ESP disabled" end, 0, 140)
local sy = 40
makeToggleBtn(mc, "Chams", false, function(s) mobOptions.Chams = s refreshMobESP() end, sy, 100) sy = sy + 37
makeToggleBtn(mc, "Name",  false, function(s) mobOptions.Name  = s refreshMobESP() end, sy, 100) sy = sy + 37
makeToggleBtn(mc, "Distance", false, function(s) mobOptions.Distance = s refreshMobESP() end, sy, 100)

local igH = 45 + 4 * 37
local ig, ic = makeGroup(visuals, "Item ESP", yOff, igH) yOff = yOff + igH + 10
makeToggleBtn(ic, "Item ESP", false, function(s) itemOptions.ESP = s refreshItemESP() StatusText.Text = s and "Item ESP enabled" or "Item ESP disabled" end, 0, 140)
sy = 40
makeToggleBtn(ic, "Chams",    false, function(s) itemOptions.Chams    = s refreshItemESP() end, sy, 100) sy = sy + 37
makeToggleBtn(ic, "Name",     false, function(s) itemOptions.Name     = s refreshItemESP() end, sy, 100) sy = sy + 37
makeToggleBtn(ic, "Distance", false, function(s) itemOptions.Distance = s refreshItemESP() end, sy, 100)

-- ========== Player Tab ==========
local playerTab = tabFrames["Player"]
yOff = 5

local speedState = false
local speedKeyBind = Enum.KeyCode.Q
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, 180, 0, 32) speedBtn.Position = UDim2.new(0, 5, 0, yOff)
speedBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) speedBtn.BorderSizePixel = 1 speedBtn.BorderColor3 = themeColor
speedBtn.Text = "Speed: Off" speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Font = Enum.Font.GothamMedium speedBtn.TextSize = 14 speedBtn.Parent = playerTab
onThemeChange(function(c) speedBtn.BorderColor3 = c end)

local snc = speedBtn.BackgroundColor3
speedBtn.MouseEnter:Connect(function() TweenService:Create(speedBtn, TweenInfo.new(0.2), {BackgroundColor3 = snc:Lerp(Color3.fromRGB(0, 80, 200), 0.3)}):Play() end)
speedBtn.MouseLeave:Connect(function() TweenService:Create(speedBtn, TweenInfo.new(0.2), {BackgroundColor3 = snc}):Play() end)

local function applySpeed(active)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if active then
        originalValues.walkSpeed = hum.WalkSpeed < 50 and hum.WalkSpeed or (originalValues.walkSpeed or 16)
        hum.WalkSpeed = 50
        speedBtn.Text = "Speed: On" snc = Color3.fromRGB(0, 60, 160)
        StatusText.Text = "Speed enabled"
    else
        hum.WalkSpeed = originalValues.walkSpeed or 16
        speedBtn.Text = "Speed: Off" snc = Color3.fromRGB(20, 20, 20)
        StatusText.Text = "Speed disabled"
    end
    speedBtn.BackgroundColor3 = snc
    updateHud(hudSpeedDot, hudSpeedLabel, "Speed", active)
end

local function toggleSpeed()
    speedState = not speedState
    applySpeed(speedState)
end
speedBtn.MouseButton1Click:Connect(toggleSpeed)
yOff = yOff + 40

local speedKeyBtn = makeKeybindBtn(playerTab, "Speed Key:", speedKeyBind, yOff)
local listeningForSpeedKey = false
speedKeyBtn.MouseButton1Click:Connect(function()
    listeningForSpeedKey = true speedKeyBtn.Text = "Press any key..."
    speedKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 30, 100)
end)
yOff = yOff + 34

-- Auto-restore speed
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not speedState then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed < 50 then hum.WalkSpeed = 50 end
end))

local _ijBtn, _ijSt, toggleInfJump = makeToggleBtn(playerTab, "Inf Jump", false, function(s)
    originalValues.infJumpActive = s
    StatusText.Text = s and "Inf Jump enabled" or "Inf Jump disabled"
end, yOff, 180)

table.insert(connections, UserInputService.JumpRequest:Connect(function()
    if not originalValues.infJumpActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

-- ========== Exploits Tab ==========
local exploits = tabFrames["Exploits"]
yOff = 5

-- ---------- AUTO PICKUP ----------
local apGroupH = 45 + 30 + 30 + 30 + 30 + 160 + 10
local apGroup, apCont = makeGroup(exploits, "Auto Pickup", yOff, apGroupH)
yOff = yOff + apGroupH + 10

local autoPickupActive = false
local autoPickupKeyBind = Enum.KeyCode.X
local startAutoPickup
local _apBtn, _apSt, toggleAutoPickupExt = makeToggleBtn(apCont, "Auto Pickup", false, function(s)
    autoPickupActive = s
    updateHud(hudPickupDot, hudPickupLabel, "Auto Pickup", s)
    if s then StatusText.Text = "Auto Pickup started" startAutoPickup()
    else StatusText.Text = "Auto Pickup stopped" end
end, 0, 160)

local apKeyBtn = makeKeybindBtn(apCont, "Pickup Key:", autoPickupKeyBind, 37)
local listeningForPickupKey = false
apKeyBtn.MouseButton1Click:Connect(function()
    listeningForPickupKey = true apKeyBtn.Text = "Press any key..."
    apKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 30, 100)
end)

local apRadiusInput = makeRadiusInput(apCont, 68, 15)

local apAllActive = false
local apAllBtn = Instance.new("TextButton")
apAllBtn.Size = UDim2.new(0, 200, 0, 26) apAllBtn.Position = UDim2.new(0, 5, 0, 99)
apAllBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) apAllBtn.BorderSizePixel = 1 apAllBtn.BorderColor3 = themeColor
apAllBtn.Text = "All Items Allowed: Off" apAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
apAllBtn.Font = Enum.Font.GothamMedium apAllBtn.TextSize = 13 apAllBtn.Parent = apCont
onThemeChange(function(c) apAllBtn.BorderColor3 = c end)
apAllBtn.MouseButton1Click:Connect(function()
    apAllActive = not apAllActive
    apAllBtn.BackgroundColor3 = apAllActive and Color3.fromRGB(0, 50, 150) or Color3.fromRGB(20, 20, 20)
    apAllBtn.Text = "All Items Allowed: " .. (apAllActive and "On (checked = blacklist)" or "Off")
end)

local apListFrame = Instance.new("ScrollingFrame")
apListFrame.Size = UDim2.new(1, -10, 0, 155) apListFrame.Position = UDim2.new(0, 5, 0, 130)
apListFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) apListFrame.BorderSizePixel = 1 apListFrame.BorderColor3 = themeColor
apListFrame.ScrollBarThickness = 6 apListFrame.ScrollBarImageColor3 = themeColor
apListFrame.CanvasSize = UDim2.new(0, 0, 0, #itemNames * 27) apListFrame.Parent = apCont
onThemeChange(function(c) apListFrame.BorderColor3 = c apListFrame.ScrollBarImageColor3 = c end)

local apItemChecks = {}
for i, name in ipairs(itemNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 24) btn.Position = UDim2.new(0, 5, 0, (i - 1) * 26)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) btn.BorderSizePixel = 1 btn.BorderColor3 = themeColor
    btn.Text = name btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham btn.TextSize = 13 btn.TextXAlignment = Enum.TextXAlignment.Left btn.Parent = apListFrame
    onThemeChange(function(c) btn.BorderColor3 = c end)
    local sel = false
    btn.MouseButton1Click:Connect(function()
        sel = not sel btn.BackgroundColor3 = sel and Color3.fromRGB(0, 50, 150) or Color3.fromRGB(20, 20, 20)
    end)
    apItemChecks[name] = function() return sel end
end

local autoPickupConn = nil
startAutoPickup = function()
    if autoPickupConn then autoPickupConn:Disconnect() end
    autoPickupConn = RunService.Heartbeat:Connect(function()
        if not autoPickupActive then return end
        local char = LocalPlayer.Character if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart") if not root then return end
        local radius = tonumber(apRadiusInput.Text) or 15
        local pos = root.Position
        if not droppedItemsFolder then return end
        for _, item in ipairs(droppedItemsFolder:GetChildren()) do
            if not autoPickupActive then break end
            local isChecked = apItemChecks[item.Name] and apItemChecks[item.Name]()
            local shouldPickup = apAllActive and not isChecked or (not apAllActive and isChecked)
            if not shouldPickup then continue end
            local mp = item.PrimaryPart or getItemMainPart(item)
            if mp and (mp.Position - pos).Magnitude <= radius then
                if adjustBackpackRemote then adjustBackpackRemote:FireServer(item)
                elseif pickUpItemRemote then pickUpItemRemote:FireServer(item) end
                task.wait(0.05)
            end
        end
    end)
end

-- ---------- AUTO USE ----------
local auGroupH = 45 + 30 + 30 + 30 + 30 + #autoUseItemNames * 27 + 20
local auGroup, auCont = makeGroup(exploits, "Auto Use", yOff, auGroupH)
yOff = yOff + auGroupH + 10

local autoUseActive = false
local autoUseKeyBind = Enum.KeyCode.C
local _auBtn, _auSt, toggleAutoUseExt = makeToggleBtn(auCont, "Auto Use", false, function(s)
    autoUseActive = s
    updateHud(hudUseDot, hudUseLabel, "Auto Use", s)
    StatusText.Text = s and "Auto Use started" or "Auto Use stopped"
end, 0, 160)

local auKeyBtn = makeKeybindBtn(auCont, "Use Key:", autoUseKeyBind, 37)
local listeningForUseKey = false
auKeyBtn.MouseButton1Click:Connect(function()
    listeningForUseKey = true auKeyBtn.Text = "Press any key..."
    auKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 30, 100)
end)

local auRadiusInput = makeRadiusInput(auCont, 68, 10)

local auAllActive = false
local auAllBtn = Instance.new("TextButton")
auAllBtn.Size = UDim2.new(0, 200, 0, 26) auAllBtn.Position = UDim2.new(0, 5, 0, 99)
auAllBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) auAllBtn.BorderSizePixel = 1 auAllBtn.BorderColor3 = themeColor
auAllBtn.Text = "All Items Allowed: Off" auAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
auAllBtn.Font = Enum.Font.GothamMedium auAllBtn.TextSize = 13 auAllBtn.Parent = auCont
onThemeChange(function(c) auAllBtn.BorderColor3 = c end)
auAllBtn.MouseButton1Click:Connect(function()
    auAllActive = not auAllActive
    auAllBtn.BackgroundColor3 = auAllActive and Color3.fromRGB(0, 50, 150) or Color3.fromRGB(20, 20, 20)
    auAllBtn.Text = "All Items Allowed: " .. (auAllActive and "On (checked = blacklist)" or "Off")
end)

local auListFrame = Instance.new("ScrollingFrame")
auListFrame.Size = UDim2.new(1, -10, 0, #autoUseItemNames * 27) auListFrame.Position = UDim2.new(0, 5, 0, 130)
auListFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) auListFrame.BorderSizePixel = 1 auListFrame.BorderColor3 = themeColor
auListFrame.ScrollBarThickness = 6 auListFrame.ScrollBarImageColor3 = themeColor
auListFrame.CanvasSize = UDim2.new(0, 0, 0, #autoUseItemNames * 27) auListFrame.Parent = auCont
onThemeChange(function(c) auListFrame.BorderColor3 = c auListFrame.ScrollBarImageColor3 = c end)

local auItemChecks = {}
for i, name in ipairs(autoUseItemNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 24) btn.Position = UDim2.new(0, 5, 0, (i - 1) * 26)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) btn.BorderSizePixel = 1 btn.BorderColor3 = themeColor
    btn.Text = name btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham btn.TextSize = 13 btn.TextXAlignment = Enum.TextXAlignment.Left btn.Parent = auListFrame
    onThemeChange(function(c) btn.BorderColor3 = c end)
    local sel = false
    btn.MouseButton1Click:Connect(function()
        sel = not sel btn.BackgroundColor3 = sel and Color3.fromRGB(0, 50, 150) or Color3.fromRGB(20, 20, 20)
    end)
    auItemChecks[name] = function() return sel end
end

--[[
    AUTO USE LOGIC v5.5 — Bug fix for Bandage / Medkit spam pickup

    ROOT CAUSE:
      Old code:  backpack:FindFirstChild(name)
      This is the Roblox Backpack container. The game's custom inventory
      (seen as numbered slots in the HUD) stores items like Bandage/Medkit
      elsewhere under LocalPlayer — NOT in Roblox's Backpack.
      So the "already owned" check always returned nil → spam pickup every tick.

    FIX:
      isItemInCustomInventory() does a recursive search (FindFirstChild(name, true))
      across ALL of LocalPlayer's descendants, which covers any custom inventory
      folder the game uses regardless of its name. If the item exists anywhere
      as a named Instance, the pickup is skipped for that tick.

    Bandage / Medkit behaviour:
      - Already in custom inventory → skip entirely (no pickup, no use)
      - Not owned + dropped item within radius → fire pickup remote once, then break
      - Never equip, never fire a use remote (game handles consumption itself)

    All other items:
      - Standard equip-from-backpack → fire use remote logic (unchanged)
]]
local autoUseConn = nil
local function startAutoUse()
    if autoUseConn then autoUseConn:Disconnect() end
    autoUseConn = RunService.Heartbeat:Connect(function()
        if not autoUseActive then return end
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not char or not backpack then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local radius = tonumber(auRadiusInput.Text) or 10

        for _, name in ipairs(autoUseItemNames) do
            local isChecked = auItemChecks[name] and auItemChecks[name]()
            local shouldUse = auAllActive and not isChecked or (not auAllActive and isChecked)
            if not shouldUse then continue end

            -- ── Bandage / Medkit: custom inventory items (BUG FIX) ──
            if table.find(inventoryOnlyItems, name) then

                -- Check the REAL custom inventory (recursive search under LocalPlayer).
                -- This correctly detects items stored in custom game inventory folders,
                -- unlike the old check which only looked in Roblox's Backpack service.
                if isItemInCustomInventory(name) then
                    continue  -- Already owned → do absolutely nothing this tick
                end

                -- Not owned yet → collect one nearby dropped item and stop
                if droppedItemsFolder and root then
                    for _, item in ipairs(droppedItemsFolder:GetChildren()) do
                        if item.Name == name then
                            local mp = item.PrimaryPart or getItemMainPart(item)
                            if mp and (mp.Position - root.Position).Magnitude <= radius then
                                if adjustBackpackRemote then
                                    adjustBackpackRemote:FireServer(item)
                                elseif pickUpItemRemote then
                                    pickUpItemRemote:FireServer(item)
                                end
                                task.wait(0.1)
                                break  -- One pickup per item per tick — prevents burst firing
                            end
                        end
                    end
                end

            else
                -- ── Standard consumable: equip from Roblox Backpack then use ──
                local tool = backpack:FindFirstChild(name) or char:FindFirstChild(name)
                if tool then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:EquipTool(tool) task.wait(0.05) end
                    local ar = tool:FindFirstChild("Activate") or tool:FindFirstChild("Use")
                    if ar and ar:IsA("RemoteEvent") then
                        ar:FireServer()
                    elseif useItemRemote then
                        useItemRemote:FireServer(tool)
                    end
                    task.wait(0.1)
                end

                -- Also check nearby dropped items within radius
                if droppedItemsFolder and root then
                    for _, item in ipairs(droppedItemsFolder:GetChildren()) do
                        if item.Name == name then
                            local mp = item.PrimaryPart or getItemMainPart(item)
                            if mp and (mp.Position - root.Position).Magnitude <= radius then
                                if useItemRemote then
                                    useItemRemote:FireServer(item)
                                elseif pickUpItemRemote then
                                    pickUpItemRemote:FireServer(item)
                                end
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end)
end

table.insert(connections, RunService.Heartbeat:Connect(function()
    if autoUseActive and not autoUseConn then startAutoUse()
    elseif not autoUseActive and autoUseConn then autoUseConn:Disconnect() autoUseConn = nil end
end))

-- ---------- BACKPACK SIZE ----------
local bpGroupH = 45 + 32 + 30 + 30 + 30
local bpGroup, bpCont = makeGroup(exploits, "Backpack Size", yOff, bpGroupH)
yOff = yOff + bpGroupH + 10

local bpStatusLbl = Instance.new("TextLabel")
bpStatusLbl.Size = UDim2.new(1, -10, 0, 20) bpStatusLbl.Position = UDim2.new(0, 5, 0, 0)
bpStatusLbl.BackgroundTransparency = 1 bpStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
bpStatusLbl.Text = "Current size: unknown" bpStatusLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
bpStatusLbl.Font = Enum.Font.Gotham bpStatusLbl.TextSize = 12 bpStatusLbl.Parent = bpCont

local bpSizeLbl = Instance.new("TextLabel")
bpSizeLbl.Size = UDim2.new(0, 80, 0, 26) bpSizeLbl.Position = UDim2.new(0, 5, 0, 24)
bpSizeLbl.BackgroundTransparency = 1 bpSizeLbl.Text = "New size:"
bpSizeLbl.TextColor3 = Color3.fromRGB(200, 200, 220) bpSizeLbl.Font = Enum.Font.Gotham
bpSizeLbl.TextSize = 13 bpSizeLbl.TextXAlignment = Enum.TextXAlignment.Left bpSizeLbl.Parent = bpCont

local bpSizeInput = Instance.new("TextBox")
bpSizeInput.Size = UDim2.new(0, 55, 0, 26) bpSizeInput.Position = UDim2.new(0, 88, 0, 24)
bpSizeInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20) bpSizeInput.BorderSizePixel = 1 bpSizeInput.BorderColor3 = themeColor
bpSizeInput.Text = "50" bpSizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
bpSizeInput.Font = Enum.Font.Gotham bpSizeInput.TextSize = 13 bpSizeInput.Parent = bpCont
onThemeChange(function(c) bpSizeInput.BorderColor3 = c end)

local bpApplyBtn = Instance.new("TextButton")
bpApplyBtn.Size = UDim2.new(0, 160, 0, 26) bpApplyBtn.Position = UDim2.new(0, 5, 0, 55)
bpApplyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) bpApplyBtn.BorderSizePixel = 1 bpApplyBtn.BorderColor3 = themeColor
bpApplyBtn.Text = "Apply Backpack Size" bpApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bpApplyBtn.Font = Enum.Font.GothamMedium bpApplyBtn.TextSize = 13 bpApplyBtn.Parent = bpCont
onThemeChange(function(c) bpApplyBtn.BorderColor3 = c end)

local bpInfoLbl = Instance.new("TextLabel")
bpInfoLbl.Size = UDim2.new(1, -10, 0, 30) bpInfoLbl.Position = UDim2.new(0, 5, 0, 86)
bpInfoLbl.BackgroundTransparency = 1 bpInfoLbl.TextWrapped = true
bpInfoLbl.Text = "Tries AdjustBackpack remote. Use correct args if it fails."
bpInfoLbl.TextColor3 = Color3.fromRGB(130, 130, 130) bpInfoLbl.Font = Enum.Font.Gotham
bpInfoLbl.TextSize = 11 bpInfoLbl.TextXAlignment = Enum.TextXAlignment.Left bpInfoLbl.Parent = bpCont

local function detectBackpackSize()
    local pStats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("PlayerData")
    if pStats then
        local bpVal = pStats:FindFirstChild("BackpackSize") or pStats:FindFirstChild("Slots") or pStats:FindFirstChild("MaxItems")
        if bpVal then bpStatusLbl.Text = "Current size: " .. tostring(bpVal.Value) return end
    end
    bpStatusLbl.Text = "Current size: unknown"
end
detectBackpackSize()

bpApplyBtn.MouseButton1Click:Connect(function()
    local newSize = tonumber(bpSizeInput.Text)
    if not newSize or newSize < 1 then bpStatusLbl.Text = "Invalid size value!" return end
    local tried = false
    if adjustBackpackRemote then
        pcall(function() adjustBackpackRemote:FireServer(newSize) end)
        pcall(function() adjustBackpackRemote:FireServer({size = newSize}) end)
        pcall(function() adjustBackpackRemote:FireServer("set", newSize) end)
        pcall(function() adjustBackpackRemote:FireServer(LocalPlayer, newSize) end)
        tried = true
    end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        for _, name in ipairs({"BackpackSize","SetSlots","UpgradeBackpack","SetBackpack","ResizeBackpack"}) do
            local r = remotes:FindFirstChild(name, true)
            if r and r:IsA("RemoteEvent") then
                pcall(function() r:FireServer(newSize) end)
                tried = true
            end
        end
    end
    bpStatusLbl.Text = tried and ("Fired remotes with size " .. newSize) or "No backpack remote found"
end)

-- ========== Misc Tab ==========
local misc = tabFrames["Misc"]

local colorTitle = Instance.new("TextLabel")
colorTitle.Size = UDim2.new(1, -10, 0, 25) colorTitle.Position = UDim2.new(0, 5, 0, 5)
colorTitle.BackgroundTransparency = 1 colorTitle.Text = "UI Theme Color"
colorTitle.TextColor3 = Color3.fromRGB(220, 220, 220) colorTitle.Font = Enum.Font.GothamBold
colorTitle.TextSize = 16 colorTitle.TextXAlignment = Enum.TextXAlignment.Left colorTitle.Parent = misc

local colorLine = Instance.new("Frame")
colorLine.Size = UDim2.new(1, -10, 0, 2) colorLine.Position = UDim2.new(0, 5, 0, 32)
colorLine.BackgroundColor3 = themeColor colorLine.BorderSizePixel = 0 colorLine.Parent = misc
onThemeChange(function(c) colorLine.BackgroundColor3 = c end)

local presetColors = {
    {name="Blood Red",  color=Color3.fromRGB(139,0,0)},
    {name="Crimson",    color=Color3.fromRGB(220,20,60)},
    {name="Orange",     color=Color3.fromRGB(220,100,0)},
    {name="Gold",       color=Color3.fromRGB(200,160,0)},
    {name="Lime",       color=Color3.fromRGB(0,180,0)},
    {name="Cyan",       color=Color3.fromRGB(0,180,200)},
    {name="Royal Blue", color=Color3.fromRGB(30,80,200)},
    {name="Purple",     color=Color3.fromRGB(120,0,200)},
    {name="Hot Pink",   color=Color3.fromRGB(220,0,150)},
    {name="White",      color=Color3.fromRGB(230,230,230)},
}

local swatchY = 40
local swatchSize = 30
local cols = 5
for i, preset in ipairs(presetColors) do
    local col = (i - 1) % cols
    local row = math.floor((i - 1) / cols)
    local swatch = Instance.new("TextButton")
    swatch.Size = UDim2.new(0, swatchSize, 0, swatchSize)
    swatch.Position = UDim2.new(0, 5 + col * (swatchSize + 6), 0, swatchY + row * (swatchSize + 6))
    swatch.BackgroundColor3 = preset.color
    swatch.BorderSizePixel = 2 swatch.BorderColor3 = Color3.fromRGB(0,0,0)
    swatch.Text = "" swatch.Parent = misc
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 4) corner.Parent = swatch
    local tip = Instance.new("TextLabel")
    tip.Size = UDim2.new(0, 80, 0, 18)
    tip.Position = UDim2.new(0, 5 + col * (swatchSize + 6), 0, swatchY + row * (swatchSize + 6) - 18)
    tip.BackgroundColor3 = Color3.fromRGB(10,10,10) tip.BorderSizePixel = 1 tip.BorderColor3 = Color3.fromRGB(80,80,80)
    tip.Text = preset.name tip.TextColor3 = Color3.fromRGB(220,220,220)
    tip.Font = Enum.Font.Gotham tip.TextSize = 11 tip.Visible = false tip.Parent = misc
    swatch.MouseEnter:Connect(function() tip.Visible = true swatch.BorderColor3 = Color3.fromRGB(255,255,255) end)
    swatch.MouseLeave:Connect(function() tip.Visible = false swatch.BorderColor3 = Color3.fromRGB(0,0,0) end)
    swatch.MouseButton1Click:Connect(function() setTheme(preset.color) StatusText.Text = "Theme changed to: " .. preset.name end)
end

local rgbY = swatchY + 2 * (swatchSize + 6) + 15
local rgbLabel = Instance.new("TextLabel")
rgbLabel.Size = UDim2.new(1, -10, 0, 20) rgbLabel.Position = UDim2.new(0, 5, 0, rgbY)
rgbLabel.BackgroundTransparency = 1 rgbLabel.Text = "Custom RGB:"
rgbLabel.TextColor3 = Color3.fromRGB(180, 180, 180) rgbLabel.Font = Enum.Font.Gotham
rgbLabel.TextSize = 13 rgbLabel.TextXAlignment = Enum.TextXAlignment.Left rgbLabel.Parent = misc
rgbY = rgbY + 22

local function makeRgbBox(parent, placeholder, xOff, y)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 50, 0, 26) box.Position = UDim2.new(0, xOff, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(20,20,20) box.BorderSizePixel = 1 box.BorderColor3 = themeColor
    box.Text = "" box.PlaceholderText = placeholder box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham box.TextSize = 13 box.Parent = parent
    onThemeChange(function(c) box.BorderColor3 = c end)
    return box
end
local rBox = makeRgbBox(misc, "R", 5, rgbY)
local gBox = makeRgbBox(misc, "G", 60, rgbY)
local bBox = makeRgbBox(misc, "B", 115, rgbY)

local applyRgbBtn = Instance.new("TextButton")
applyRgbBtn.Size = UDim2.new(0, 70, 0, 26) applyRgbBtn.Position = UDim2.new(0, 172, 0, rgbY)
applyRgbBtn.BackgroundColor3 = Color3.fromRGB(20,20,20) applyRgbBtn.BorderSizePixel = 1 applyRgbBtn.BorderColor3 = themeColor
applyRgbBtn.Text = "Apply" applyRgbBtn.TextColor3 = Color3.fromRGB(255,255,255)
applyRgbBtn.Font = Enum.Font.GothamMedium applyRgbBtn.TextSize = 13 applyRgbBtn.Parent = misc
onThemeChange(function(c) applyRgbBtn.BorderColor3 = c end)
applyRgbBtn.MouseButton1Click:Connect(function()
    local r = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
    local g = math.clamp(tonumber(gBox.Text) or 80, 0, 255)
    local b = math.clamp(tonumber(bBox.Text) or 200, 0, 255)
    setTheme(Color3.fromRGB(r, g, b))
    StatusText.Text = string.format("Custom color applied: RGB(%d,%d,%d)", r, g, b)
end)

local previewLabel = Instance.new("TextLabel")
previewLabel.Size = UDim2.new(0, 60, 0, 14) previewLabel.Position = UDim2.new(0, 5, 0, rgbY + 30)
previewLabel.BackgroundTransparency = 1 previewLabel.Text = "Preview:"
previewLabel.TextColor3 = Color3.fromRGB(150,150,150) previewLabel.Font = Enum.Font.Gotham
previewLabel.TextSize = 11 previewLabel.Parent = misc

local previewSwatch = Instance.new("Frame")
previewSwatch.Size = UDim2.new(0, 30, 0, 18) previewSwatch.Position = UDim2.new(0, 65, 0, rgbY + 28)
previewSwatch.BackgroundColor3 = themeColor previewSwatch.BorderSizePixel = 1 previewSwatch.BorderColor3 = Color3.fromRGB(80,80,80)
previewSwatch.Parent = misc
onThemeChange(function(c) previewSwatch.BackgroundColor3 = c end)

local function updatePreview()
    local r = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
    local g = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
    local b = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
    previewSwatch.BackgroundColor3 = Color3.fromRGB(r, g, b)
end
rBox:GetPropertyChangedSignal("Text"):Connect(updatePreview)
gBox:GetPropertyChangedSignal("Text"):Connect(updatePreview)
bBox:GetPropertyChangedSignal("Text"):Connect(updatePreview)

-- ========== Info Tab ==========
local info = tabFrames["Info"]
yOff = 5
local function mkInfo(text, color, size, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 25) l.Position = UDim2.new(0, 5, 0, y)
    l.BackgroundTransparency = 1 l.Text = text l.TextColor3 = color or Color3.fromRGB(255,255,255)
    l.Font = Enum.Font.GothamBold l.TextSize = size or 16
    l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = info
end
mkInfo("FieScript", Color3.fromRGB(100,160,255), 22, yOff) yOff = yOff + 30
mkInfo("Version: 5.5", Color3.fromRGB(255,255,255), 16, yOff) yOff = yOff + 30
mkInfo("Keybinds:", Color3.fromRGB(200,200,255), 14, yOff) yOff = yOff + 22
mkInfo("  [Insert]  Toggle GUI",                Color3.fromRGB(180,180,255), 13, yOff) yOff = yOff + 20
mkInfo("  [Q]       Speed  (rebindable)",        Color3.fromRGB(180,180,255), 13, yOff) yOff = yOff + 20
mkInfo("  [X]       Auto Pickup  (rebindable)",  Color3.fromRGB(180,180,255), 13, yOff) yOff = yOff + 20
mkInfo("  [C]       Auto Use  (rebindable)",     Color3.fromRGB(180,180,255), 13, yOff) yOff = yOff + 35
mkInfo("Auto Use notes:", Color3.fromRGB(200,200,255), 13, yOff) yOff = yOff + 20
mkInfo("  Bandage & Medkit = collect only if NOT in custom inventory", Color3.fromRGB(160,220,255), 12, yOff) yOff = yOff + 20
mkInfo("  Other items = equip from backpack + use", Color3.fromRGB(160,220,255), 12, yOff) yOff = yOff + 35

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0, 200, 0, 40) unloadBtn.Position = UDim2.new(0, 5, 0, yOff)
unloadBtn.BackgroundColor3 = Color3.fromRGB(0,40,120) unloadBtn.BorderSizePixel = 2 unloadBtn.BorderColor3 = Color3.fromRGB(0,0,0)
unloadBtn.Text = "UNLOAD" unloadBtn.TextColor3 = Color3.fromRGB(255,255,255)
unloadBtn.Font = Enum.Font.GothamBold unloadBtn.TextSize = 18 unloadBtn.Parent = info
unloadBtn.MouseEnter:Connect(function() TweenService:Create(unloadBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,70,180)}):Play() end)
unloadBtn.MouseLeave:Connect(function() TweenService:Create(unloadBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,40,120)}):Play() end)

-- ========== Unload ==========
local function unloadAll()
    for c in pairs(mobESPInstances) do removeMobESP(c) end
    for i in pairs(itemESPInstances) do removeItemESP(i) end
    for _, c in ipairs(connections) do c:Disconnect() end
    if autoPickupConn then autoPickupConn:Disconnect() end
    if autoUseConn then autoUseConn:Disconnect() end
    if speedState then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = originalValues.walkSpeed or 16 end
        end
    end
    ScreenGui:Destroy()
    HudScreenGui:Destroy()
    print("FieScript unloaded.")
end
unloadBtn.MouseButton1Click:Connect(unloadAll)

-- ========== Global Keybinds ==========
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if listeningForSpeedKey then
        speedKeyBind = input.KeyCode
        speedKeyBtn.Text = "Speed Key: [" .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "") .. "]  (click to rebind)"
        speedKeyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        listeningForSpeedKey = false return
    end
    if listeningForPickupKey then
        autoPickupKeyBind = input.KeyCode
        apKeyBtn.Text = "Pickup Key: [" .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "") .. "]  (click to rebind)"
        apKeyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        listeningForPickupKey = false return
    end
    if listeningForUseKey then
        autoUseKeyBind = input.KeyCode
        auKeyBtn.Text = "Use Key: [" .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "") .. "]  (click to rebind)"
        auKeyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        listeningForUseKey = false return
    end

    if input.KeyCode == Enum.KeyCode.Insert then ScreenGui.Enabled = not ScreenGui.Enabled end
    if input.KeyCode == speedKeyBind then toggleSpeed() end
    if input.KeyCode == autoPickupKeyBind then toggleAutoPickupExt() end
    if input.KeyCode == autoUseKeyBind then toggleAutoUseExt() end
end))

-- ========== Status Bar ==========
table.insert(connections, RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    StatusText.Text = string.format(
        "Ready | FPS:%d | MobESP:%s | ItemESP:%s | InfJump:%s | Pickup:%s | Speed:%s | Use:%s",
        fps,
        mobOptions.ESP and "On" or "Off",
        itemOptions.ESP and "On" or "Off",
        originalValues.infJumpActive and "On" or "Off",
        autoPickupActive and "On" or "Off",
        speedState and "On" or "Off",
        autoUseActive and "On" or "Off"
    )
end))

print("FieScript v5.5 loaded. [Insert] GUI | [Q] Speed | [X] Pickup | [C] AutoUse")
