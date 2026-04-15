local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

local ESP = {}
ESP.Enabled = true

-- Box
ESP.Boxes       = true
ESP.BoxType     = 1                                 -- 0 = full, 1 = corner
ESP.BoxColor    = Color3.fromRGB(115, 218, 255)
ESP.BoxFill     = false
ESP.BoxFillColor = Color3.fromRGB(115, 218, 255)
ESP.BoxFillTransparency = 0.85

-- Health
ESP.HealthBar  = true
ESP.HealthText = true

-- Info
ESP.Names         = true
ESP.NameColor     = Color3.fromRGB(255, 255, 255)
ESP.Distance      = true
ESP.DistanceColor = Color3.fromRGB(180, 180, 180)
ESP.Weapon        = true
ESP.WeaponColor   = Color3.fromRGB(180, 180, 180)

-- Skeleton
ESP.Skeletons        = true
ESP.SkeletonColor    = Color3.fromRGB(255, 255, 255)
ESP.SkeletonThickness = 1

-- OOF Arrows (off-screen indicators)
ESP.OOFArrows = true
ESP.OOFRadius = 200
ESP.OOFSize   = 12
ESP.OOFColor  = Color3.fromRGB(115, 218, 255)

-- Filters
ESP.MaxDistance    = 0
ESP.TeamCheck      = false
ESP.VisibleCheck   = false
ESP.VisibleColor   = Color3.fromRGB(0, 255, 0)

-- Viewline (tracer)
ESP.Viewline          = false
ESP.ViewlineColor     = Color3.fromRGB(115, 218, 255)
ESP.ViewlineThickness = 1
ESP.ViewlineLength    = 15  -- studs from head along look direction

local R15_BONES = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local R6_BONES = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local cache = {}

local function createCache()
    local c = {}

    c.boxLines = {}
    c.boxOutlines = {}
    for i = 1, 8 do
        local outline = Drawing.new("Line")
        outline.Color = Color3.fromRGB(0, 0, 0)
        outline.Thickness = 3
        outline.Visible = false
        c.boxOutlines[i] = outline

        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        c.boxLines[i] = line
    end

    c.boxFill = Drawing.new("Square")
    c.boxFill.Filled = true
    c.boxFill.Visible = false

    c.healthBg = Drawing.new("Square")
    c.healthBg.Filled = true
    c.healthBg.Color = Color3.fromRGB(0, 0, 0)
    c.healthBg.Transparency = 0.3
    c.healthBg.Visible = false

    c.healthFill = Drawing.new("Square")
    c.healthFill.Filled = true
    c.healthFill.Visible = false

    c.healthOutline = Drawing.new("Square")
    c.healthOutline.Filled = false
    c.healthOutline.Color = Color3.fromRGB(0, 0, 0)
    c.healthOutline.Thickness = 1
    c.healthOutline.Visible = false

    c.healthText = Drawing.new("Text")
    c.healthText.Center = false
    c.healthText.Outline = true
    c.healthText.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.healthText.Color = Color3.fromRGB(255, 255, 255)
    c.healthText.Visible = false

    c.nameText = Drawing.new("Text")
    c.nameText.Center = true
    c.nameText.Outline = true
    c.nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.nameText.Visible = false

    c.weaponText = Drawing.new("Text")
    c.weaponText.Center = true
    c.weaponText.Outline = true
    c.weaponText.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.weaponText.Visible = false

    c.skeletonLines = {}
    c.skeletonOutlines = {}
    for i = 1, 14 do
        local outline = Drawing.new("Line")
        outline.Color = Color3.fromRGB(0, 0, 0)
        outline.Thickness = 3
        outline.Visible = false
        c.skeletonOutlines[i] = outline

        local line = Drawing.new("Line")
        line.Visible = false
        c.skeletonLines[i] = line
    end

    c.arrowFill = Drawing.new("Triangle")
    c.arrowFill.Filled = true
    c.arrowFill.Visible = false

    c.arrowOutline = Drawing.new("Triangle")
    c.arrowOutline.Filled = false
    c.arrowOutline.Color = Color3.fromRGB(0, 0, 0)
    c.arrowOutline.Thickness = 1
    c.arrowOutline.Visible = false

    c.viewline = Drawing.new("Line")
    c.viewline.Visible = false

    c.viewlineOutline = Drawing.new("Line")
    c.viewlineOutline.Color = Color3.fromRGB(0, 0, 0)
    c.viewlineOutline.Visible = false

    return c
end

local function destroyCache(c)
    for _, l in ipairs(c.boxLines) do l:Remove() end
    for _, l in ipairs(c.boxOutlines) do l:Remove() end
    c.boxFill:Remove()
    c.healthBg:Remove()
    c.healthFill:Remove()
    c.healthOutline:Remove()
    c.healthText:Remove()
    c.nameText:Remove()
    c.weaponText:Remove()
    for _, l in ipairs(c.skeletonLines) do l:Remove() end
    for _, l in ipairs(c.skeletonOutlines) do l:Remove() end
    c.arrowFill:Remove()
    c.arrowOutline:Remove()
    c.viewline:Remove()
    c.viewlineOutline:Remove()
end

local function hideAll(c)
    for i = 1, 8 do
        c.boxLines[i].Visible = false
        c.boxOutlines[i].Visible = false
    end
    c.boxFill.Visible = false
    c.healthBg.Visible = false
    c.healthFill.Visible = false
    c.healthOutline.Visible = false
    c.healthText.Visible = false
    c.nameText.Visible = false
    c.weaponText.Visible = false
    for i = 1, 14 do
        c.skeletonLines[i].Visible = false
        c.skeletonOutlines[i].Visible = false
    end
    c.arrowFill.Visible = false
    c.arrowOutline.Visible = false
    c.viewline.Visible = false
    c.viewlineOutline.Visible = false
end

local function getHealthColor(pct)
    if pct > 75 then
        return Color3.fromRGB(0, 255, 0)
    elseif pct > 50 then
        return Color3.fromRGB(255, 255, 0)
    elseif pct > 25 then
        return Color3.fromRGB(255, 165, 0)
    end
    return Color3.fromRGB(255, 0, 0)
end

local function isEnemy(plr)
    if not ESP.TeamCheck then return true end
    local myTeam = lp:GetAttribute("Team")
    local theirTeam = plr:GetAttribute("Team")
    if not myTeam or not theirTeam then return true end
    return myTeam ~= theirTeam
end

local function setLine(line, outline, from, to, color)
    outline.From = from
    outline.To = to
    outline.Visible = true
    line.From = from
    line.To = to
    line.Color = color
    line.Visible = true
end

local function drawFullBox(c, bx, by, bw, bh, color)
    local tl = Vector2.new(bx, by)
    local tr = Vector2.new(bx + bw, by)
    local bl = Vector2.new(bx, by + bh)
    local br = Vector2.new(bx + bw, by + bh)

    setLine(c.boxLines[1], c.boxOutlines[1], tl, tr, color) 
    setLine(c.boxLines[2], c.boxOutlines[2], tr, br, color) 
    setLine(c.boxLines[3], c.boxOutlines[3], br, bl, color)  
    setLine(c.boxLines[4], c.boxOutlines[4], bl, tl, color) 

    for i = 5, 8 do
        c.boxLines[i].Visible = false
        c.boxOutlines[i].Visible = false
    end
end

local function drawCornerBox(c, bx, by, bw, bh, color)
    local cw = bw * 0.25 
    local ch = bh * 0.25  

    setLine(c.boxLines[1], c.boxOutlines[1],
        Vector2.new(bx, by), Vector2.new(bx + cw, by), color)
    setLine(c.boxLines[2], c.boxOutlines[2],
        Vector2.new(bx, by), Vector2.new(bx, by + ch), color)

    setLine(c.boxLines[3], c.boxOutlines[3],
        Vector2.new(bx + bw - cw, by), Vector2.new(bx + bw, by), color)
    setLine(c.boxLines[4], c.boxOutlines[4],
        Vector2.new(bx + bw, by), Vector2.new(bx + bw, by + ch), color)

    setLine(c.boxLines[5], c.boxOutlines[5],
        Vector2.new(bx, by + bh), Vector2.new(bx + cw, by + bh), color)
    setLine(c.boxLines[6], c.boxOutlines[6],
        Vector2.new(bx, by + bh - ch), Vector2.new(bx, by + bh), color)

    setLine(c.boxLines[7], c.boxOutlines[7],
        Vector2.new(bx + bw - cw, by + bh), Vector2.new(bx + bw, by + bh), color)
    setLine(c.boxLines[8], c.boxOutlines[8],
        Vector2.new(bx + bw, by + bh - ch), Vector2.new(bx + bw, by + bh), color)
end

local function drawOOFArrow(c, headScreen, headZ, color)
    local vp = cam.ViewportSize
    local cx, cy = vp.X * 0.5, vp.Y * 0.5

    local sx, sy = headScreen.X, headScreen.Y

    if headZ <= 0 then
        sx = cx + (cx - sx)
        sy = cy + (cy - sy)
    end

    local dx = sx - cx
    local dy = sy - cy
    local angle = math.atan2(dy, dx)

    local radius = ESP.OOFRadius
    local ax = cx + math.cos(angle) * radius
    local ay = cy + math.sin(angle) * radius

    local size = ESP.OOFSize

    local p1 = Vector2.new(
        ax + math.cos(angle) * size,
        ay + math.sin(angle) * size
    )

    local baseDist = size * 0.4
    local nx = math.cos(angle + 1.5708) * baseDist
    local ny = math.sin(angle + 1.5708) * baseDist

    local p2 = Vector2.new(ax + nx, ay + ny)
    local p3 = Vector2.new(ax - nx, ay - ny)

    c.arrowFill.PointA = p1
    c.arrowFill.PointB = p2
    c.arrowFill.PointC = p3
    c.arrowFill.Color = color
    c.arrowFill.Visible = true

    c.arrowOutline.PointA = p1
    c.arrowOutline.PointB = p2
    c.arrowOutline.PointC = p3
    c.arrowOutline.Visible = true
end

local function renderPlayer(plr, c)
    if plr == lp then hideAll(c) return end

    local char = plr.Character
    if not char then hideAll(c) return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then hideAll(c) return end

    local head = char:FindFirstChild("Head")
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then hideAll(c) return end

    if not isEnemy(plr) then hideAll(c) return end

    local isVisible = false
    if ESP.VisibleCheck then
        local origin = cam.CFrame.Position
        local dir = head.Position - origin
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {lp.Character, char}
        local result = workspace:Raycast(origin, dir, params)
        isVisible = result == nil
    end

    local rootPos = hrp.Position
    local dist = (rootPos - cam.CFrame.Position).Magnitude
    if ESP.MaxDistance > 0 and dist > ESP.MaxDistance then hideAll(c) return end

    local headPos  = head.Position + Vector3.new(0, 0.5, 0)
    local headScreen, headVis = cam:WorldToViewportPoint(headPos)
    local vp = cam.ViewportSize

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local cf = part.CFrame
            local sz = part.Size * 0.5
            local corners = {
                cf * Vector3.new( sz.X,  sz.Y,  sz.Z),
                cf * Vector3.new(-sz.X,  sz.Y,  sz.Z),
                cf * Vector3.new( sz.X, -sz.Y,  sz.Z),
                cf * Vector3.new(-sz.X, -sz.Y,  sz.Z),
                cf * Vector3.new( sz.X,  sz.Y, -sz.Z),
                cf * Vector3.new(-sz.X,  sz.Y, -sz.Z),
                cf * Vector3.new( sz.X, -sz.Y, -sz.Z),
                cf * Vector3.new(-sz.X, -sz.Y, -sz.Z),
            }
            for _, corner in ipairs(corners) do
                local sp, vis = cam:WorldToViewportPoint(corner)
                if vis and sp.Z > 0 then
                    anyOnScreen = true
                    if sp.X < minX then minX = sp.X end
                    if sp.X > maxX then maxX = sp.X end
                    if sp.Y < minY then minY = sp.Y end
                    if sp.Y > maxY then maxY = sp.Y end
                end
            end
        end
    end

    if not anyOnScreen then
        local feetPos  = hrp.Position - Vector3.new(0, 3, 0)
        local feetScreen, feetVis = cam:WorldToViewportPoint(feetPos)

        local headOnScreen = headVis
            and headScreen.X > 0 and headScreen.X < vp.X
            and headScreen.Y > 0 and headScreen.Y < vp.Y
        local feetOnScreen = feetVis
            and feetScreen.X > 0 and feetScreen.X < vp.X
            and feetScreen.Y > 0 and feetScreen.Y < vp.Y

        if not headOnScreen and not feetOnScreen then
            hideAll(c)

            if ESP.OOFArrows then
                drawOOFArrow(c, headScreen, headScreen.Z, ESP.OOFColor)
            end
            return
        end

        minX = math.min(headScreen.X, feetScreen.X) - 20
        maxX = math.max(headScreen.X, feetScreen.X) + 20
        minY = math.min(headScreen.Y, feetScreen.Y)
        maxY = math.max(headScreen.Y, feetScreen.Y)
        anyOnScreen = true
    end

    if not anyOnScreen or maxX < 0 or minX > vp.X or maxY < 0 or minY > vp.Y then
        hideAll(c)

        if ESP.OOFArrows then
            drawOOFArrow(c, headScreen, headScreen.Z, ESP.OOFColor)
        end
        return
    end

    c.arrowFill.Visible = false
    c.arrowOutline.Visible = false

    local padding    = 2
    local boxX       = minX - padding
    local boxY       = minY - padding
    local boxWidth   = (maxX - minX) + padding * 2
    local totalHeight = (maxY - minY) + padding * 2

    if ESP.Boxes then
        local boxCol = (ESP.VisibleCheck and isVisible) and ESP.VisibleColor or ESP.BoxColor
        if ESP.BoxType == 0 then
            drawFullBox(c, boxX, boxY, boxWidth, totalHeight, boxCol)
        else
            drawCornerBox(c, boxX, boxY, boxWidth, totalHeight, boxCol)
        end

        if ESP.BoxFill then
            c.boxFill.Position = Vector2.new(boxX + 1, boxY + 1)
            c.boxFill.Size = Vector2.new(boxWidth - 2, totalHeight - 2)
            c.boxFill.Color = (ESP.VisibleCheck and isVisible) and ESP.VisibleColor or ESP.BoxFillColor
            c.boxFill.Transparency = ESP.BoxFillTransparency
            c.boxFill.Visible = true
        else
            c.boxFill.Visible = false
        end
    else
        for i = 1, 8 do
            c.boxLines[i].Visible = false
            c.boxOutlines[i].Visible = false
        end
        c.boxFill.Visible = false
    end

    local healthPct = math.clamp(math.floor((hum.Health / hum.MaxHealth) * 100), 0, 100)
    if ESP.HealthBar then
        local hbX = boxX - 4
        local hbY = boxY
        local hbH = totalHeight
        local hbW = 1

        c.healthBg.Position = Vector2.new(hbX - 1, hbY - 1)
        c.healthBg.Size = Vector2.new(hbW + 2, hbH + 2)
        c.healthBg.Visible = true

        c.healthOutline.Position = Vector2.new(hbX - 1, hbY - 1)
        c.healthOutline.Size = Vector2.new(hbW + 2, hbH + 2)
        c.healthOutline.Visible = true

        local fillH = math.floor((hbH * healthPct) / 100)
        local hColor = getHealthColor(healthPct)

        c.healthFill.Position = Vector2.new(hbX, hbY + hbH - fillH)
        c.healthFill.Size = Vector2.new(hbW, fillH)
        c.healthFill.Color = hColor
        c.healthFill.Visible = true

        if ESP.HealthText and healthPct < 100 then
            c.healthText.Text = tostring(healthPct)
            c.healthText.Size = 13
            c.healthText.Center = false
            c.healthText.Position = Vector2.new(hbX - 14, hbY + hbH - fillH - 6)
            c.healthText.Color = hColor
            c.healthText.Visible = true
        else
            c.healthText.Visible = false
        end
    else
        c.healthBg.Visible = false
        c.healthFill.Visible = false
        c.healthOutline.Visible = false
        if ESP.HealthText then
            c.healthText.Text = healthPct .. "%"
            c.healthText.Position = Vector2.new(boxX + boxWidth * 0.5, boxY + totalHeight + 2)
            c.healthText.Center = true
            c.healthText.Visible = true
        else
            c.healthText.Visible = false
        end
    end

    if ESP.Names or ESP.Distance then
        local name = plr.DisplayName or plr.Name
        local label = ""

        if ESP.Names and ESP.Distance then
            label = string.format("%s [%dm]", name, math.floor(dist))
        elseif ESP.Names then
            label = name
        else
            label = string.format("[%dm]", math.floor(dist))
        end

        c.nameText.Text = label
        c.nameText.Color = ESP.NameColor
        c.nameText.Position = Vector2.new(headScreen.X, boxY - 15)
        c.nameText.Visible = true
    else
        c.nameText.Visible = false
    end

    if ESP.Weapon then
        local raw = plr:GetAttribute("CurrentEquipped")
        if raw then
            local wepName = string.match(raw, '"Name"%s*:%s*"([^"]+)"') or ""
            if wepName ~= "" then
                c.weaponText.Text = wepName
                c.weaponText.Color = ESP.WeaponColor
                c.weaponText.Position = Vector2.new(boxX + boxWidth * 0.5, boxY + totalHeight + 2)
                c.weaponText.Visible = true
            else
                c.weaponText.Visible = false
            end
        else
            c.weaponText.Visible = false
        end
    else
        c.weaponText.Visible = false
    end

    if ESP.Skeletons then
        local bones = if char:FindFirstChild("UpperTorso") then R15_BONES else R6_BONES
        local drawn = 0

        for i, pair in ipairs(bones) do
            local b1 = char:FindFirstChild(pair[1])
            local b2 = char:FindFirstChild(pair[2])

            if b1 and b2 then
                local s1, v1 = cam:WorldToViewportPoint(b1.Position)
                local s2, v2 = cam:WorldToViewportPoint(b2.Position)

                if v1 and v2 and s1.Z > 0 and s2.Z > 0 then
                    drawn = i
                    local from = Vector2.new(s1.X, s1.Y)
                    local to   = Vector2.new(s2.X, s2.Y)

                    c.skeletonOutlines[i].From = from
                    c.skeletonOutlines[i].To = to
                    c.skeletonOutlines[i].Thickness = ESP.SkeletonThickness + 0.8
                    c.skeletonOutlines[i].Visible = true

                    c.skeletonLines[i].From = from
                    c.skeletonLines[i].To = to
                    c.skeletonLines[i].Color = ESP.SkeletonColor
                    c.skeletonLines[i].Thickness = ESP.SkeletonThickness
                    c.skeletonLines[i].Visible = true
                else
                    c.skeletonLines[i].Visible = false
                    c.skeletonOutlines[i].Visible = false
                end
            else
                c.skeletonLines[i].Visible = false
                c.skeletonOutlines[i].Visible = false
            end
        end

        for i = #bones + 1, 14 do
            c.skeletonLines[i].Visible = false
            c.skeletonOutlines[i].Visible = false
        end
    else
        for i = 1, 14 do
            c.skeletonLines[i].Visible = false
            c.skeletonOutlines[i].Visible = false
        end
    end

    if ESP.Viewline then
        local headCF = head.CFrame
        local lookEnd = headCF.Position + headCF.LookVector * ESP.ViewlineLength
        local headSP = cam:WorldToViewportPoint(headCF.Position)
        local endSP, endVis = cam:WorldToViewportPoint(lookEnd)

        if headSP.Z > 0 and endVis and endSP.Z > 0 then
            local fromPos = Vector2.new(headSP.X, headSP.Y)
            local toPos = Vector2.new(endSP.X, endSP.Y)

            c.viewlineOutline.From = fromPos
            c.viewlineOutline.To = toPos
            c.viewlineOutline.Thickness = ESP.ViewlineThickness + 2
            c.viewlineOutline.Visible = true

            c.viewline.From = fromPos
            c.viewline.To = toPos
            c.viewline.Color = ESP.ViewlineColor
            c.viewline.Thickness = ESP.ViewlineThickness
            c.viewline.Visible = true
        else
            c.viewline.Visible = false
            c.viewlineOutline.Visible = false
        end
    else
        c.viewline.Visible = false
        c.viewlineOutline.Visible = false
    end
end

local function onPlayerAdded(plr)
    if plr == lp then return end
    if not cache[plr] then
        cache[plr] = createCache()
    end
end

local function onPlayerRemoving(plr)
    if cache[plr] then
        destroyCache(cache[plr])
        cache[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    onPlayerAdded(plr)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

RunService.RenderStepped:Connect(function()
    cam = workspace.CurrentCamera

    if not ESP.Enabled then
        for _, c in pairs(cache) do
            hideAll(c)
        end
        return
    end

    for plr, c in pairs(cache) do
        if not plr.Parent then
            destroyCache(c)
            cache[plr] = nil
        else
            renderPlayer(plr, c)
        end
    end
end)

return ESP
