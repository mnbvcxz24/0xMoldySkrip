-- RAPSkrip ESP module
-- Loaded as a separate Lua chunk by RAP-skrip-code.
-- Keep this module self-contained; shared references are passed in ctx.

return function(ctx)
    local RAPSkripFunctions = ctx.RAPSkripFunctions
    local SelectedEggs = ctx.SelectedEggs
    local ESPFilterCount = ctx.ESPFilterCount
    local DetectedEggFrame = ctx.DetectedEggFrame
    local EggCount = ctx.EggCount

    local ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "EggESP"
    ESPFolder.Parent = workspace

    RAPSkripFunctions.ESPObjects = RAPSkripFunctions.ESPObjects or {}

RAPSkripFunctions.updateDetectedEggList = function(lines)
    for _,child in ipairs(DetectedEggFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _,line in ipairs(lines) do
        local label=Instance.new("TextLabel")
        label.Size=UDim2.new(1,-10,0,20)
        label.BackgroundTransparency=1
        label.Text=tostring(line)
        label.TextColor3=Color3.fromRGB(210,210,218)
        label.TextSize=RAPSkripFunctions.textSize(9)
        label.Font=Enum.Font.Gotham
        label.TextXAlignment=Enum.TextXAlignment.Left
        label.Parent=DetectedEggFrame
    end
end

RAPSkripFunctions.updateFilterText = function()
    local selectedNames=RAPSkripFunctions.getSelectedEggNames()

    local ActiveEggs=RAPSkripFunctions.getActiveEggs()
    if not ActiveEggs then
        ESPFilterCount.Text="Detected eggs: 0"
        RAPSkripFunctions.updateDetectedEggList({})
        return
    end

    local lines={}
    local total=0

    for _,egg in ipairs(ActiveEggs:GetChildren()) do
        local eggName=egg:GetAttribute("Egg")

        if eggName and SelectedEggs[eggName] then
            total=total+1

            local weight=tonumber(egg:GetAttribute("Weight"))
            if weight then
                table.insert(lines,string.format("%s - %.2f",eggName,weight))
            else
                table.insert(lines,eggName.." - --")
            end
        end
    end

    ESPFilterCount.Text="Detected eggs: "..tostring(total)
    RAPSkripFunctions.updateDetectedEggList(lines)
end

local ESPFolder=Instance.new("Folder")
ESPFolder.Name="EggESP"
ESPFolder.Parent=workspace

RAPSkripFunctions.ESPObjects = {}

RAPSkripFunctions.clearESP = function()
    for egg, data in pairs(RAPSkripFunctions.ESPObjects) do
        if data and data.Part then
            pcall(function()
                data.Part:Destroy()
            end)
        end

        RAPSkripFunctions.ESPObjects[egg]=nil
    end
end

RAPSkripFunctions.createESP = function(egg)
    if RAPSkripFunctions.ESPObjects[egg] then
        return
    end

    local eggName=egg:GetAttribute("Egg") or "Egg"
    local position=RAPSkripFunctions.getEggPosition(egg)

    if not position then
        RAPSkripFunctions.AddDebug("[ESP ERROR] No usable Position: "..tostring(eggName))
        return
    end

    local part=Instance.new("Part")
    part.Name="EggESP_"..tostring(egg.Name)
    part.Size=Vector3.new(0.5,0.5,0.5)
    part.Position=position
    part.Anchored=true
    part.CanCollide=false
    part.CanTouch=false
    part.CanQuery=false
    part.Transparency=1
    part.Parent=ESPFolder

    local billboard=Instance.new("BillboardGui")
    billboard.Name="EggLabel"
    billboard.Size=UDim2.fromOffset(180,45)
    billboard.StudsOffset=Vector3.new(0,3,0)
    billboard.AlwaysOnTop=true
    billboard.MaxDistance=math.huge
    billboard.Parent=part

    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.Text=eggName
    label.TextColor3=Color3.fromRGB(255,255,255)
    label.TextStrokeTransparency=0
    label.TextStrokeColor3=Color3.fromRGB(0,0,0)
    label.TextSize=RAPSkripFunctions.textSize(13)
    label.Font=Enum.Font.GothamBold
    label.Parent=billboard

    RAPSkripFunctions.ESPObjects[egg]={
        Part=part,
        Label=label
    }
end

RAPSkripFunctions.updateESP = function()
    if not ctx.isESPEnabled() then
        RAPSkripFunctions.clearESP()
        return
    end

    local selectedNames=RAPSkripFunctions.getSelectedEggNames()

    if #selectedNames==0 then
        RAPSkripFunctions.clearESP()
        ESPFilterCount.Text="Detected eggs: 0"
        RAPSkripFunctions.updateDetectedEggList({})
        return
    end

    local ActiveEggs=RAPSkripFunctions.getActiveEggs()

    if not ActiveEggs then
        RAPSkripFunctions.clearESP()
        RAPSkripFunctions.AddDebug("[ESP ERROR] ActiveEggs not found")
        ESPFilterCount.Text="Detected eggs: 0"
        RAPSkripFunctions.updateDetectedEggList({})
        return
    end

    local eggs=ActiveEggs:GetChildren()
    local activeEggSet={}

    for _, egg in ipairs(eggs) do
        local currentEggName=egg:GetAttribute("Egg")

        if currentEggName and SelectedEggs[currentEggName] then
            local weight=tonumber(egg:GetAttribute("Weight"))
            local position=RAPSkripFunctions.getEggPosition(egg)

            if not RAPSkripFunctions.ESPObjects[egg] then
                RAPSkripFunctions.createESP(egg)
            end

            if RAPSkripFunctions.ESPObjects[egg] then
                local data=RAPSkripFunctions.ESPObjects[egg]

                if position and data.Part then
                    data.Part.Position=position
                end

                if data.Label then
                    local weightText="--"

                    if weight~=nil then
                        weightText=string.format("%.2f",weight)
                    end

                    data.Label.Text=tostring(currentEggName).." | "..weightText
                end
            end

            activeEggSet[egg]=true

            local weightText="--"

            if weight~=nil then
                weightText=string.format("%.2f",weight)
            end
        end
    end

    for egg, data in pairs(RAPSkripFunctions.ESPObjects) do
        if not activeEggSet[egg] then
            if data and data.Part then
                pcall(function()
                    data.Part:Destroy()
                end)
            end

            RAPSkripFunctions.ESPObjects[egg]=nil
        end
    end

    EggCount.Text="Active Eggs: "..tostring(#eggs)
end
end
