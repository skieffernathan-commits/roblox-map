local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local rootName = "BRAINROT_BUNKER"

local function clearExistingMap()
	local existing = Workspace:FindFirstChild(rootName)
	if existing then
		existing:Destroy()
	end

	for _, folderName in ipairs({"Hub", "Bases", "Zones", "SpawnPoints", "Obstacles", "Decor", "SafeZones"}) do
		local folder = Workspace:FindFirstChild(folderName)
		if folder then
			folder:Destroy()
		end
	end
end

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if folder then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function makePart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addBillboard(part, text, color, offset)
	local gui = Instance.new("BillboardGui")
	gui.Name = part.Name .. "Label"
	gui.Size = UDim2.fromOffset(280, 70)
	gui.StudsOffset = offset or Vector3.new(0, 8, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.2
	label.Parent = gui
end

local function addLight(part, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Parent = part
end

local function createSpawnMarker(parent, name, position, color)
	local marker = makePart(parent, name, Vector3.new(4, 1, 4), CFrame.new(position + Vector3.new(0, 1, 0)), color, Enum.Material.Neon)
	marker.Transparency = 0.2
	marker.CanCollide = false
	return marker
end

local function createSafeZone(parent, name, position, size, color)
	local safeZone = makePart(parent, name, size, CFrame.new(position), color, Enum.Material.Neon)
	safeZone.Transparency = 0.5
	safeZone.CanCollide = false
	addLight(safeZone, color, 1.5, 18)
	return safeZone
end

local function buildHub(root)
	local hubFolder = ensureFolder(root, "Hub")
	local spawnFolder = ensureFolder(root, "SpawnPoints")
	local decorFolder = ensureFolder(root, "Decor")
	local safeZoneFolder = ensureFolder(root, "SafeZones")

	makePart(hubFolder, "Ground", Vector3.new(1500, 4, 1500), CFrame.new(0, -2, 0), Color3.fromRGB(26, 54, 39), Enum.Material.Grass)
	makePart(hubFolder, "OuterRing", Vector3.new(620, 2, 620), CFrame.new(0, 0.5, 0), Color3.fromRGB(103, 82, 128), Enum.Material.SmoothPlastic)
	makePart(hubFolder, "CentralPlaza", Vector3.new(220, 2, 220), CFrame.new(0, 1, 0), Color3.fromRGB(89, 135, 154), Enum.Material.SmoothPlastic)

	local clockTower = makePart(hubFolder, "ClockTower", Vector3.new(24, 110, 24), CFrame.new(0, 55, 0), Color3.fromRGB(242, 210, 95), Enum.Material.Metal)
	local clockFace = makePart(hubFolder, "ClockFace", Vector3.new(32, 32, 4), CFrame.new(0, 80, 12), Color3.fromRGB(31, 39, 54), Enum.Material.SmoothPlastic)
	clockFace.CanCollide = false
	addBillboard(clockTower, "DAY / NIGHT", Color3.fromRGB(255, 245, 180), Vector3.new(0, 18, 0))
	addBillboard(clockFace, "12:00", Color3.fromRGB(255, 255, 255), Vector3.new(0, 2, 0))

	local shop = makePart(hubFolder, "ShopKiosk", Vector3.new(28, 16, 24), CFrame.new(60, 8, 0), Color3.fromRGB(255, 138, 70), Enum.Material.SmoothPlastic)
	local board = makePart(hubFolder, "LeaderboardBoard", Vector3.new(70, 32, 4), CFrame.new(-70, 18, 0), Color3.fromRGB(44, 52, 66), Enum.Material.SmoothPlastic)
	board.CanCollide = false
	addBillboard(board, "LEADERBOARD", Color3.fromRGB(255, 210, 97), Vector3.new(0, 6, 0))

	local hubSpawn = Instance.new("SpawnLocation")
	hubSpawn.Name = "HubSpawn_01"
	hubSpawn.Size = Vector3.new(8, 1, 8)
	hubSpawn.Position = Vector3.new(0, 2, 0)
	hubSpawn.Anchored = true
	hubSpawn.Neutral = true
	hubSpawn.Color = Color3.fromRGB(122, 255, 160)
	hubSpawn.Material = Enum.Material.SmoothPlastic
	hubSpawn.Parent = spawnFolder

	local safeZone = createSafeZone(safeZoneFolder, "HubSafeZone", Vector3.new(0, 1, 0), Vector3.new(140, 2, 140), Color3.fromRGB(104, 255, 129))
	safeZone.CanCollide = false

	for _, deco in ipairs({
		{ "FruitStatue", Vector3.new(-112, 10, -36), Vector3.new(12, 18, 12), Color3.fromRGB(255, 127, 80) },
		{ "ToyTower", Vector3.new(112, 12, 44), Vector3.new(18, 24, 18), Color3.fromRGB(142, 96, 255) },
		{ "LanternPost", Vector3.new(90, 7, -70), Vector3.new(4, 14, 4), Color3.fromRGB(255, 218, 94) },
		{ "LanternPost", Vector3.new(-90, 7, 70), Vector3.new(4, 14, 4), Color3.fromRGB(255, 218, 94) },
	}) do
		local part = makePart(decorFolder, deco[1], deco[3], CFrame.new(deco[2]), deco[4], Enum.Material.SmoothPlastic)
		if deco[1] == "LanternPost" then
			addLight(part, Color3.fromRGB(255, 218, 94), 1.2, 18)
		end
	end
end

local function buildBases(root)
	local baseFolder = ensureFolder(root, "Bases")
	local spawnFolder = ensureFolder(root, "SpawnPoints")

	for index = 1, 8 do
		local angle = math.rad((index - 1) * 45)
		local x = math.cos(angle) * 330
		local z = math.sin(angle) * 330
		local base = ensureFolder(baseFolder, "Base_" .. index)

		makePart(base, "BasePad", Vector3.new(80, 2, 80), CFrame.new(x, 0, z), Color3.fromRGB(168, 202, 126), Enum.Material.Grass)
		makePart(base, "Gate", Vector3.new(8, 16, 30), CFrame.new(x + math.cos(angle) * 24, 8, z + math.sin(angle) * 24), Color3.fromRGB(58, 98, 74), Enum.Material.Metal)
		makePart(base, "UpgradeStation", Vector3.new(18, 10, 18), CFrame.new(x - 18, 5, z + 18), Color3.fromRGB(90, 122, 196), Enum.Material.Metal)
		makePart(base, "TurretSlot", Vector3.new(10, 8, 10), CFrame.new(x + 18, 4, z - 16), Color3.fromRGB(255, 158, 70), Enum.Material.Neon)

		for pedestalIndex = 1, 10 do
			local offsetX = ((pedestalIndex - 1) % 5) * 9 - 18
			local offsetZ = math.floor((pedestalIndex - 1) / 5) * 9 - 9
			local pedestal = makePart(base, "Pedestal_" .. pedestalIndex, Vector3.new(6, 8, 6), CFrame.new(x + offsetX, 4, z + offsetZ), Color3.fromRGB(225, 230, 244), Enum.Material.SmoothPlastic)
			pedestal.Color = Color3.fromRGB(198, 210, 228)
		end

		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "BaseSpawn_" .. index
		spawn.Size = Vector3.new(8, 1, 8)
		spawn.Position = Vector3.new(x, 2, z)
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Color = Color3.fromRGB(127, 197, 255)
		spawn.Material = Enum.Material.SmoothPlastic
		spawn.Parent = spawnFolder
	end
end

local function createZone(root, zoneName, position, palette, difficulty)
	local zoneFolder = ensureFolder(root, zoneName)
	local obstacleFolder = ensureFolder(root, "Obstacles")
	local safeZoneFolder = ensureFolder(root, "SafeZones")
	local spawnFolder = ensureFolder(root, "SpawnPoints")

	local ground = makePart(zoneFolder, "ZoneGround", Vector3.new(260, 4, 260), CFrame.new(position + Vector3.new(0, -2, 0)), palette.ground, Enum.Material.Grass)
	ground.Material = Enum.Material.Grass
	makePart(zoneFolder, "Path", Vector3.new(110, 1, 60), CFrame.new(position + Vector3.new(0, 0.5, 0)), palette.path, Enum.Material.SmoothPlastic)

	for bushIndex = 1, 12 do
		local angle = math.rad((bushIndex / 12) * 360)
		local x = math.cos(angle) * 90
		local z = math.sin(angle) * 90
		makePart(zoneFolder, "Bush_" .. bushIndex, Vector3.new(12, 9, 12), CFrame.new(position + Vector3.new(x, 5, z)), palette.bush, Enum.Material.SmoothPlastic)
	end

	for idx = 1, 8 do
		local angle = math.rad((idx / 8) * 360)
		local x = math.cos(angle) * 90
		local z = math.sin(angle) * 90
		createSpawnMarker(spawnFolder, zoneName .. "_Spawn_" .. idx, position + Vector3.new(x, 1, z), palette.spawn)
	end

	local leftCheckpoint = makePart(zoneFolder, "Checkpoint_01", Vector3.new(18, 4, 18), CFrame.new(position + Vector3.new(-55, 2, 20)), Color3.fromRGB(79, 255, 139), Enum.Material.Neon)
	leftCheckpoint.CanCollide = false
	local rightCheckpoint = makePart(zoneFolder, "Checkpoint_02", Vector3.new(18, 4, 18), CFrame.new(position + Vector3.new(55, 2, -20)), Color3.fromRGB(79, 255, 139), Enum.Material.Neon)
	rightCheckpoint.CanCollide = false

	createSafeZone(safeZoneFolder, zoneName .. "_SafeZone", position + Vector3.new(0, 0.5, 0), Vector3.new(90, 2, 90), palette.safe)

	if zoneName == "VolcanoTemple" then
		local idol = makePart(zoneFolder, "GiantIdol", Vector3.new(36, 54, 36), CFrame.new(position + Vector3.new(0, 27, 0)), Color3.fromRGB(255, 160, 72), Enum.Material.Metal)
		local arena = makePart(zoneFolder, "BossArena", Vector3.new(120, 2, 120), CFrame.new(position + Vector3.new(0, 0.5, 0)), Color3.fromRGB(120, 33, 31), Enum.Material.SmoothPlastic)
		arena.CanCollide = false
		safeZoneFolder:FindFirstChild(zoneName .. "_SafeZone").Transparency = 0.35
		addBillboard(idol, "BOSS", Color3.fromRGB(255, 213, 100), Vector3.new(0, 25, 0))
	end

	local obstacleSet = ensureFolder(obstacleFolder, zoneName)
	local movingPlatform = makePart(obstacleSet, "MovingPlatform", Vector3.new(20, 2, 20), CFrame.new(position + Vector3.new(0, 8, -30)), palette.accent, Enum.Material.Neon)
	movingPlatform.CanCollide = true
	local spinner = makePart(obstacleSet, "Spinner", Vector3.new(18, 4, 18), CFrame.new(position + Vector3.new(40, 6, 35)), palette.accent, Enum.Material.Neon)
	spinner.CanCollide = false
	makePart(obstacleSet, "LaserGate", Vector3.new(3, 18, 35), CFrame.new(position + Vector3.new(-35, 9, 10)), Color3.fromRGB(255, 76, 76), Enum.Material.Neon)
	makePart(obstacleSet, "WaveZone", Vector3.new(70, 2, 20), CFrame.new(position + Vector3.new(0, 1.5, 35)), Color3.fromRGB(157, 208, 255), Enum.Material.SmoothPlastic)

	if zoneName == "NeonJunkyard" then
		local belt = makePart(obstacleSet, "ConveyorBelt", Vector3.new(100, 2, 14), CFrame.new(position + Vector3.new(0, 2, 20)), Color3.fromRGB(52, 55, 65), Enum.Material.SmoothPlastic)
		belt.CanCollide = false
	end

	if zoneName == "CandySwamp" then
		for i = 1, 6 do
			local mushroom = makePart(zoneFolder, "Mushroom_" .. i, Vector3.new(6, 16, 6), CFrame.new(position + Vector3.new((i - 3.5) * 14, 8, 50)), Color3.fromRGB(255, 169, 204), Enum.Material.SmoothPlastic)
			mushroom.Color = Color3.fromRGB(255, 182, 214)
		end
	end

	if zoneName == "PixelForest" then
		for i = 1, 8 do
			local tree = makePart(zoneFolder, "Tree_" .. i, Vector3.new(12, 36, 12), CFrame.new(position + Vector3.new((i - 4.5) * 18, 18, 40 - (i % 2) * 20)), Color3.fromRGB(82, 102, 76), Enum.Material.SmoothPlastic)
			tree.Color = Color3.fromRGB(94, 122, 80)
		end
	end

	if zoneName == "VolcanoTemple" then
		for i = 1, 6 do
			local lava = makePart(zoneFolder, "LavaRiver_" .. i, Vector3.new(24, 3, 90), CFrame.new(position + Vector3.new((i - 3.5) * 22, 1.5, 0)), Color3.fromRGB(255, 93, 40), Enum.Material.Neon)
			lava.Transparency = 0.1
			addLight(lava, Color3.fromRGB(255, 120, 60), 1.8, 20)
		end
	end
end

local function buildZones(root)
	local zoneDefinitions = {
		{
			name = "CandySwamp",
			position = Vector3.new(-550, 0, -550),
			palette = { ground = Color3.fromRGB(80, 190, 122), path = Color3.fromRGB(255, 205, 128), bush = Color3.fromRGB(69, 163, 116), spawn = Color3.fromRGB(164, 255, 188), accent = Color3.fromRGB(255, 214, 118), safe = Color3.fromRGB(108, 255, 148) },
		},
		{
			name = "PixelForest",
			position = Vector3.new(550, 0, -550),
			palette = { ground = Color3.fromRGB(63, 112, 89), path = Color3.fromRGB(82, 148, 132), bush = Color3.fromRGB(54, 82, 61), spawn = Color3.fromRGB(118, 236, 255), accent = Color3.fromRGB(123, 242, 148), safe = Color3.fromRGB(67, 215, 168) },
		},
		{
			name = "NeonJunkyard",
			position = Vector3.new(-550, 0, 550),
			palette = { ground = Color3.fromRGB(82, 89, 108), path = Color3.fromRGB(124, 138, 185), bush = Color3.fromRGB(89, 99, 123), spawn = Color3.fromRGB(255, 104, 128), accent = Color3.fromRGB(72, 255, 245), safe = Color3.fromRGB(82, 255, 214) },
		},
		{
			name = "VolcanoTemple",
			position = Vector3.new(550, 0, 550),
			palette = { ground = Color3.fromRGB(135, 74, 62), path = Color3.fromRGB(192, 108, 79), bush = Color3.fromRGB(87, 44, 37), spawn = Color3.fromRGB(255, 180, 99), accent = Color3.fromRGB(255, 110, 48), safe = Color3.fromRGB(255, 146, 92) },
		},
	}

	for _, zone in ipairs(zoneDefinitions) do
		createZone(root, zone.name, zone.position, zone.palette, zone.name)
	end
end

local function buildDecor(root)
	local decorFolder = ensureFolder(root, "Decor")
	for _, prop in ipairs({
		{ "OversizedFruit", Vector3.new(-130, 8, 150), Vector3.new(16, 16, 16), Color3.fromRGB(255, 139, 78) },
		{ "GiantToyBlock", Vector3.new(130, 8, -150), Vector3.new(22, 22, 22), Color3.fromRGB(255, 218, 89) },
		{ "FunnyStatue", Vector3.new(150, 8, 130), Vector3.new(14, 20, 14), Color3.fromRGB(124, 91, 255) },
		{ "FloatingSign", Vector3.new(-150, 12, -120), Vector3.new(18, 10, 3), Color3.fromRGB(117, 225, 255) },
	}) do
		local part = makePart(decorFolder, prop[1], prop[3], CFrame.new(prop[2]), prop[4], Enum.Material.SmoothPlastic)
		addBillboard(part, string.upper(prop[1]), Color3.fromRGB(255, 255, 255), Vector3.new(0, 8, 0))
	end
end

local function buildSecretAreas(root)
	local secretFolder = ensureFolder(root, "Decor")
	local secretRoom = makePart(secretFolder, "HiddenSecretRoom", Vector3.new(30, 10, 30), CFrame.new(0, 5, -220), Color3.fromRGB(120, 200, 255), Enum.Material.SmoothPlastic)
	secretRoom.Transparency = 0.35
	addBillboard(secretRoom, "SHHH... CAT", Color3.fromRGB(255, 255, 255), Vector3.new(0, 12, 0))

	for _, catSpot in ipairs({
		Vector3.new(75, 3, -220),
		Vector3.new(-75, 3, 220),
		Vector3.new(220, 3, 75),
		Vector3.new(-220, 3, -75),
	}) do
		local cat = makePart(secretFolder, "CatButton_" .. tostring(catSpot), Vector3.new(6, 3, 6), CFrame.new(catSpot), Color3.fromRGB(250, 221, 145), Enum.Material.SmoothPlastic)
		cat.CanCollide = false
	end
end

local function buildAtmosphere()
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(128, 140, 170)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 138, 168)
	Lighting.ClockTime = 14
	Lighting.FogColor = Color3.fromRGB(124, 113, 180)
	Lighting.FogEnd = 900
	Lighting.ColorShift_Top = Color3.fromRGB(64, 77, 120)
	Lighting.ColorShift_Bottom = Color3.fromRGB(18, 10, 38)
end

local function main()
	clearExistingMap()
	local root = Instance.new("Folder")
	root.Name = rootName
	root.Parent = Workspace

	local spawnFolder = ensureFolder(root, "SpawnPoints")
	ensureFolder(root, "Hub")
	ensureFolder(root, "Bases")
	ensureFolder(root, "Zones")
	ensureFolder(root, "Obstacles")
	ensureFolder(root, "Decor")
	ensureFolder(root, "SafeZones")

	buildAtmosphere()
	buildHub(root)
	buildBases(root)
	buildZones(root)
	buildDecor(root)
	buildSecretAreas(root)

	local boundary = makePart(root, "BoundaryWall", Vector3.new(1500, 30, 1500), CFrame.new(0, 12, 0), Color3.fromRGB(70, 64, 88), Enum.Material.SmoothPlastic)
	boundary.Transparency = 1
	boundary.CanCollide = false
	boundary.Name = "PlayableBoundary"

	for _, spawn in ipairs(spawnFolder:GetChildren()) do
		if spawn:IsA("SpawnLocation") then
			spawn.Parent = root
		end
	end
end

main()
