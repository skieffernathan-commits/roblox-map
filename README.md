# BRAINROT BUNKER: SURVIVE THE NIGHT

This repository contains a Roblox map generator for a stylized multiplayer survival game built around the concept below:

- Central hub with a circular plaza and day/night clock tower
- 8 personal bases distributed around the hub
- 4 themed wildlife zones with increasing difficulty
- Safe zones, checkpoints, obstacles, and boss arena references
- A Rojo-ready project layout for easy syncing into Roblox Studio

## Project layout

- `src/ServerScriptService/BrainrotBunkerMap.server.lua` — builds the map and environment when the game starts
- `default.project.json` — Rojo project definition

## How to use

1. Open the project in Roblox Studio using Rojo.
2. Sync the project.
3. Run the game and the `BrainrotBunkerMap` script will generate the full map in `Workspace/BRAINROT_BUNKER`.

## Included map features

- 1500 x 1500 stud playable field
- Hub and ring layout per specification
- 8 personal bases with pedestals, gate, upgrade station and turret slot
- Candy Swamp, Pixel Forest, Neon Junkyard and Volcano Temple zones
- Named spawn points and checkpoints for scripting
- Mobile-friendly low-detail geometry with folder organization

## Notes

The map is generated procedurally from Lua so it can be tuned easily for building scale, colors, layout spacing, and difficulty.
