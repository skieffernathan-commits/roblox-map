--!strict
-- BRAINROT BUNKER: SURVIVE THE NIGHT
-- Replaces the old scattered-block prototype with a connected, readable map.
-- Put this Script in ServerScriptService and press Play.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BRAINROT_BUNKER"
local rng = Random.new(20261113)

local C = {
	grass = Color3.fromRGB(57, 128, 77),
	darkGrass = Color3.fromRGB(39, 91, 63),
	stone = Color3.fromRGB(94, 103, 124),
	path = Color3.fromRGB(198, 185, 153),
	gold = Color3.fromRGB(255, 202, 79),
	white = Color3.fromRGB(245, 242, 226),
	green = Color3.fromRGB(75, 255, 145),
}

local function folder(parent: Instance, name: string): Folder
	local found = parent:FindFirstChild(name)
	if found and found:IsA("Folder") then return found end
	local result = Instance.new("Folder")
	result.Name = name
	result.Parent = parent
	return result
end

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function label(adornee: Instance, text: string, color: Color3, offset: Vector3?)
	local gui = Instance.new("BillboardGui")
	gui.Name = "WorldLabel"
	gui.Adornee = adornee:IsA("BasePart") and adornee or nil
	gui.Size = UDim2.fromOffset(260, 62)
	gui.StudsOffset = offset or Vector3.new(0, 7, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 400
	gui.Parent = adornee
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
	textLabel.BackgroundTransparency = 0.18
	textLabel.Text = text
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0.45
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = textLabel
end

local function light(parent: Instance, color: Color3, brightness: number, range: number)
	local point = Instance.new("PointLight")
	point.Color = color
	point.Brightness = brightness
	point.Range = range
	point.Parent = parent
end

local function beamPath(parent: Instance, name: string, a: Vector3, b: Vector3, width: number, color: Color3, y: number)
	local start = Vector3.new(a.X, y, a.Z)
	local finish = Vector3.new(b.X, y, b.Z)
	local mid = (start + finish) * 0.5
	local length = (finish - start).Magnitude
	return part(parent, name, Vector3.new(width, 1.2, length), CFrame.lookAt(mid, finish), color, Enum.Material.Slate)
end

local function cylinder(parent: Instance, name: string, diameter: number, height: number, position: Vector3, color: Color3, material: Enum.Material)
	return part(parent, name, Vector3.new(height, diameter, diameter), CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)), color, material, Enum.PartType.Cylinder)
end

local function createSpawn(parent: Instance, name: string, position: Vector3, color: Color3)
	local pad = cylinder(parent, name, 9, 0.7, position + Vector3.new(0, 0.45, 0), color, Enum.Material.Neon)
	pad.CanCollide = false
	pad:SetAttribute("SpawnPoint", true)
	return pad
end

local function createCheckpoint(parent: Instance, name: string, position: Vector3)
	local pad = cylinder(parent, name, 15, 1, position + Vector3.new(0, 0.6, 0), C.green, Enum.Material.Neon)
	pad.CanCollide = false
	pad:SetAttribute("Checkpoint", true)
	local postL = part(parent, name .. "_LeftPost", Vector3.new(2, 12, 2), CFrame.new(position + Vector3.new(-8, 6, 0)), C.green, Enum.Material.Neon)
	local postR = part(parent, name .. "_RightPost", Vector3.new(2, 12, 2), CFrame.new(position + Vector3.new(8, 6, 0)), C.green, Enum.Material.Neon)
	part(parent, name .. "_Arch", Vector3.new(18, 2, 2), CFrame.new(position + Vector3.new(0, 12, 0)), C.green, Enum.Material.Neon)
	postL.CanCollide = false
	postR.CanCollide = false
	label(pad, "CHECKPOINT", Color3.fromRGB(207, 255, 220), Vector3.new(0, 4, 0))
end

local function createSafeZone(root: Instance, name: string, position: Vector3, radius: number)
	local zones = folder(root, "SafeZones")
	local region = part(zones, name, Vector3.new(radius * 2, 18, radius * 2), CFrame.new(position + Vector3.new(0, 9, 0)), Color3.fromRGB(70, 255, 140))
	region.Transparency = 1
	region.CanCollide = false
	region.CanTouch = false
	region:SetAttribute("SafeZone", true)
	local ring = cylinder(zones, name .. "_GlowRing", radius * 2, 0.45, position + Vector3.new(0, 0.35, 0), Color3.fromRGB(78, 255, 145), Enum.Material.Neon)
	ring.Transparency = 0.55
	ring.CanCollide = false
end

local function addLantern(parent: Instance, position: Vector3, color: Color3)
	part(parent, "LanternPost", Vector3.new(2, 11, 2), CFrame.new(position + Vector3.new(0, 5.5, 0)), Color3.fromRGB(61, 58, 68), Enum.Material.Metal)
	local lamp = part(parent, "Lantern", Vector3.new(3, 3, 3), CFrame.new(position + Vector3.new(0, 11.5, 0)), color, Enum.Material.Neon)
	lamp.CanCollide = false
	light(lamp, color, 1.5, 28)
end

local function buildHub(root: Instance)
	local hub = folder(root, "Hub")
	local decor = folder(root, "Decor")
	-- Raised circular plaza with concentric trim, radial paving and clear entrances.
	cylinder(hub, "PlazaFoundation", 222, 5, Vector3.new(0, 0, 0), Color3.fromRGB(47, 57, 80), Enum.Material.Slate)
	cylinder(hub, "PlazaOuterTrim", 210, 1.3, Vector3.new(0, 3.1, 0), C.gold, Enum.Material.Metal)
	cylinder(hub, "PlazaWalkway", 196, 1.5, Vector3.new(0, 4, 0), Color3.fromRGB(117, 137, 157), Enum.Material.Concrete)
	cylinder(hub, "PlazaCenter", 112, 1.8, Vector3.new(0, 4.9, 0), Color3.fromRGB(78, 104, 139), Enum.Material.Slate)
	cylinder(hub, "ClockPlatform", 48, 2, Vector3.new(0, 6.7, 0), C.gold, Enum.Material.Metal)

	-- Eight bold colored radial inlays make the circular hub easy to navigate.
	for i = 1, 8 do
		local angle = math.rad((i - 1) * 45)
		local r = 76
		local tile = part(hub, "HubRadialInlay_" .. i, Vector3.new(5, 0.45, 28), CFrame.new(math.cos(angle) * r, 5.95, math.sin(angle) * r) * CFrame.Angles(0, -angle, 0), i % 2 == 0 and C.gold or Color3.fromRGB(123, 220, 255), Enum.Material.Neon)
		tile.CanCollide = false
	end

	-- Clock tower: broad foot, visible shaft, clock faces, roof and beacon.
	part(hub, "ClockTowerFoot", Vector3.new(28, 8, 28), CFrame.new(0, 12, 0), Color3.fromRGB(64, 72, 95), Enum.Material.Slate)
	part(hub, "ClockTowerShaft", Vector3.new(18, 48, 18), CFrame.new(0, 39, 0), Color3.fromRGB(236, 190, 80), Enum.Material.Metal)
	for _, side in ipairs({-1, 1}) do
		local face = part(hub, "ClockFace_" .. side, Vector3.new(16, 16, 1), CFrame.new(0, 49, side * 9.7) * CFrame.Angles(0, side == 1 and 0 or math.pi, 0), Color3.fromRGB(25, 34, 54), Enum.Material.SmoothPlastic)
		face.CanCollide = false
		label(face, "DAY / NIGHT", C.gold, Vector3.new(0, 0, 0))
	end
	part(hub, "ClockRoof", Vector3.new(25, 5, 25), CFrame.new(0, 66, 0), Color3.fromRGB(193, 72, 79), Enum.Material.Metal)
	local beacon = cylinder(hub, "ClockBeacon", 6, 7, Vector3.new(0, 72, 0), C.gold, Enum.Material.Neon)
	beacon.CanCollide = false
	light(beacon, C.gold, 2, 38)
	label(beacon, "BRAINROT BUNKER", C.white, Vector3.new(0, 8, 0))

	-- Shop and leaderboard are real landmarks, not floating labels.
	local shop = part(hub, "ShopKiosk", Vector3.new(24, 12, 18), CFrame.new(63, 10, 0), Color3.fromRGB(241, 115, 64), Enum.Material.WoodPlanks)
	part(hub, "ShopAwning", Vector3.new(31, 2, 22), CFrame.new(63, 17, 0), C.gold, Enum.Material.Fabric)
	label(shop, "BUNKER SHOP", C.white, Vector3.new(0, 9, 0))
	local board = part(hub, "LeaderboardBoard", Vector3.new(30, 20, 3), CFrame.new(-65, 15, 0), Color3.fromRGB(34, 42, 59), Enum.Material.Slate)
	part(hub, "BoardLeg_L", Vector3.new(2, 9, 2), CFrame.new(-74, 5, 0), C.gold, Enum.Material.Metal)
	part(hub, "BoardLeg_R", Vector3.new(2, 9, 2), CFrame.new(-56, 5, 0), C.gold, Enum.Material.Metal)
	label(board, "TOP SURVIVORS", C.gold, Vector3.new(0, 12, 0))

	for _, p in ipairs({Vector3.new(82, 0, 68), Vector3.new(-82, 0, 68), Vector3.new(82, 0, -68), Vector3.new(-82, 0, -68)}) do
		addLantern(decor, p, Color3.fromRGB(255, 218, 112))
	end
	createSafeZone(root, "HubSafeZone", Vector3.new(0, 5, 0), 76)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn_01"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 6.2, -27)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = C.green
	spawn.Parent = folder(root, "SpawnPoints")
end

local function buildBases(root: Instance)
	local bases = folder(root, "Bases")
	local spawns = folder(root, "SpawnPoints")
	for i = 1, 8 do
		local angle = math.rad((i - 1) * 45 + 22.5)
		local center = Vector3.new(math.cos(angle) * 246, 0, math.sin(angle) * 246)
		local base = folder(bases, string.format("Base_%02d", i))
		base:SetAttribute("OwnerUserId", 0)
		base:SetAttribute("BaseNumber", i)
		part(base, "Foundation", Vector3.new(76, 2, 76), CFrame.new(center + Vector3.new(0, 1, 0)), Color3.fromRGB(62, 83, 91), Enum.Material.Slate)
		part(base, "Lawn", Vector3.new(68, 0.8, 68), CFrame.new(center + Vector3.new(0, 2.4, 0)), Color3.fromRGB(111, 168, 102), Enum.Material.Grass)
		-- Back and side walls leave the front open to the shared race lanes.
		part(base, "BackWall", Vector3.new(68, 13, 3), CFrame.new(center + Vector3.new(0, 9, 32)), Color3.fromRGB(68, 93, 105), Enum.Material.WoodPlanks)
		part(base, "LeftWall", Vector3.new(3, 13, 64), CFrame.new(center + Vector3.new(-32, 9, 0)), Color3.fromRGB(68, 93, 105), Enum.Material.WoodPlanks)
		part(base, "RightWall", Vector3.new(3, 13, 64), CFrame.new(center + Vector3.new(32, 9, 0)), Color3.fromRGB(68, 93, 105), Enum.Material.WoodPlanks)
		local gateColor = Color3.fromRGB(89, 205, 255)
		part(base, "GatePost_L", Vector3.new(4, 15, 4), CFrame.new(center + Vector3.new(-13, 9, -31)), gateColor, Enum.Material.Metal)
		part(base, "GatePost_R", Vector3.new(4, 15, 4), CFrame.new(center + Vector3.new(13, 9, -31)), gateColor, Enum.Material.Metal)
		local gate = part(base, "LockableGate", Vector3.new(22, 10, 1.5), CFrame.new(center + Vector3.new(0, 8, -31)), Color3.fromRGB(70, 176, 227), Enum.Material.ForceField)
		gate.Transparency = 0.25
		gate:SetAttribute("Locked", false)
		gate.CanCollide = false
		part(base, "GateHeader", Vector3.new(30, 3, 4), CFrame.new(center + Vector3.new(0, 17, -31)), C.gold, Enum.Material.Metal)
		label(gate, "PLAYER BASE " .. i, C.white, Vector3.new(0, 8, 0))
		-- Ten clearly numbered display plinths in two neat rows.
		for n = 1, 10 do
			local col = (n - 1) % 5
			local row = math.floor((n - 1) / 5)
			local x = center.X - 24 + col * 12
			local z = center.Z - 5 + row * 20
			cylinder(base, "CreaturePedestal_" .. n, 8, 3.5, Vector3.new(x, 5.2, z), Color3.fromRGB(211, 218, 230), Enum.Material.Marble)
			local glow = cylinder(base, "PedestalGlow_" .. n, 5, 0.35, Vector3.new(x, 7.15, z), gateColor, Enum.Material.Neon)
			glow.CanCollide = false
		end
		local upgrade = part(base, "UpgradeStation", Vector3.new(12, 8, 10), CFrame.new(center + Vector3.new(-22, 7, 25)), Color3.fromRGB(111, 139, 255), Enum.Material.Metal)
		label(upgrade, "UPGRADE", C.white, Vector3.new(0, 7, 0))
		local turret = cylinder(base, "TurretSlot", 12, 5, center + Vector3.new(23, 4.5, 24), Color3.fromRGB(255, 144, 70), Enum.Material.Metal)
		turret:SetAttribute("TurretSlot", true)
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "BaseSpawn_" .. string.format("%02d", i)
		spawn.Size = Vector3.new(7, 1, 7)
		spawn.Position = center + Vector3.new(0, 3, -19)
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Duration = 0
		spawn.Parent = spawns
		createSafeZone(root, "BaseSafeZone_" .. string.format("%02d", i), center + Vector3.new(0, 3, 0), 31)
	end
end

local zoneData = {
	CandySwamp = {center = Vector3.new(-500, 0, -500), ground = Color3.fromRGB(102, 190, 123), path = Color3.fromRGB(255, 207, 145), accent = Color3.fromRGB(255, 132, 196), glow = Color3.fromRGB(255, 220, 106), sign = "CANDY SWAMP  •  EASY"},
	PixelForest = {center = Vector3.new(500, 0, -500), ground = Color3.fromRGB(49, 104, 78), path = Color3.fromRGB(135, 157, 111), accent = Color3.fromRGB(101, 218, 165), glow = Color3.fromRGB(130, 242, 255), sign = "PIXEL FOREST  •  MEDIUM"},
	NeonJunkyard = {center = Vector3.new(-500, 0, 500), ground = Color3.fromRGB(91, 99, 119), path = Color3.fromRGB(166, 164, 174), accent = Color3.fromRGB(68, 245, 236), glow = Color3.fromRGB(255, 84, 138), sign = "NEON JUNKYARD  •  HARD"},
	VolcanoTemple = {center = Vector3.new(500, 0, 500), ground = Color3.fromRGB(119, 68, 57), path = Color3.fromRGB(183, 118, 79), accent = Color3.fromRGB(255, 111, 48), glow = Color3.fromRGB(255, 177, 64), sign = "VOLCANO TEMPLE  •  VERY HARD"},
}

local function addTree(parent: Instance, pos: Vector3, trunkColor: Color3, leafColor: Color3, scale: number)
	cylinder(parent, "ChunkyTreeTrunk", 5 * scale, 16 * scale, pos + Vector3.new(0, 8 * scale, 0), trunkColor, Enum.Material.Wood)
	local crown = part(parent, "BlockyTreeCrown", Vector3.new(16, 15, 16) * scale, CFrame.new(pos + Vector3.new(0, 20 * scale, 0)), leafColor, Enum.Material.Grass)
	part(parent, "TreeCrownTop", Vector3.new(11, 9, 11) * scale, CFrame.new(pos + Vector3.new(0, 30 * scale, 0)), leafColor:Lerp(Color3.new(1, 1, 1), 0.1), Enum.Material.Grass)
	crown:SetAttribute("Decor", true)
end

local function addMushroom(parent: Instance, pos: Vector3, scale: number, capColor: Color3)
	cylinder(parent, "CandyMushroomStem", 4 * scale, 10 * scale, pos + Vector3.new(0, 5 * scale, 0), Color3.fromRGB(255, 235, 206), Enum.Material.SmoothPlastic)
	local cap = part(parent, "CandyMushroomCap", Vector3.new(15, 7, 15) * scale, CFrame.new(pos + Vector3.new(0, 11 * scale, 0)), capColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	cap:SetAttribute("Decor", true)
	light(cap, capColor, 0.35, 13)
end

local function addRock(parent: Instance, name: string, pos: Vector3, size: Vector3, color: Color3)
	local rock = part(parent, name, size, CFrame.new(pos) * CFrame.Angles(math.rad(rng:NextInteger(-8, 8)), math.rad(rng:NextInteger(0, 180)), math.rad(rng:NextInteger(-8, 8))), color, Enum.Material.Rock)
	rock:SetAttribute("Decor", true)
end

local function addZoneLandmarks(root: Instance, name: string, data, zone: Folder)
	local x, z = data.center.X, data.center.Z
	local deco = folder(root, "Decor")
	if name == "CandySwamp" then
		for i = 1, 15 do
			local angle = (i / 15) * math.pi * 2
			local radius = rng:NextNumber(74, 145)
			addMushroom(zone, Vector3.new(x + math.cos(angle) * radius, 1, z + math.sin(angle) * radius), rng:NextNumber(0.65, 1.25), i % 2 == 0 and Color3.fromRGB(255, 112, 178) or Color3.fromRGB(255, 199, 98))
		end
		for i = 1, 8 do
			local fruit = part(zone, "OversizedCandyFruit_" .. i, Vector3.new(10, 10, 10), CFrame.new(x + rng:NextInteger(-145, 145), 8, z + rng:NextInteger(-145, 145)), i % 2 == 0 and Color3.fromRGB(255, 105, 107) or Color3.fromRGB(255, 191, 68), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
			fruit:SetAttribute("Decor", true)
		end
		part(zone, "GummyBridge", Vector3.new(20, 3, 74), CFrame.new(x + 95, 4, z) * CFrame.Angles(0, math.rad(28), 0), Color3.fromRGB(255, 156, 211), Enum.Material.SmoothPlastic)
		part(zone, "SwampBoardwalk", Vector3.new(18, 2, 90), CFrame.new(x - 100, 2, z + 4) * CFrame.Angles(0, math.rad(-20), 0), Color3.fromRGB(133, 87, 125), Enum.Material.WoodPlanks)
	elseif name == "PixelForest" then
		for i = 1, 24 do
			local angle = (i / 24) * math.pi * 2
			local radius = rng:NextNumber(92, 163)
			local pos = Vector3.new(x + math.cos(angle) * radius, 1, z + math.sin(angle) * radius)
			if (pos - data.center).Magnitude > 112 then
				addTree(zone, pos, Color3.fromRGB(101, 73, 56), i % 3 == 0 and Color3.fromRGB(73, 149, 95) or Color3.fromRGB(54, 124, 81), rng:NextNumber(0.75, 1.2))
			end
		end
		-- Cabin with roof, porch and warmly lit windows.
		local cabinPos = Vector3.new(x + 112, 0, z - 92)
		part(zone, "AbandonedCabin", Vector3.new(40, 22, 30), CFrame.new(cabinPos + Vector3.new(0, 12, 0)), Color3.fromRGB(91, 65, 49), Enum.Material.WoodPlanks)
		part(zone, "CabinRoof", Vector3.new(48, 4, 38), CFrame.new(cabinPos + Vector3.new(0, 25, 0)), Color3.fromRGB(47, 54, 58), Enum.Material.Slate)
		part(zone, "CabinDoor", Vector3.new(8, 15, 1), CFrame.new(cabinPos + Vector3.new(0, 7.5, -15)), Color3.fromRGB(42, 38, 40), Enum.Material.Wood)
		for _, dx in ipairs({-12, 12}) do
			local window = part(zone, "CabinFireflyWindow", Vector3.new(7, 7, 1), CFrame.new(cabinPos + Vector3.new(dx, 15, -15)), Color3.fromRGB(255, 220, 111), Enum.Material.Neon)
			light(window, Color3.fromRGB(255, 206, 93), 0.7, 15)
		end
		for i = 1, 6 do
			local firefly = part(deco, "ForestFirefly_" .. i, Vector3.new(1.2, 1.2, 1.2), CFrame.new(x + rng:NextInteger(-130, 130), rng:NextInteger(5, 14), z + rng:NextInteger(-130, 130)), Color3.fromRGB(149, 255, 184), Enum.Material.Neon, Enum.PartType.Ball)
			firefly.CanCollide = false
			light(firefly, firefly.Color, 0.7, 12)
		end
	elseif name == "NeonJunkyard" then
		for i = 1, 13 do
			local angle = (i / 13) * math.pi * 2
			local radius = rng:NextNumber(82, 154)
			local pos = Vector3.new(x + math.cos(angle) * radius, 1, z + math.sin(angle) * radius)
			local h = rng:NextInteger(14, 36)
			local tower = part(zone, "ScrapTower_" .. i, Vector3.new(rng:NextInteger(12, 23), h, rng:NextInteger(12, 23)), CFrame.new(pos + Vector3.new(0, h / 2, 0)) * CFrame.Angles(0, math.rad(rng:NextInteger(0, 90)), 0), i % 2 == 0 and Color3.fromRGB(113, 124, 143) or Color3.fromRGB(76, 88, 104), Enum.Material.CorrodedMetal)
			tower:SetAttribute("Decor", true)
			local stripe = part(zone, "ScrapNeonStripe_" .. i, Vector3.new(2, 2, 15), tower.CFrame * CFrame.new(0, -h / 2 + 5, -8), i % 2 == 0 and data.glow or data.accent, Enum.Material.Neon)
			stripe.CanCollide = false
		end
		part(zone, "ConveyorBelt", Vector3.new(28, 2, 126), CFrame.new(x - 112, 2, z + 15), Color3.fromRGB(44, 49, 59), Enum.Material.Metal)
		for i = 1, 9 do
			part(zone, "BeltRoller_" .. i, Vector3.new(2, 3, 29), CFrame.new(x - 112, 3.5, z - 42 + i * 14), data.accent, Enum.Material.Metal)
		end
		local arch1 = part(zone, "LaserGatePost_L", Vector3.new(3, 18, 3), CFrame.new(x + 38, 9, z - 20), Color3.fromRGB(48, 58, 70), Enum.Material.Metal)
		part(zone, "LaserGatePost_R", Vector3.new(3, 18, 3), CFrame.new(x + 72, 9, z - 20), Color3.fromRGB(48, 58, 70), Enum.Material.Metal)
		local laser = part(zone, "LaserGate", Vector3.new(1, 12, 31), CFrame.new(x + 55, 9, z - 20), data.glow, Enum.Material.Neon)
		laser.Transparency = 0.2
		laser.CanCollide = false
		arch1:SetAttribute("Obstacle", true)
	elseif name == "VolcanoTemple" then
		-- Layered stepped mountain gives the temple a strong silhouette and a climbable route.
		for step = 1, 5 do
			local width = 228 - step * 31
			local y = step * 11
			part(zone, "TempleMountainTier_" .. step, Vector3.new(width, 15, width), CFrame.new(x, y, z), step % 2 == 0 and Color3.fromRGB(97, 56, 49) or Color3.fromRGB(119, 65, 50), Enum.Material.Basalt)
		end
		for step = 1, 5 do
			local y = step * 11 + 8
			local stair = part(zone, "TempleStair_" .. step, Vector3.new(34, 2, 19), CFrame.new(x + 48, y, z - 99 + step * 38), Color3.fromRGB(194, 130, 83), Enum.Material.Slate)
			stair:SetAttribute("WalkableRoute", true)
		end
		-- Broad summit arena, pillars and central idol.
		cylinder(zone, "BossArenaFloor", 92, 4, Vector3.new(x, 59, z), Color3.fromRGB(76, 38, 39), Enum.Material.Slate)
		cylinder(zone, "BossArenaRune", 68, 0.6, Vector3.new(x, 61.3, z), data.glow, Enum.Material.Neon).Transparency = 0.2
		for i = 1, 8 do
			local a = math.rad(i * 45)
			local pillar = part(zone, "ArenaPillar_" .. i, Vector3.new(8, 24, 8), CFrame.new(x + math.cos(a) * 49, 73, z + math.sin(a) * 49), Color3.fromRGB(86, 54, 47), Enum.Material.Basalt)
			local flame = part(zone, "ArenaFlame_" .. i, Vector3.new(3, 4, 3), pillar.CFrame * CFrame.new(0, 1, 0), data.glow, Enum.Material.Neon)
			flame.CanCollide = false
			light(flame, data.glow, 0.8, 18)
		end
		local idol = part(zone, "GiantTempleIdol", Vector3.new(24, 31, 18), CFrame.new(x, 78, z), Color3.fromRGB(201, 111, 61), Enum.Material.Metal)
		label(idol, "BOSS ARENA", data.glow, Vector3.new(0, 20, 0))
		-- Lava channels sit around the outside edge, not across the main entrance.
		for i = 1, 4 do
			local side = i % 2 == 0 and 1 or -1
			local lava = part(zone, "LavaChannel_" .. i, Vector3.new(18, 1, 104), CFrame.new(x + side * (120 + math.floor(i / 3) * 23), 1.2, z + (i <= 2 and -115 or 115)), Color3.fromRGB(255, 86, 35), Enum.Material.Neon)
			lava:SetAttribute("Hazard", true)
			light(lava, Color3.fromRGB(255, 84, 25), 0.7, 20)
		end
	end
end

local function buildZone(root: Instance, name: string, data)
	local zones = folder(root, "Zones")
	local zone = folder(zones, name)
	local center = data.center
	-- Distinct, generous zone footprint and a readable central clearing.
	part(zone, "ZoneGround", Vector3.new(350, 3, 350), CFrame.new(center + Vector3.new(0, -0.5, 0)), data.ground, Enum.Material.Grass)
	part(zone, "MainPath", Vector3.new(24, 1.2, 225), CFrame.new(center + Vector3.new(0, 1.5, 0)), data.path, Enum.Material.Slate)
	part(zone, "CrossPath", Vector3.new(208, 1.2, 22), CFrame.new(center + Vector3.new(0, 1.55, 38)), data.path, Enum.Material.Slate)
	-- Gateway and big sign act as a clear destination landmark.
	local gateFolder = folder(zone, "ZoneEntrance")
	part(gateFolder, "GatePost_L", Vector3.new(8, 24, 8), CFrame.new(center + Vector3.new(-25, 12, -153)), data.accent, Enum.Material.Slate)
	part(gateFolder, "GatePost_R", Vector3.new(8, 24, 8), CFrame.new(center + Vector3.new(25, 12, -153)), data.accent, Enum.Material.Slate)
	local header = part(gateFolder, "ZoneNameSign", Vector3.new(66, 10, 5), CFrame.new(center + Vector3.new(0, 27, -153)), Color3.fromRGB(35, 39, 50), Enum.Material.Slate)
	label(header, data.sign, data.glow, Vector3.new(0, 7, 0))
	local spawnFolder = folder(root, "SpawnPoints")
	for i = 1, 8 do
		local angle = math.rad((i - 1) * 45)
		local radius = i <= 4 and 62 or 128
		createSpawn(spawnFolder, name .. "_CreatureSpawn_" .. string.format("%02d", i), center + Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius), data.glow)
	end
	createCheckpoint(zone, name .. "_Checkpoint_01", center + Vector3.new(-75, 2, -12))
	createCheckpoint(zone, name .. "_Checkpoint_02", center + Vector3.new(75, 2, 85))
	createSafeZone(root, name .. "_SafeZone", center + Vector3.new(-80, 2, 90), 23)
	-- Every themed zone gets a secret nook and a friendly cat push prompt.
	local secret = part(zone, "SecretRoom_" .. name, Vector3.new(27, 12, 25), CFrame.new(center + Vector3.new(135, 7, 132)), Color3.fromRGB(42, 50, 67), Enum.Material.Slate)
	secret:SetAttribute("SecretRoom", true)
	label(secret, "SECRET NOOK", data.glow, Vector3.new(0, 10, 0))
	local cat = part(zone, "PushTheCat_" .. name, Vector3.new(5, 3, 4), CFrame.new(center + Vector3.new(135, 14, 132)), Color3.fromRGB(255, 213, 147), Enum.Material.SmoothPlastic)
	cat:SetAttribute("EasterEgg", "Push the cat")
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Push gently"
	prompt.ObjectText = "Bunker cat"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.Parent = cat
	-- Obstacle route is parallel to, not blocking, the broad 24-stud main path.
	local obstacles = folder(root, "Obstacles")
	local obstacleFolder = folder(obstacles, name)
	local platform = part(obstacleFolder, "MovingPlatform_" .. name, Vector3.new(24, 2, 18), CFrame.new(center + Vector3.new(44, 5, -68)), data.accent, Enum.Material.Neon)
	platform:SetAttribute("ObstacleType", "MovingPlatform")
	local spinner = part(obstacleFolder, "Spinner_" .. name, Vector3.new(36, 2, 5), CFrame.new(center + Vector3.new(-45, 5, 66)), data.accent, Enum.Material.Neon)
	spinner:SetAttribute("ObstacleType", "Spinner")
	addZoneLandmarks(root, name, data, zone)
end

local function buildRoads(root: Instance)
	local roads = folder(root, "Decor")
	-- Four 24-stud race lanes connect the hub to each biome without crossing buildings.
	for name, data in pairs(zoneData) do
		local center = data.center
		local distance = center.Magnitude
		local direction = center.Unit
		local start = direction * 111
		local finish = direction * (distance - 170)
		beamPath(roads, name .. "_MainRaceLane", start, finish, 24, data.path, 0.55)
		-- Bright edge markers guide players at night.
		for _, t in ipairs({0.18, 0.38, 0.58, 0.78}) do
			local pos = start:Lerp(finish, t)
			for _, side in ipairs({-1, 1}) do
				local offset = Vector3.new(-direction.Z, 0, direction.X) * side * 14
				local marker = part(roads, name .. "_RoadMarker", Vector3.new(2, 1, 5), CFrame.new(pos + offset + Vector3.new(0, 1.5, 0)), data.glow, Enum.Material.Neon)
				marker.CanCollide = false
			end
		end
	end
	-- A complete circular service path links all eight personal plots.
	for i = 1, 8 do
		local a1 = math.rad((i - 1) * 45 + 22.5)
		local a2 = math.rad(i * 45 + 22.5)
		local p1 = Vector3.new(math.cos(a1) * 293, 0, math.sin(a1) * 293)
		local p2 = Vector3.new(math.cos(a2) * 293, 0, math.sin(a2) * 293)
		beamPath(roads, "BaseRingRoad_" .. i, p1, p2, 16, Color3.fromRGB(114, 125, 139), 0.45)
	end
end

local function buildSecretProps(root: Instance)
	local decor = folder(root, "Decor")
	for i, pos in ipairs({Vector3.new(105, 1, 160), Vector3.new(-105, 1, 160), Vector3.new(160, 1, -105), Vector3.new(-160, 1, -105)}) do
		local statue = part(decor, "HubToyStatue_" .. i, Vector3.new(13, 18, 13), CFrame.new(pos + Vector3.new(0, 9, 0)), i % 2 == 0 and Color3.fromRGB(255, 125, 104) or Color3.fromRGB(131, 118, 255), Enum.Material.SmoothPlastic)
		label(statue, i % 2 == 0 and "SILLY STATUE" or "GIANT TOY", C.white, Vector3.new(0, 12, 0))
	end
end

local function setupLighting()
	Lighting.ClockTime = 14
	Lighting.Brightness = 2.3
	Lighting.Ambient = Color3.fromRGB(126, 137, 158)
	Lighting.OutdoorAmbient = Color3.fromRGB(143, 151, 164)
	Lighting.FogColor = Color3.fromRGB(172, 201, 224)
	Lighting.FogEnd = 1250
	Lighting.GlobalShadows = true
end

local function build()
	local old = Workspace:FindFirstChild(ROOT_NAME)
	if old then old:Destroy() end
	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace
	for _, name in ipairs({"Hub", "Bases", "Zones", "SpawnPoints", "Obstacles", "Decor", "SafeZones", "Collectibles", "Enemies"}) do
		folder(root, name)
	end
	-- One continuous playable ground plane; roads and biome pads sit cleanly on top.
	part(root, "WorldGround", Vector3.new(1500, 8, 1500), CFrame.new(0, -4, 0), C.grass, Enum.Material.Grass)
	part(root, "WorldEdge_N", Vector3.new(1500, 30, 8), CFrame.new(0, 11, -750), C.darkGrass, Enum.Material.Rock)
	part(root, "WorldEdge_S", Vector3.new(1500, 30, 8), CFrame.new(0, 11, 750), C.darkGrass, Enum.Material.Rock)
	part(root, "WorldEdge_E", Vector3.new(8, 30, 1500), CFrame.new(750, 11, 0), C.darkGrass, Enum.Material.Rock)
	part(root, "WorldEdge_W", Vector3.new(8, 30, 1500), CFrame.new(-750, 11, 0), C.darkGrass, Enum.Material.Rock)
	setupLighting()
	buildRoads(root)
	buildHub(root)
	buildBases(root)
	for name, data in pairs(zoneData) do buildZone(root, name, data) end
	buildSecretProps(root)
	Workspace:SetAttribute("BrainrotBunkerMapBuilt", true)
	print("BRAINROT BUNKER: connected map generated successfully")
end

build()
