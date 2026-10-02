# Salvage Run build log

## Contract and environment
- Read the entire design specification and one-shot build prompt. The prompt wins conflicts: Grassland is Stage 1; exact stats override the spec's incompatible claim that every fresh vehicle beats every maxed predecessor.
- Studio: Salvage Run, place 120476079479285; streaming already enabled. All game scripts are repo files synced by Rojo. World and asset operations use Studio MCP.
- `docs/ui-reference/` is absent. No reference images were supplied, so side-by-side reference comparison cannot be verified. Follow the specified chunky rounded outlines, bright semantic colors, Fredoka/Luckiest Guy typography, icon buttons, bouncy transitions and sparse mobile HUD.
- Inspect the single supplied Free Icon Pack 3.0.1 (Basic) and use it consistently for icons; build panels/buttons in the shared UIKit. No artwork from another game.
- Choices: forward is negative Z; Safe Line Z=0; strip 160 wide, 3500 long; base 360 wide, 180 deep; exactly four plots. Plain banked items pay Cash and also register a displayable Collection entry. Mutation size rolls apply to all banked items.
- No permission questions: the supplied prompt authorizes the complete build, world editing, safety scans, debugging and commits.

## Verification policy
Only mark PASS after observed evidence. Missing references, live persistence verification, phone emulation and unavailable assets must be reported, never silently treated as passed.

## Phase 1 — map
- Built four plots, twelve provisioned pedestals each (four visible), wide base, shared bay, full-width Safe Line, ten 350-stud stages, arches and collidable perimeter walls. Deleted Baseplate after new ground existed. Streaming on.
- PASS (server inspection during Play): 10 stage folders, exactly 4 plots, all walls collidable, no Baseplate. Character navigation reached bay.
- FAIL / UNVERIFIED: stage visual distinctness and floating/clipping checks. Every MCP screen capture returns black 3D viewport, including Play with visible Roblox core UI. Camera and character positions are valid. Attempt to enable 3D rendering is blocked by RobloxScript capability. Will revisit with game UI and camera.
- MISSING FROM TOOLBOX: spaceship wreck (two candidates rejected at 195 / 253 parts); six-part metallic broken-hull placeholder. All other required map props found. One selected server rack is detailed mesh geometry: profile on phone later.
- Repaired asset capability flags after sanitization; all import code removed. Asset audit records suspicious MarketplaceService/obfuscated code and rejected high-part packs.
- No supplied UI reference images; kit selection recorded above.

SAVE POINT 1

## Phase 2 — vehicles and input
- Imported all 10 vehicle shells, removed all original chassis code, and wired every vehicle to the same VehicleSeat controller and config. Added validated START, spawn alignment/block avoidance, ghosted player/vehicle collision groups, direct low-speed steering, brake/reverse, upright stabilization, flip recovery, follow camera, boost and hop requests.
- PASS: START actual mouse click seats and starts; W moves Skateboard; A/D changes heading; S reverses; Skateboard overturn injection recovered upright before follow-up observation. Vehicle 5 drove 272 studs with min up-vector 1.0; first top-speed check 61.59 vs 70 found friction issue and fixed chassis friction weighting. Vehicle 10 retest measured 103.96 vs 104, min up-vector 1.0, distance 452 studs. Vehicle 10 low-speed turn/reverse exercised. Server/client ready, no game console errors.
- PARTIAL: full high-speed steering/collision feel on all three target vehicles and phone thumbstick cannot be visually accepted while 3D captures remain black. Desktop HUD captures show readable gold Cash, single-kit icon menu, START and run bars. Cargo rectangles are too wide at six slots; polish to square slots in phase 8.
- Chosen kit: Free Icon Pack 3.0.1 (Basic), the only candidate. Reviewed coin/hammer/book/backpack/gear PNGs: strong dark outlines, bright fills, simple silhouettes match written style. Uploaded seven icons and recorded IDs in Icons.luau. Panels/buttons custom UIKit.
- Session-lock persistence scaffold added early because vehicles need ownership data. Studio tests use a separate `_Studio` DataStore so tests do not touch production progress. Scratch fallback is Studio-only and does not save on API failure. Successful API session observed, rejoin check deferred to phase 7.
- Studio-only test bridge uses attributes because MCP cannot invoke privileged server Bindable callbacks. It is not a client remote and exists only on the server. Owner UI debug requests remain separately authorized.

SAVE POINT 2

## Phase 3 — collection field, Cargo, banking
- Built all 60 item configurations and templates, target density 12/stage, timed pickups with decay, local radius ring and progress feedback, lift/spin/arc/shrink FX, icon flight, strict slot limit, auto-scrap, server inward banking and Cargo clearing. Added reusable mutation visuals and reward math now because collectible spawn/banking depends on them.
- PASS: Play started with 120 loot models. Controlled Stage 1 fixture collected six unique plain items; Cargo showed FULL 6/6 and no extra pickup. Real S input drove inward across the line and logged a six-item bank of $415. Cash math from the six registered sizes matched $415 exactly; state returned BASE and vehicle despawned. No game console errors after fixes.
- Fixed Vector3.zero mistakenly called as a function in icon camera. Fixed Safe Line collider preventing returns; updated world source and Edit place. Shells now rest above ground rather than centering large bodies through it.
- PARTIAL: auto-scrap saved option exists in server protocol; Settings interaction and death loss checks follow. 3D world and model icons still capture blank; 2D state and Cash are visible.
- MISSING FROM TOOLBOX: Engine Block (both >300 parts), Crucible (unrelated weapon/buildings), Quantum Drive (unrelated cars), Reactor Rod (unrelated assemblies), Alien Power Cell (unrelated monsters), Impossible Ring (unrelated objects). Each has a clean colored multi-part silhouette in tools/build-fallback-items.luau. Spaceship wreck remains the earlier fallback. Saucer Fragment uses the audited Roblox UFO hull; unrelated fallback search result replaced.
- Exact listed search terms tried first; alias searches used for centrifuge/debris and sci-fi items. Each inserted model scanned immediately. All import scripts removed; the full audit will be regenerated before final delivery.

SAVE POINT 3

## Phase 4 — danger and failure
- Built shared 50-enemy system (five/stage), PATROL/CHASE/ATTACK/RETURN, proximity and pickup noise, stage leashes, red wind-up flashes, chaser/swarm/diver/sentry/hazard-maker behaviors, visible bolts/puddles, 40 themed hazards, HP damage, stacked armor/hover/crush, smoke/low-HP pulse/siren, failure burst and camera hold.
- PASS: Skateboard carrying 6 items plus $123 unbanked was moved to Stage 3 near a Chaser. Failed within the 20-second bound (total run 14.80 seconds, including pickup fixture); HAUL LOST captured; after respawn Cargo=0, unbanked=0, state BASE, permanent Cash remained $415. Server inspection found exactly 50 mobs and zero outside their own stage. No game console errors.
- PARTIAL: all five telegraphs and effect looks cannot be visually accepted while 3D capture is blank. Diver travel and oil/rift feel will be reviewed in critique. Defaults and hazard colors are distinct by inspection.
- Replaced an unrelated android/anime search candidate with a genuine audited robot, tinted later for lab use. All AI/animation code from Toolbox stripped.

SAVE POINT 4
