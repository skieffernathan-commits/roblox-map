# BRAINROT BUNKER: SURVIVE THE NIGHT

A Rojo-ready Roblox map prototype with a connected, colorful low-poly layout. The current generator is a **map-building script**; game systems such as saving, combat damage, ownership, upgrades, and a functional leaderboard need their own server scripts.

## Use in Roblox Studio

1. Open a new Baseplate experience.
2. In Explorer, open `ServerScriptService` and add a `Script` named `BrainrotBunkerMap`.
3. Copy the complete contents of `src/ServerScriptService/BrainrotBunkerMap.server.lua` into it.
4. Press **Play**. The map appears under `Workspace/BRAINROT_BUNKER`.
5. If testing only the generated map, delete or disable the old map script first to avoid building two maps.

Rojo users can instead open `default.project.json` and sync the project.

## What the redesigned map builds

- One continuous 1500 x 1500 stud ground with clear boundaries.
- A detailed circular hub with clock tower, shop kiosk, leaderboard landmark, lanterns and safe zone.
- Eight individual base plots, each with a front gate, 10 numbered creature pedestals, upgrade station, turret slot and named spawn.
- Four visually distinct biomes placed around the hub: Candy Swamp, Pixel Forest, Neon Junkyard, and Volcano Temple.
- Four 24-stud-wide race lanes plus a complete base-ring road.
- Eight named creature spawn markers and two named checkpoint arches in every biome.
- Zone entrance signs, secret nooks, cat easter eggs, landmark clusters and optional obstacle routes.
- A stepped volcano, summit boss arena, temple idol, pillars and lava channels.
- Organized `Hub`, `Bases`, `Zones`, `SpawnPoints`, `Obstacles`, `Decor`, `SafeZones`, `Collectibles` and `Enemies` folders inside the generated model.

The generator uses anchored, simple Parts and moderate detail so it is straightforward to edit in Studio. The map geometry and spawn markers do not by themselves implement monster AI, damage, persistence, base ownership, shop purchases or boss scheduling.
