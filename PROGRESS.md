# Salvage Run build log

## Contract and environment
- Read the entire design specification and one-shot build prompt. The prompt wins conflicts: Grassland is Stage 1; exact stats override the spec's incompatible claim that every fresh vehicle beats every maxed predecessor.
- Studio: Salvage Run, place 120476079479285; streaming already enabled. All game scripts are repo files synced by Rojo. World and asset operations use Studio MCP.
- `docs/ui-reference/` is absent. No reference images were supplied, so side-by-side reference comparison cannot be verified. Follow the specified chunky rounded outlines, bright semantic colors, Fredoka/Luckiest Guy typography, icon buttons, bouncy transitions and sparse mobile HUD.
- Inspect the single supplied Free Icon Pack 3.0.1 (Basic) and use it consistently for icons; build panels/buttons in the shared UIKit. No artwork from another game.
- Choices: forward is negative Z; Safe Line Z=0; strip 160 wide, 3500 long; base 360 wide, 180 deep; exactly four plots. Plain banked items pay Cash and also register a displayable Collection entry. Mutation size rolls apply to all banked items.
- Current user coordination override: stop at each SAVE POINT and tell the user to save/publish to Roblox; wait for confirmation before the next phase. Coordinate Play control explicitly while the user may be testing. UIKits is not a recovery blocker; ask for it when a UI phase needs it, and do not start UI-kit work during recovery.

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
- PASS: Skateboard carrying 6 items plus $123 unbanked was moved to Stage 3 near a Chaser. Failed within the 20-second bound (total run 14.80 seconds, including pickup fixture); HAUL LOST captured and permanent Cash display remained $415. No game console errors in that capture.
- UNVERIFIED: post-respawn Cargo/unbanked/state and live 50-mob leash audit. Studio disconnected before those follow-up calls could execute; queued calls returned studio-not-connected. Reconnect and verify before claiming these checks pass.
- PARTIAL: all five telegraphs and effect looks cannot be visually accepted while 3D capture is blank. Diver travel and oil/rift feel will be reviewed in critique. Defaults and hazard colors are distinct by inspection.
- Replaced an unrelated android/anime search candidate with a genuine audited robot, tinted later for lab use. All AI/animation code from Toolbox stripped.

SAVE POINT 4
## Phase 5 — rarity, reveal cards and discovery

- Added rotating mutation reveal cards with exact odds, an Item Index grouped by ten stages, silhouettes, mutation pips and completion percentages. All managed source remains in `src/` and was delivered through Rojo.
- Recovered the current autosave after Studio disconnected. The reopened renderer displays 3D correctly. Exported the current map and all 113 audited model templates into `assets/snapshot/`; `rojo build` now produces a complete place, rather than a script-only scaffold.
- PASS: Studio debug force-spawned all eight Microwave mutations. The field lineup shows gray, silver, gold, cyan, crystal blue, blue flame, flickering magenta and dark purple treatments. Particle motion is present; Glitched jitter and Blue Flame rotation need polish.
- PASS: live RarityMath reports Golden Colossal odds 50,000 and value $6,000. All eight Colossal value/mutation combinations were inspected. Fractional reciprocal odds are rounded only for display.
- PASS: desktop captures `phase5-index-desktop`, `phase5-golden-colossal-reveal` show the Index and rotating card with its 1 in 50,000 label and buttons. Mouse close was exercised. Phone verification is scheduled for Phase 8.
- Console: server and client ready, no runtime error. The warning explicitly reports scratch saves for the unpublished local recovery file. Persistence is UNVERIFIED in this file.
- Current recovery also confirms the visible base and stage strip; the earlier black captures were a Studio rendering problem, not proof of visual acceptance.

SAVE POINT 5

## Phase 6 — ownership and income

- Collection stores the best size by item/mutation. Added local owner-only placement highlights, pedestal swap/remove, rotating displays and approach-only nameplates, bought pedestal slots, passive income and capped offline credit.
- PASS: normal/new mutated/equal duplicate/larger duplicate rules ran in Studio. Golden Microwave sequence normal, normal, Big, normal, Colossal paid $0, $600, $300, $600, $5,100 respectively, without losing the stored best size.
- PASS: four Chrome items placed in an owned plot. Sum = $4.80/sec; sign initially rounded this to $5/sec (FAIL), then fixed and retested: sign `$4.8/sec` exactly matches income. Inventory and nameplate rates now retain cents.
- PASS: Inventory PLACE click creates exactly four Highlights in the owner's plot and zero in all other plots. A world click on an occupied pedestal opens SWAP / REMOVE. Actual REMOVE → Inventory PLACE → world click restored the four-item loadout and $4.8/sec income.
- PASS: offline fixture uses the real join-credit function at a 16-hour absence: $4.8/sec × 8-hour cap × 50% = $69,120 expected and actual. Passive Cash increased during navigation. This tests calculation and credit, not a persistent rejoin.
- Captures: `phase6-inventory-with-four-finds`, `phase6-placed-items-sign`, `phase6-pedestal-interaction`. Four rotating models visible on pedestals; the sign's text was checked on the server.
- Found missing local `impact_generic.mp3` audio; replaced all local sound choices with files verified in Studio's installed content. Retest after cold client reload in Phase 7. No gameplay errors.
- Live persistence and multiplayer ownership under separate actual accounts remain UNVERIFIED. Current local place deliberately uses Studio scratch data.

SAVE POINT 6

## Phase 7 — progression and persistent rejoin

- Garage applies four five-level tracks; Trade Up checks all tracks, banked stage and Cash, keeps earlier vehicles and ownership, and starts the next vehicle with zero levels.
- PASS: one level changed Skateboard stats 40 → 42.4 speed, 100 → 115 HP, 6 → 7 slots, 2 → 2.2 boost seconds and 8 → 7.2 cooldown seconds. At five levels the real spawned Skateboard has speed 52, HP 175 and 11 slots. W driving measured **51.94 studs/sec**, minimum up-vector 1.0. S crossed the Safe Line and banked a real collected item for $50.
- FAIL then FIXED: default seat controls in the recovered Studio session reported ThrottleFloat 0 with W down. Shared controller now reads W/S/A/D explicitly on keyboard; cold-load measured speed passes. Mobile seat input remains for Phase 8 testing.
- PASS: Trade Up unlocked BMX; old maxed Skateboard, ten Collection entries and four pedestal selections survived. A later BMX Trade Up attempt with Stage 1 banked is rejected because Stage 2 must be banked. Garage/trade desktop captures show the conditions.
- PASS: restored metadata to the same original user game (place 120476079479285, universe 10768946482), without publishing. DataService uses its separate `_Studio` DataStore. A real UpdateAsync Save returned true. Stopped Play, rebuilt/cold-opened, and rejoined: Scratch=false, Cash, both vehicles, five-level Skateboard tracks, ten finds, Index, Settings, DeepestBanked=1 and all four pedestal keys loaded correctly. Offline Cash was credited on that real rejoin.
- Found client Ready can arrive before asynchronous data load and miss the offline popup. Credit is correct; popup handshake needs fixing in Phase 8.
- Cold-loaded valid local sound paths; pedestal placement causes no missing-sound error. One console error was QA instrumentation using the wrong folder name; corrected to RunVehicles. A direct MCP remote invocation was blocked by capability metadata, not by game logic; ordinary game UI works.
- Production save namespace is untouched. Actual two-player concurrent lock contention and live-server performance remain UNVERIFIED.

SAVE POINT 7

## Recovery checkpoint after reconnect — verified in Studio Edit

- Target: reopened user-owned place **120476079479285**, Studio `6826b07e-51dc-4354-9b62-f61d51c00698`. Inspected current Edit contents; did not start or stop a playtest.
- Deleted the reintroduced `Workspace.Baseplate`. Initial verification passed, but a subsequent inventory check detected it again. Deleted it again and confirmed absence in a separate read. The cause of reappearance is not established; this is why the new verifier must run after every world change.
- Added `tools/verify-world.luau`, a read-only Edit assertion routine. Actual Studio result: PASS, 4 plots, 48 provisioned pedestals, 10 floors/arches, 80 placed props, 113 sanitized templates (60 items / 10 vehicles / 10 mobs / 33 props), 26 collidable perimeter walls, 3 walls at Stage 10, no Baseplate. User confirmed 26 walls means the whole perimeter.
- A rebuild routine already exists: `tools/build-world.luau` uses Config plus audited templates to reconstruct the static map. `default.project.json` also builds the complete saved map/template snapshot. Documented recovery and required verification in `docs/world-recovery.md`.

### Post-original-deletion edit ledger

Checked PROGRESS order, git history after Phase 1 (`522a571`), and the relevant diffs. These are the later world/template changes and runtime-generated world features:

| Order / checkpoint | World edit | Current Studio spot check |
|---|---|---|
| Phase 1 repairs after the initial build | Reinserted/repaired grass tuft, washing machine, furnace, anchor, lab equipment and test tube templates; cleared asset capabilities and removed imported scripts | All six have geometry, PrimaryParts, anchored parts, empty capability flags and zero scripts. Their placed stage props exist. |
| Phase 2 — `c5df8f4` | Imported and sanitized ten vehicle shells; normalized templates; runtime VehicleSeat/chassis, spawn alignment, collision groups and follow control; PNG icon IDs in the client source | All ten vehicle templates present with PrimaryParts, anchored geometry and zero import scripts. VehicleService and client controller match repo source. Vehicles and HUD are generated in Play; no new driving test was run. |
| Phase 3 — `ee183dd` | Imported sixty item templates; six part-built fallbacks; replaced Saucer Fragment with audited UFO hull | Exactly sixty items present. Engine Block, Crucible, Quantum Drive, Reactor Rod, Alien Power Cell and Impossible Ring have geometry/PrimaryParts and no scripts. Saucer Fragment is the one-part hull from asset 162741606. The six-part spaceship-wreck fallback also remains. |
| Phase 3 — `ee183dd` | Fixed Safe Line collision and vehicle shell ground-height offset | Safe Line is 160 studs wide, CanCollide=false, CanTouch=false. Live VehicleService contains the shell offset fix and matches the repo. |
| Phase 3 — `ee183dd` | Runtime loot density, pickup ring/progress/arc/icon effects, temporary Cargo and inward banking | CollectibleService, CollectionService, ItemVisual and related client source remain. These are generated runtime features, not saved map instances; functional rechecks await an agreed Play handoff. |
| Phase 4 — `7909a05` | Ten sanitized mob templates, including corrected lab robot; runtime fifty mobs, forty hazards, sixteen crates, bolts/puddles, damage warnings and death FX | All ten mob templates present with geometry/PrimaryParts, anchored parts and no imported AI. Lab robot is asset 2783823576. EnemyService and CollectibleService source match repo; runtime parts are correctly absent in Edit. |
| Phase 5 — `8eb8f60` | Recovered/exported the complete static map and 113 models; mutation treatments and temporary eight-mutation showcase | Four plots, ten bands and their signs, eight props per stage, Stage 4 water edges, Stage 10 grid, lighting and all models remain. Mutation source matches repo. The showcase was a temporary Play fixture and must not be saved into the map. |
| Phase 6 — `48eadf0` | Runtime placed-item displays, approach nameplates, owner headshots and income signs; corrected fractional income formatting | All four permanent income signs and all 48 provisioned pedestals exist. Live DisplayService and Format contain the precision fix and match repo. Displayed finds/headshots restore at runtime from player data; Edit has no owner fixtures. |
| Phase 7 — `45d99d5` | Shared keyboard control repair; progression and persistence checks | Live VehicleController includes explicit W/S/A/D and matches repo. This checkpoint introduced no additional static map pieces. |

- No later static/template edit was missing, so no replacement map or models were built. The only missing recovery operation redone was Baseplate removal. Thirteen relevant live source modules were compared with repo source hashes and matched, including vehicle, enemy, collection, economy, data, mutation and UI implementations.
- All ten floor colors/materials match Config. **Visual quality is not accepted by this inventory check:** reopened-place 3D capture is black again. Bounding-box checks also reveal existing prop grounding offsets in several stages, up to ~9.44 studs; floating/clipping cleanup remains outstanding. Phase 1's visual acceptance remains unresolved.
- Data module is the custom `src/server/DataService.luau`, not an external profile library. Verified live source: production `SalvageRun_v1`; Studio `SalvageRun_v1_Studio`; lease 180 seconds, autosave/renewal every 60 seconds. UpdateAsync preserves Data and replaces an expired foreign lock with the new token. A fresh foreign lock is rejected. Save checks ownership to prevent an old session from overwriting a new one. These requested protections already exist; no forced active-lock takeover or new DataStore write was performed.
- Console history includes previous Save failures and save-session kicks. They are not treated as fixed by a source inspection. Runtime lock contention needs a coordinated test; no active user session was interrupted.
- Updated CODEX_PROMPT with publish/Play handoffs, mandatory world verification, editor-only `ServerStorage.UIKits`, PNG location, used-icons-only manifest and user-supplied upload-ID workflow. UIKits is not ready and does not block this recovery. Icon selection, `docs/ui-assets.md` creation and ID changes are deferred until the UI phase, per the user's latest instruction.

SAVE POINT 7 — RECOVERY

STOP: tell the user to save/publish the verified current place to Roblox. Wait for confirmation before Phase 8. Ask for UIKits when that phase needs UI-kit work; coordinate an explicit Play handoff before testing.
