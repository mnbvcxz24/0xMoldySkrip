-- RAPSkrip AutoPlace module
-- Extracted from RAP-skrip-code. Shared state is accessed through ctx callbacks.
return function(ctx)
    local RAPSkripFunctions = ctx.RAPSkripFunctions
    local player = ctx.player
    local Gui = ctx.Gui
    local EggTypes = ctx.EggTypes
    local EggPlacedEvent = ctx.EggPlacedEvent
    local AutoContent2 = ctx.AutoContent2
    local isAutoPickupBusy = ctx.isAutoPickupBusy
    local isAutoPickupFloating = ctx.isAutoPickupFloating
    local isAutoHatchActionBusy = ctx.isAutoHatchActionBusy

    local AutoPlaceSelectedEggs = {}
    local AutoPlaceEnabled = false
    local AutoPlaceRunning = false
    local AutoPlaceActionBusy = false
    local AutoPlaceObserved = {}
    local AutoPlaceSnapshotCount = 0
    local AutoPlaceSnapshotReceived = false
    local AutoPlaceReservedPositions = {}
    local AutoPlaceSavedCenterCFrame = nil -- Temporary runtime anchor; reset when this script is restarted.

local AutoPlaceCard = Instance.new("Frame")
AutoPlaceCard.Name = "AutoPlaceCard"
AutoPlaceCard.Size = UDim2.new(1, -10, 0, 126)
AutoPlaceCard.Position = UDim2.fromOffset(5, 10)
AutoPlaceCard.BackgroundColor3 = Color3.fromRGB(29, 32, 41)
AutoPlaceCard.BorderSizePixel = 0
AutoPlaceCard.Parent = AutoContent2
local AutoPlaceCardCorner = Instance.new("UICorner")
AutoPlaceCardCorner.CornerRadius = UDim.new(0, 7)
AutoPlaceCardCorner.Parent = AutoPlaceCard

local AutoPlaceTitle = Instance.new("TextLabel")
AutoPlaceTitle.Name = "AutoPlaceTitle"
AutoPlaceTitle.Size = UDim2.new(1, -85, 0, 19)
AutoPlaceTitle.Position = UDim2.fromOffset(5, 24)
AutoPlaceTitle.BackgroundTransparency = 1
AutoPlaceTitle.Text = "Auto Place Eggs"
AutoPlaceTitle.TextColor3 = Color3.fromRGB(210, 210, 218)
AutoPlaceTitle.TextSize = RAPSkripFunctions.textSize(10)
AutoPlaceTitle.Font = Enum.Font.GothamMedium
AutoPlaceTitle.TextXAlignment = Enum.TextXAlignment.Left
AutoPlaceTitle.Parent = AutoPlaceCard

local AutoPlaceStatus = Instance.new("TextLabel")
AutoPlaceStatus.Name = "AutoPlaceStatus"
AutoPlaceStatus.Size = UDim2.new(1, -85, 0, 22)
AutoPlaceStatus.Position = UDim2.fromOffset(5, 37)
AutoPlaceStatus.BackgroundTransparency = 1
AutoPlaceStatus.Text = "● IDLE"
AutoPlaceStatus.TextColor3 = Color3.fromRGB(150, 150, 158)
AutoPlaceStatus.TextSize = RAPSkripFunctions.textSize(10)
AutoPlaceStatus.Font = Enum.Font.Gotham
AutoPlaceStatus.TextXAlignment = Enum.TextXAlignment.Left
AutoPlaceStatus.Parent = AutoPlaceCard

local AutoPlaceToggle = Instance.new("TextButton")
AutoPlaceToggle.Name = "AutoPlaceToggle"
AutoPlaceToggle.Size = UDim2.fromOffset(62, 27)
AutoPlaceToggle.Position = UDim2.new(1, -67, 0, 24)
AutoPlaceToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
AutoPlaceToggle.Text = "OFF"
AutoPlaceToggle.TextColor3 = Color3.fromRGB(220, 220, 225)
AutoPlaceToggle.TextSize = RAPSkripFunctions.textSize(10)
AutoPlaceToggle.Font = Enum.Font.GothamBold
AutoPlaceToggle.AutoButtonColor = false
AutoPlaceToggle.Active = true
AutoPlaceToggle.Selectable = true
AutoPlaceToggle.ZIndex = 50
AutoPlaceToggle.Parent = AutoPlaceCard

local AutoPlaceToggleCorner = Instance.new("UICorner")
AutoPlaceToggleCorner.CornerRadius = UDim.new(0, 6)
AutoPlaceToggleCorner.Parent = AutoPlaceToggle

local AutoPlaceFilterLabel = Instance.new("TextLabel")
AutoPlaceFilterLabel.Name = "AutoPlaceFilterLabel"
AutoPlaceFilterLabel.Size = UDim2.new(1, -10, 0, 19)
AutoPlaceFilterLabel.Position = UDim2.fromOffset(5,54)
AutoPlaceFilterLabel.BackgroundTransparency = 1
AutoPlaceFilterLabel.Text = "Egg Filter"
AutoPlaceFilterLabel.TextColor3 = Color3.fromRGB(210, 210, 218)
AutoPlaceFilterLabel.TextSize = RAPSkripFunctions.textSize(10)
AutoPlaceFilterLabel.Font = Enum.Font.GothamMedium
AutoPlaceFilterLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoPlaceFilterLabel.Parent = AutoPlaceCard

local AutoPlaceFilterButton = Instance.new("TextButton")
AutoPlaceFilterButton.Name = "AutoPlaceFilterButton"
AutoPlaceFilterButton.Size = UDim2.new(1,-10,0,27)
AutoPlaceFilterButton.Position = UDim2.fromOffset(5,71)
AutoPlaceFilterButton.BackgroundColor3 = Color3.fromRGB(35,35,42)
AutoPlaceFilterButton.Text = "  -- ▼"
AutoPlaceFilterButton.TextColor3 = Color3.fromRGB(220,220,225)
AutoPlaceFilterButton.TextSize = RAPSkripFunctions.textSize(10)
AutoPlaceFilterButton.Font = Enum.Font.Gotham
AutoPlaceFilterButton.TextXAlignment = Enum.TextXAlignment.Left
AutoPlaceFilterButton.AutoButtonColor = false
AutoPlaceFilterButton.Active = true
AutoPlaceFilterButton.Selectable = true
AutoPlaceFilterButton.ZIndex = 10
AutoPlaceFilterButton.Parent = AutoPlaceCard

local AutoPlaceFilterButtonCorner = Instance.new("UICorner")
AutoPlaceFilterButtonCorner.CornerRadius = UDim.new(0,6)
AutoPlaceFilterButtonCorner.Parent = AutoPlaceFilterButton

local AutoPlaceFilterCount = Instance.new("TextLabel")
AutoPlaceFilterCount.Name = "AutoPlaceFilterCount"
AutoPlaceFilterCount.Size = UDim2.new(1,-10,0,18)
AutoPlaceFilterCount.Position = UDim2.fromOffset(5,100)
AutoPlaceFilterCount.BackgroundTransparency = 1
AutoPlaceFilterCount.Text = "Selected eggs: 0"
AutoPlaceFilterCount.TextColor3 = Color3.fromRGB(145,145,155)
AutoPlaceFilterCount.TextSize = RAPSkripFunctions.textSize(9)
AutoPlaceFilterCount.Font = Enum.Font.Gotham
AutoPlaceFilterCount.TextXAlignment = Enum.TextXAlignment.Left
AutoPlaceFilterCount.Parent = AutoPlaceCard

local AutoPlaceFilterFrame = Instance.new("ScrollingFrame")
AutoPlaceFilterFrame.Name = "AutoPlaceFilterFrame"
AutoPlaceFilterFrame.Size = UDim2.new(1, -10, 0, 120)
AutoPlaceFilterFrame.Position = UDim2.fromOffset(5,100)
AutoPlaceFilterFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 33)
AutoPlaceFilterFrame.BorderSizePixel = 0
AutoPlaceFilterFrame.ScrollBarThickness = 3
AutoPlaceFilterFrame.ZIndex = 20
AutoPlaceFilterFrame.Visible = false
AutoPlaceFilterFrame.Parent = AutoContent2

local AutoPlaceFilterLayout = Instance.new("UIListLayout")
AutoPlaceFilterLayout.SortOrder = Enum.SortOrder.LayoutOrder
AutoPlaceFilterLayout.Padding = UDim.new(0, 3)
AutoPlaceFilterLayout.Parent = AutoPlaceFilterFrame

    RAPSkripFunctions.setupFilterScrolling(AutoPlaceFilterFrame,AutoPlaceFilterLayout)

RAPSkripFunctions.refreshAutoPlaceFilterText = function()
    local selected={}
    for _,eggName in ipairs(EggTypes) do
        if eggName~="--" and AutoPlaceSelectedEggs[eggName] then
            table.insert(selected,eggName)
        end
    end
    if #selected==0 then
        AutoPlaceFilterButton.Text="  -- ▼"
    elseif #selected==1 then
        AutoPlaceFilterButton.Text="  "..selected[1].." ▼"
    elseif #selected==2 then
        AutoPlaceFilterButton.Text="  "..selected[1]..", "..selected[2].." ▼"
    else
        AutoPlaceFilterButton.Text="  "..selected[1]..", "..selected[2]..", +"..tostring(#selected-2).." ▼"
    end
    AutoPlaceFilterCount.Text="Selected eggs: "..tostring(#selected)
    AutoPlaceFilterButton.BackgroundColor3=#selected>0 and Color3.fromRGB(55,85,60) or Color3.fromRGB(35,35,42)
end

RAPSkripFunctions.createAutoPlaceFilterButtons = function()
    for _,child in ipairs(AutoPlaceFilterFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for _,eggName in ipairs(EggTypes) do
        local isSelected=eggName~="--" and AutoPlaceSelectedEggs[eggName]==true
        local button=Instance.new("TextButton")
        button.Size=UDim2.new(1,-10,0,22)
        button.BackgroundColor3=isSelected and Color3.fromRGB(55,85,60) or Color3.fromRGB(27,27,33)
        button.BackgroundTransparency=isSelected and 0 or 1
        button.TextColor3=isSelected and Color3.fromRGB(225,225,230) or Color3.fromRGB(190,190,198)
        button.TextSize=RAPSkripFunctions.textSize(10)
        button.Font=Enum.Font.Gotham
        button.TextXAlignment=Enum.TextXAlignment.Left
        button.AutoButtonColor=false
        button.Text=(isSelected and "  ☑ " or " ☐ ")..(eggName=="--" and "Clear Selection" or eggName)
        button.Parent=AutoPlaceFilterFrame
        button.MouseButton1Click:Connect(function()
            if eggName=="--" then
                AutoPlaceSelectedEggs={}
            else
                AutoPlaceSelectedEggs[eggName]=not AutoPlaceSelectedEggs[eggName] or nil
            end
            RAPSkripFunctions.createAutoPlaceFilterButtons()
            RAPSkripFunctions.refreshAutoPlaceFilterText()
        end)
    end
end

RAPSkripFunctions.holdEgg = function(eggName, quiet)
    if not AutoPlaceEnabled then
        return false
    end

    if type(eggName) ~= "string" or eggName == "" then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Invalid egg name")
        return false
    end

    local character = player.Character
    if not character then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Character not available")
        return false
    end

    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Backpack not available")
        return false
    end

    local tool

    -- Find the selected egg in the Backpack.
    for _, child in ipairs(backpack:GetChildren()) do
        if child:IsA("Tool") and child.Name == eggName then
            tool = child
            break
        elseif child:IsA("Folder") then
            local candidate = child:FindFirstChild(eggName, true)
            if candidate and candidate:IsA("Tool") then
                tool = candidate
                break
            end
        end
    end

    if not tool then
        if not quiet then RAPSkripFunctions.AddDebug("[AUTO PLACE] Egg tool not found: " .. eggName) end
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Humanoid not found")
        return false
    end

    local success, err = pcall(function()
        humanoid:EquipTool(tool)
    end)

    if not success then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Equip failed: " .. tostring(err))
        return false
    end

    if tool.Parent ~= character then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Egg was not equipped: " .. eggName)
        return false
    end

    RAPSkripFunctions.AddDebug("[AUTO PLACE] Equipped: " .. eggName)
    return true
end

-- Auto Place settings. Ring 1 is the first 3x3 grid; ring 2 expands to 5x5.
local AUTO_PLACE_SPACING = 30
local AUTO_PLACE_MAX_RING = 2
local AUTO_PLACE_POSITION_TOLERANCE = 2

RAPSkripFunctions.getAutoPlaceOffsets = function()
    local offsets = {
        Vector3.new(-1, 0,  1),
        Vector3.new(-1, 0,  0),
        Vector3.new(-1, 0, -1),
        Vector3.new( 0, 0,  1),
        Vector3.new( 0, 0,  0),
        Vector3.new( 0, 0, -1),
        Vector3.new( 1, 0,  1),
        Vector3.new( 1, 0,  0),
        Vector3.new( 1, 0, -1)
    }

    for ring = 2, AUTO_PLACE_MAX_RING do
        for z = ring, -ring, -1 do
            if z == ring or z == -ring then
                for x = -ring, ring do
                    table.insert(offsets, Vector3.new(x, 0, z))
                end
            else
                table.insert(offsets, Vector3.new(-ring, 0, z))
                table.insert(offsets, Vector3.new(ring, 0, z))
            end
        end
    end

    for index, offset in ipairs(offsets) do
        offsets[index] = offset * AUTO_PLACE_SPACING
    end

    return offsets
end

RAPSkripFunctions.isAutoPlacePositionOccupied = function(position)
    for _, placement in ipairs(AutoPlaceObserved) do
        if placement.Position
            and (placement.Position - position).Magnitude <= AUTO_PLACE_POSITION_TOLERANCE then
            return true
        end
    end

    for _, reservedPosition in ipairs(AutoPlaceReservedPositions) do
        if (reservedPosition - position).Magnitude <= AUTO_PLACE_POSITION_TOLERANCE then
            return true
        end
    end

    return false
end

local AUTO_PLACE_MAX_EGGS = 10

-- UI/counting uses only the latest server snapshot, never local reservations.
RAPSkripFunctions.getAutoPlaceOccupiedCount = function()
    return AutoPlaceSnapshotCount
end

RAPSkripFunctions.getAutoPlacePendingReservationCount = function()
    local pendingCount = 0

    for _, reservedPosition in ipairs(AutoPlaceReservedPositions) do
        local representedInSnapshot = false
        for _, placement in ipairs(AutoPlaceObserved) do
            if placement.Position
                and (placement.Position - reservedPosition).Magnitude <= AUTO_PLACE_POSITION_TOLERANCE then
                representedInSnapshot = true
                break
            end
        end
        if not representedInSnapshot then
            pendingCount = pendingCount + 1
        end
    end

    return pendingCount
end

RAPSkripFunctions.getAutoPlaceEffectiveCount = function()
    return RAPSkripFunctions.getAutoPlaceOccupiedCount()
        + RAPSkripFunctions.getAutoPlacePendingReservationCount()
end

RAPSkripFunctions.setAutoPlaceStatus = function(status, color)
    if AutoPlaceStatus then
        AutoPlaceStatus.Text = "● " .. tostring(status)
        AutoPlaceStatus.TextColor3 = color or Color3.fromRGB(150, 150, 158)
    end
end

RAPSkripFunctions.stopAutoPlaceAtLimit = function()
    RAPSkripFunctions.setAutoPlaceStatus("FULL (10/10)", Color3.fromRGB(220, 155, 100))
end

RAPSkripFunctions.findNextAutoPlacePosition = function(centerCFrame)
    local plot = RAPSkripFunctions.findMyPlot()
    local baseplate = plot and plot:FindFirstChild("Baseplate")
    if not baseplate or not baseplate:IsA("BasePart") then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Cannot validate plot bounds; Baseplate not found")
        return nil
    end

    local edgeMargin = 3
    local halfX = (baseplate.Size.X / 2) - edgeMargin
    local halfZ = (baseplate.Size.Z / 2) - edgeMargin
    if halfX <= 0 or halfZ <= 0 then
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Baseplate is too small for safe placement")
        return nil
    end

    for _, offset in ipairs(RAPSkripFunctions.getAutoPlaceOffsets()) do
        if not AutoPlaceEnabled then return nil end
        local candidate = (centerCFrame * CFrame.new(offset)).Position
        local localPosition = baseplate.CFrame:PointToObjectSpace(candidate)
        local insidePlot = math.abs(localPosition.X) <= halfX
            and math.abs(localPosition.Z) <= halfZ

        if insidePlot and not RAPSkripFunctions.isAutoPlacePositionOccupied(candidate) then
            return candidate
        end
    end
    return nil
end

RAPSkripFunctions.isCharacterIdleForAutoPlace = function()
    if isAutoPickupBusy() or isAutoPickupFloating() then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false end
    if humanoid.MoveDirection.Magnitude > 0.05 then return false end
    if humanoid.FloorMaterial == Enum.Material.Air then return false end
    if root.AssemblyLinearVelocity.Magnitude > 1.5 then return false end
    return true
end

RAPSkripFunctions.autoPlaceEggs = function()
    if not AutoPlaceEnabled or AutoPlaceRunning then return end
    AutoPlaceRunning = true

    local success, err = pcall(function()
        if not EggPlacedEvent then
            RAPSkripFunctions.setAutoPlaceStatus("NO REMOTE", Color3.fromRGB(220, 155, 100))
            RAPSkripFunctions.AddDebug("[AUTO PLACE] EggPlaced remote is not ready")
            return
        end

        while AutoPlaceEnabled and Gui.Parent and not AutoPlaceSnapshotReceived do
            RAPSkripFunctions.setAutoPlaceStatus("WAIT SNAP", Color3.fromRGB(220, 190, 110))
            task.wait(0.25)
        end
        if not AutoPlaceEnabled or not Gui.Parent then return end

        local centerCFrame = AutoPlaceSavedCenterCFrame or RAPSkripFunctions.getMyRanchCFrame()
        if not centerCFrame then
            RAPSkripFunctions.setAutoPlaceStatus("NO PLOT", Color3.fromRGB(220, 155, 100))
            RAPSkripFunctions.AddDebug("[AUTO PLACE] Could not find your plot Baseplate")
            return
        end

        local selectedEggNames = {}
        for _, eggName in ipairs(EggTypes) do
            if eggName ~= "--" and AutoPlaceSelectedEggs[eggName] == true then
                table.insert(selectedEggNames, eggName)
            end
        end
        if #selectedEggNames == 0 then
            RAPSkripFunctions.setAutoPlaceStatus("NO EGGS", Color3.fromRGB(220, 190, 110))
            RAPSkripFunctions.AddDebug("[AUTO PLACE] Select at least one egg type")
            return
        end

        RAPSkripFunctions.AddDebug("[AUTO PLACE] Monitoring slots for " .. tostring(#selectedEggNames) .. " selected type(s)")

        while AutoPlaceEnabled and Gui.Parent do
            local ready = false
            while AutoPlaceEnabled and Gui.Parent and not ready do
                local characterReady =
                    not isAutoPickupBusy()
                    and not isAutoPickupFloating()
                    and not isAutoHatchActionBusy()
                    and not AutoPlaceActionBusy
                    and RAPSkripFunctions.isCharacterInMyPlot()
                    and RAPSkripFunctions.isCharacterIdleForAutoPlace()
                local occupiedCount = RAPSkripFunctions.getAutoPlaceOccupiedCount()
                local effectiveCount = RAPSkripFunctions.getAutoPlaceEffectiveCount()
                if not characterReady then
                    RAPSkripFunctions.setAutoPlaceStatus("WAITING", Color3.fromRGB(220, 190, 110))
                    task.wait(0.25)
                elseif effectiveCount >= AUTO_PLACE_MAX_EGGS then
                    if occupiedCount >= AUTO_PLACE_MAX_EGGS then
                        RAPSkripFunctions.stopAutoPlaceAtLimit()
                    else
                        RAPSkripFunctions.setAutoPlaceStatus("WAIT SNAP", Color3.fromRGB(220, 190, 110))
                    end
                    task.wait(0.5)
                else
                    ready = true
                end
            end
            if not AutoPlaceEnabled or not Gui.Parent then break end

            RAPSkripFunctions.setAutoPlaceStatus("PROCESSING", Color3.fromRGB(130, 180, 140))
            local placedThisRound = false
            local retryNextCycle = false

            for _, eggName in ipairs(selectedEggNames) do
                if not AutoPlaceEnabled or not Gui.Parent then break end

                local canPlace = false
                while AutoPlaceEnabled and Gui.Parent and not canPlace do
                    local characterReady =
                        not isAutoPickupBusy()
                        and not isAutoPickupFloating()
                        and not isAutoHatchActionBusy()
                        and not AutoPlaceActionBusy
                        and RAPSkripFunctions.isCharacterInMyPlot()
                        and RAPSkripFunctions.isCharacterIdleForAutoPlace()
                    local occupiedCount = RAPSkripFunctions.getAutoPlaceOccupiedCount()
                    local effectiveCount = RAPSkripFunctions.getAutoPlaceEffectiveCount()
                    if not characterReady then
                        RAPSkripFunctions.setAutoPlaceStatus("WAITING", Color3.fromRGB(220, 190, 110))
                        task.wait(0.25)
                    elseif effectiveCount >= AUTO_PLACE_MAX_EGGS then
                        if occupiedCount >= AUTO_PLACE_MAX_EGGS then
                            RAPSkripFunctions.stopAutoPlaceAtLimit()
                        else
                            RAPSkripFunctions.setAutoPlaceStatus("WAIT SNAP", Color3.fromRGB(220, 190, 110))
                        end
                        task.wait(0.5)
                    else
                        canPlace = true
                    end
                end
                if not AutoPlaceEnabled or not Gui.Parent then break end

                local position = RAPSkripFunctions.findNextAutoPlacePosition(centerCFrame)
                if not position then
                    RAPSkripFunctions.setAutoPlaceStatus("WAIT SLOT", Color3.fromRGB(220, 190, 110))
                    RAPSkripFunctions.AddDebug("[AUTO PLACE] No free placement position found; will retry")
                    retryNextCycle = true
                    break
                end

                AutoPlaceActionBusy = true
                local held = RAPSkripFunctions.holdEgg(eggName, true)
                if held then
                    table.insert(AutoPlaceReservedPositions, position)
                    local sent, sendError = pcall(function()
                        EggPlacedEvent:FireServer({ PlantPosition = position })
                    end)
                    if sent then
                        placedThisRound = true
                        RAPSkripFunctions.AddDebug("[AUTO PLACE] Request sent for " .. eggName)
                        task.wait(0.75)
                    else
                        for index = #AutoPlaceReservedPositions, 1, -1 do
                            if AutoPlaceReservedPositions[index] == position then
                                table.remove(AutoPlaceReservedPositions, index)
                                break
                            end
                        end
                        RAPSkripFunctions.AddDebug("[AUTO PLACE] Request failed: " .. tostring(sendError))
                    end
                end
                AutoPlaceActionBusy = false
            end

            if not AutoPlaceEnabled or not Gui.Parent then break end
            if retryNextCycle then
                task.wait(0.5)
            elseif not placedThisRound then
                RAPSkripFunctions.setAutoPlaceStatus("WAIT EGGS", Color3.fromRGB(220, 190, 110))
                task.wait(2)
            else
                task.wait(0.25)
            end
        end

        RAPSkripFunctions.AddDebug("[AUTO PLACE] Placement monitor stopped")
    end)

    AutoPlaceActionBusy = false
    AutoPlaceRunning = false
    if not success then
        RAPSkripFunctions.setAutoPlaceStatus("ERROR", Color3.fromRGB(220, 100, 100))
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Error: " .. tostring(err))
    elseif not AutoPlaceEnabled then
        RAPSkripFunctions.setAutoPlaceStatus("IDLE", Color3.fromRGB(150, 150, 158))
    end
end


-- Listen for the server's owner-specific placement snapshot.
task.spawn(function()
    while not EggPlacedEvent and Gui.Parent do
        task.wait(0.1)
    end

    if not EggPlacedEvent or not Gui.Parent then
        return
    end

    EggPlacedEvent.OnClientEvent:Connect(function(payload)
        if type(payload) ~= "table" or payload.Snapshot ~= true then
            return
        end

        if payload.Owner ~= player then
            return
        end

        local updatedPlacements = {}
        AutoPlaceSnapshotCount = type(payload.Placements) == "table"
            and #payload.Placements or 0

        if type(payload.Placements) == "table" then
            for _, placement in ipairs(payload.Placements) do
                if type(placement) == "table" then
                    local coordinate = placement.Coordinate
                    local position

                    if typeof(coordinate) == "CFrame" then
                        position = coordinate.Position
                    elseif typeof(coordinate) == "Vector3" then
                        position = coordinate
                    end

                    if position then
                        table.insert(updatedPlacements, {
                            Position = position,
                            EggName = placement.EggName,
                            EggKey = placement.EggKey,
                            NestId = placement.NestId
                        })
                    end
                end
            end
        end

        AutoPlaceObserved = updatedPlacements
        AutoPlaceSnapshotReceived = true

        if not AutoPlaceRunning then
            AutoPlaceReservedPositions = {}
        end

        local occupiedCount = RAPSkripFunctions.getAutoPlaceOccupiedCount()
        if AutoPlaceEnabled and occupiedCount >= AUTO_PLACE_MAX_EGGS then
            RAPSkripFunctions.stopAutoPlaceAtLimit()
        elseif AutoPlaceEnabled and not AutoPlaceRunning then
            RAPSkripFunctions.setAutoPlaceStatus("PROCESSING", Color3.fromRGB(130, 180, 140))
            task.spawn(RAPSkripFunctions.autoPlaceEggs)
        end

        RAPSkripFunctions.AddDebug("[AUTO PLACE] Snapshot received: " .. tostring(AutoPlaceSnapshotCount) .. " placed egg(s); slots refreshed (" .. tostring(AutoPlaceSnapshotCount) .. "/" .. tostring(AUTO_PLACE_MAX_EGGS) .. ")")
    end)

    RAPSkripFunctions.AddDebug("[AUTO PLACE] EggPlaced listener connected")
end)

AutoPlaceToggle.Activated:Connect(function()
    if AutoPlaceEnabled then
        AutoPlaceEnabled = false
        RAPSkripFunctions.styleToggle(AutoPlaceToggle, false)
        RAPSkripFunctions.setAutoPlaceStatus("IDLE", Color3.fromRGB(150, 150, 158))
        RAPSkripFunctions.AddDebug("[AUTO PLACE] Disabled")
        return
    end

    AutoPlaceEnabled = true
    if not AutoPlaceSavedCenterCFrame then
        AutoPlaceSavedCenterCFrame = RAPSkripFunctions.getMyRanchCFrame()
        if AutoPlaceSavedCenterCFrame then
            RAPSkripFunctions.AddDebug("[AUTO PLACE] Saved temporary placement center for this script session")
        end
    end
    RAPSkripFunctions.styleToggle(AutoPlaceToggle, true)
    if RAPSkripFunctions.getAutoPlaceOccupiedCount() >= AUTO_PLACE_MAX_EGGS then
        RAPSkripFunctions.stopAutoPlaceAtLimit()
    else
        RAPSkripFunctions.setAutoPlaceStatus("WAITING", Color3.fromRGB(220, 190, 110))
    end
    RAPSkripFunctions.AddDebug("[AUTO PLACE] Enabled; monitoring slots and waiting for an idle character")
    task.spawn(RAPSkripFunctions.autoPlaceEggs)
end)


AutoPlaceFilterButton.MouseButton1Click:Connect(function()
    AutoPlaceFilterFrame.Visible=not AutoPlaceFilterFrame.Visible
    if AutoPlaceFilterFrame.Visible then
        AutoPlaceFilterButton.Text="  Select Eggs ▲"
        RAPSkripFunctions.createAutoPlaceFilterButtons()
    else
        RAPSkripFunctions.refreshAutoPlaceFilterText()
    end
end)


    return {
        isActionBusy = function()
            return AutoPlaceActionBusy
        end,
        shutdown = function()
            AutoPlaceEnabled = false
            AutoPlaceRunning = false
            AutoPlaceActionBusy = false
        end,
        isEnabled = function()
            return AutoPlaceEnabled
        end
    }
end
