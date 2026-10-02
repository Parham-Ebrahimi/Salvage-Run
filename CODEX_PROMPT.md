# CODEX ONE-SHOT BUILD: SALVAGE RUN (Roblox)

You are building a complete, playable Roblox game in one long autonomous session. Work through every phase below in order without waiting for me. Do not stop to ask questions; when something is ambiguous, pick the option that best matches the design doc, write the decision in `PROGRESS.md`, and keep going.

**User's recovery and coordination rules (override autonomous continuation above):** At every `SAVE POINT`, stop, tell the user to save/publish the current place to Roblox, and wait for their confirmation before starting the next phase. Do not start or stop a playtest while the user may be testing; obtain an explicit handoff before taking control of Play. Never mark work done in `PROGRESS.md` until verified in the connected Studio. Label source-only checks and untested runtime behavior accurately.

After every world mutation, run the read-only `tools/verify-world.luau` against the Edit DataModel. Expected inventory: four plots with twelve provisioned pedestals each, ten stage floors and arches, eight props per stage, 113 templates, 26 perimeter walls across the whole map (Stage 10 has two sides and the final end wall), and no `Workspace.Baseplate`. If the user is playing, defer Edit mutations and verification without stopping their session.

For editing the existing Studio place, serve `live.project.json` on port 34872. It syncs source scripts and preserves unknown instances, including the Studio world, assets, MaterialService variants and UIKits. Reserve `default.project.json` for deliberate snapshot builds/recovery: syncing it can overwrite newer Studio world edits with the older repo snapshot. Check the running Rojo server's actual tree after restarting; editing a project file does not establish which configuration an existing server is serving.

## 0. Read first

**This is a from-scratch build.** The Studio place is an empty Baseplate and the repo contains only this prompt, `docs/SALVAGE_RUN_DESIGN.md` and the Rojo scaffold. Nothing from any earlier version of this game exists; do not look for old code or save data. Delete the default Baseplate part once the new ground exists.

1. Read `docs/SALVAGE_RUN_DESIGN.md` completely. It describes what the game is and how every system behaves. This prompt adds exact numbers, asset lists and build order, and wins any conflict.
2. You are connected to Roblox Studio through the `Roblox_Studio` MCP server. Use it for everything inside the place: `search_asset` / `insert_asset` (Toolbox / Creator Store), `search_game_tree`, `inspect_instance`, `execute_luau`, `start_stop_play`, `user_keyboard_input`, `character_navigation`, `screen_capture`, `get_console_output`. Call `list_roblox_studios` first and pass the `studio_id` on every call.
3. Code lives in this git repo and syncs into Studio through Rojo (`default.project.json`: `src/server` -> ServerScriptService, `src/client` -> StarterPlayer.StarterPlayerScripts, `src/shared` -> ReplicatedStorage). **Write and edit all game scripts as files in `src/`. Never edit Rojo-managed scripts through the MCP script tools**, because Rojo treats the files as the source of truth and will overwrite Studio-side edits on the next sync. Use the MCP only for the world: Parts, inserted models, shared MaterialVariants, lighting, and for playtesting. Do not create Terrain.
4. If `default.project.json` does not exist, run `rojo init` in the repo root, then continue.

## 1. The game in one paragraph

Players spawn on one of 4 plots in a wide base. They walk to a shared Vehicle Bay and press START. Their vehicle spawns just past the green Safe Line, facing a long forward strip of 10 salvage stages. They drive out; items on the ground get pulled into their vehicle by a proximity collection field and go into a temporary Cargo row. Stage mobs chase and damage the vehicle. If the vehicle hits 0 HP it explodes, the player respawns at their plot, and all unbanked Cargo is lost. If they drive back across the Safe Line, the haul is banked: plain items become Cash, Mutated items become permanent Collection entries they can place on pedestals on their plot, where they earn Cash per second. Cash buys vehicle upgrades; a maxed vehicle can Trade Up to the next of 10 vehicles. Deeper stages pay far more and are far more dangerous.

## 2. Scope and key rules

- **Build everything in this prompt**: all 10 stages, all 10 vehicles, enemies, rarity, Collection, pedestals, passive income, upgrades, Trade Up and saving. Driving quality is still the top priority (Phase 2 acceptance).
- **No vehicle-gated stages.** Any vehicle may drive into any stage. Danger does the gating: a Skateboard that drives into Stage 3 should die quickly. Vehicle abilities are perks used during runs, not keys.
- **Run start is an on-screen START button**, shown only while the player stands in the Vehicle Bay and is in BASE state. It must work by mouse click and touch. If the player owns more than one vehicle, show a small vehicle picker next to START (defaults to the best owned vehicle).
- **Toolbox first.** Vehicles, mob models, props and environment pieces come from the Toolbox (Creator Store) via `search_asset` / `insert_asset`. Use Parts and the shared material roles in Visual style for all world construction. Hazards use Parts and particles; stage theme names do not authorize Terrain or alternate body materials.
- **Auto-scrap toggle** (Section 7).
- **Mobile uses Roblox default controls.** Desktop uses WASD.

## 3. Hard technical rules

- **Server authority** for run state, spawning, pickups, Cargo, HP, damage, death, banking, Cash, rarity rolls, Collection, placement and passive income. The client only animates and sends requests; validate every RemoteEvent on the server (ownership, state, distance, rate limits). Prevent double pickups, fake banking, and duplicate vehicles.
- **One config module** `src/shared/Config.luau` holding every tuning number in this prompt (vehicles, upgrades, stages, items, mutations, sizes, enemies, economy). No magic numbers elsewhere.
- **Modules, not monoliths.** Use the service split from design doc Section 20 (RunService, VehicleService, VehicleController, StageService, CollectibleService, CargoService, BankingService, EnemyService, EconomyService, CollectionService, DisplayService, RarityService, DataService, HUDController). No single giant script.
- **Toolbox safety scan.** After every `insert_asset`, search the inserted model's scripts for `require(` with a numeric asset ID, `loadstring`, `getfenv`/`setfenv`, `HttpService`, `TeleportService`, `MarketplaceService` prompts, `InsertService`, and obfuscated code. Delete any script containing those. Keep other scripts only if the asset needs them to function. Log every asset (ID, name, creator, what it is used for, scripts kept/removed) in `ASSET_MANIFEST.md`.
- **Toolbox fallbacks.** For every asset in Sections 4-6, try the listed search terms in order. If nothing usable is found, build a clean placeholder from parts with the right silhouette and colors, and record "MISSING FROM TOOLBOX: <name>" in `PROGRESS.md`. Never silently skip an asset.
- **Vehicles must use a VehicleSeat** so WASD and the mobile thumbstick work through Roblox's default controls. Many Toolbox vehicles ship with their own chassis scripts (e.g. A-Chassis). Either use the model as a visual shell on our own VehicleSeat-based controller, or keep its chassis only if our Config values (max speed, acceleration, turn rate, HP) actually drive its behavior. Upgrades MUST change how the vehicle drives. If a vehicle's own scripts ignore our Config, replace them with our controller.
- **Persistence** with DataStores and session locking (write a small session-locked wrapper or use ProfileStore). Save: Cash, owned vehicles, current vehicle, upgrade levels per vehicle, Collection (base type x mutation, best size), pedestal loadout, pedestal count, auto-scrap setting, Item Index discoveries. Version the schema.
- **StreamingEnabled** on. Keep part counts reasonable; the map must run on a phone.

## Visual style

- All ground, walls, and vehicle/prop bodies use Parts or imported MeshParts, never Terrain. **Block-only rule:** apply the Row B shared stud MaterialVariant only to block Parts (`Part` with `Shape = Block`). Use one global `StudsPerTile`, so stud size is identical on all eligible blocks, independent of object size. Use a regular repeating square-stud pattern; never adjust tiling per object. **MeshParts stay smooth with just color:** use SmoothPlastic, no MaterialVariant, no surface studs, no mesh texture or SurfaceAppearance overlay; preserve their geometry and current color. Other non-block body Parts stay smooth.
- Block Part metal trim uses a second shared diamond plate MaterialVariant. Glowing Part elements use `Enum.Material.Neon`; MeshParts retain the smooth, color-only rule.
- Define the variants, texture-map asset IDs, names, material roles, and global tiling in **one place**, `src/shared/VisualStyle.luau`. Every world builder, fallback builder, template preparation step, and runtime vehicle/prop renderer must reference this module. Install its two variants under MaterialService in Edit and include them in the saved/build artifact; runtime code references the installed variants. Do not globally override a base material.
- Never attach per-part Texture or Decal instances for these surfaces, or duplicate texture IDs/tiling elsewhere. Remove imported body texture overlays from styled clones; clear MeshPart texture IDs and SurfaceAppearance overrides so MeshParts remain color-only. Keep GUI, particle and signage assets separate from body surface styling.
- Stage names such as Grassland, Foundry and Shipping Docks describe theme, color, props and hazards, not alternative ground materials. Preserve the current map colors during the sample review. This section overrides conflicting material descriptions in the design doc and imported assets. Loot mutation effects remain separate from vehicle/prop body styling.
- Before rollout, compare the shared variant on the floor, wall and box block Parts while keeping the MeshPart smooth and color-only; show a real Studio capture and wait for the user's approval. Verify identical world-scale studs on the blocks, seamless repetition, smooth meshes, trim and Neon. Do not recolor or restyle the whole map before approval. `tools/preview-visual-style.luau` creates only the isolated approval samples; run `tools/verify-world.luau` after each world change.

- **Temporary texture approval (2026-10-02):** the user approved third-party stud image `10509831729` for now. Record the uploader, source pack and date in `docs/visual-style-preview.md`; replace it with an owned upload before release. When the user supplies their own image ID, change the central ColorMap and clear the previous NormalMap unless a matching replacement is supplied.
- **Rollout batches:** restyle block Parts only, one stage or one plot per batch. Leave MeshParts and other non-block instances untouched during these batches. Preserve colors, sizes, transforms and existing physics. Back up the full batch before mutation and roll it back if application or verification fails. Run `tools/verify-world.luau` after each batch; stop and tell the user to save/publish to Roblox, then wait for their confirmation before the next batch. If any error or usage limit occurs, stop and report. Never leave a batch half-applied.

## 4. Vehicles (Toolbox search terms in brackets)

| # | Vehicle | Toolbox search terms | Max speed (studs/s) | Base HP | Cargo slots | Boost | Perk |
|---|---|---|---|---|---|---|---|
| 1 | Skateboard | [skateboard, longboard] | 40 | 100 | 6 | 1.5x speed, 2 s, 8 s cooldown | none |
| 2 | BMX Bike | [bmx, bicycle, bike] | 48 | 160 | 7 | same | **Hop**: jump button / Space hops ~8 studs (clears hazards, small mobs) |
| 3 | Go-Kart | [go kart, kart] | 56 | 250 | 8 | hold to boost, battery refills | none extra |
| 4 | Dirt Bike | [dirt bike, motocross, motorcycle] | 64 | 400 | 9 | nitro | **Mud grip**: no slowdown on Mud/Sand hazards |
| 5 | Quad ATV | [atv, quad bike, four wheeler] | 70 | 650 | 10 | nitro | **Wide field**: +50% pickup radius |
| 6 | Jeep | [jeep, offroad, safari jeep] | 76 | 1,000 | 12 | nitro | **Armor**: -30% damage taken |
| 7 | Armored Truck | [armored truck, swat truck, military truck] | 80 | 1,600 | 14 | nitro | **Smash**: breaks loot crates and barricades on contact |
| 8 | Monster Truck | [monster truck, bigfoot truck] | 86 | 2,500 | 16 | nitro | **Crush**: instantly kills small mobs it drives over |
| 9 | Hovercraft | [hovercraft, hover car] | 94 | 4,000 | 18 | nitro | **Hover**: immune to lava/acid/mud hazard damage and slowdown |
| 10 | Hover Bike | [hover bike, sci fi bike, speeder] | 104 | 6,500 | 20 | nitro | **Phase dash**: Boost also makes the vehicle untouchable for 1 s |

Abilities stack: every vehicle keeps all perks of earlier vehicles.

**Driving requirements (Phase 2 acceptance):** W accelerates, S brakes then reverses, A/D steer directly; strong low-speed turning; not twitchy at top speed; little unwanted sliding; collisions with props/mobs do not spin or flip the vehicle; automatic flip recovery within 2 s if overturned; stable follow camera that shows what is ahead; every vehicle uses the same controller with different Config values.

## 5. Map and stages

Follow design doc Section 3 for the base: 4 plots in one row at the back, wide base compound, open walkway, centered shared Vehicle Bay strip, green Safe Line across the full entrance, tall collidable perimeter walls. Plot labels per design doc Section 4 (no "PLOT 1"/"OPEN" text; other players' plots show their avatar headshot).

The salvage strip runs forward from the Safe Line. **Each stage is ~350 studs long**, same width as the Stage 1 entrance, continuous, no vertical climbing. At each stage start build an arch with the stage number, name and a danger skull count (1-5), and show a short entry banner on the HUD. Each stage must be recognizable instantly by its floor color, fog/atmosphere tint and props. **Stage floor colors must be muted environmental tones so gold/neon rarity effects stay readable. Every floor uses the shared stud variant; the table describes color and atmosphere, not alternative materials.**

| # | Stage | Ground / atmosphere | Props (Toolbox) | Hazard | Mobs (Toolbox) | Stage value mult | Mob hit damage |
|---|---|---|---|---|---|---|---|
| 1 | Grassland | muted green stud floor, light natural fog | [grass tuft, small rock, tree stump, wildflower] | shallow Mud patches (slow) | [wild boar, boar] | 1 | 10 |
| 2 | Scrap Yard | gray stud floor, light gray fog | [junk pile, scrap pile, tire stack, chain link fence] | oil slicks (spin-out) | [rat] small, fast | 5 | 19 |
| 3 | Appliance Graveyard | tan stud floor, sandy atmosphere | [old fridge, washing machine, broken tv] stacks | Mud patches (slow) | [dog, wolf] | 25 | 36 |
| 4 | Shipping Docks | teal stud floor, diamond plate trim, sea fog, Part-based water edges | [cargo container, dock crane, anchor] | water edge (fall = damage) | [crab] | 120 | 69 |
| 5 | Foundry | rust-red stud floor | [furnace, factory machine, smokestack] | Neon lava Part pools (damage) | [lava golem, rock golem, fire monster] | 600 | 130 |
| 6 | Restricted Zone | olive stud floor, muddy atmosphere | [barbed wire, military tent, sandbags, watchtower] | Mud belts | [robot soldier, sentry turret, robot] | 3,000 | 248 |
| 7 | Research Facility | white stud floor, cool white fog | [lab equipment, server rack, computer desk] | laser gates (timed) | [lab robot, android] | 15,000 | 470 |
| 8 | Containment | toxic lime floor, green fog | [containment tank, biohazard barrel, test tube] | acid pools (damage) | [slime, mutant, zombie] | 75,000 | 894 |
| 9 | Crash Site | scorched black stud floor, purple sky | [ufo, spaceship wreck, alien crystal] | crystal shards | [alien] | 350,000 | 1,700 |
| 10 | The Anomaly | void-black stud floor with Neon grid, starfield sky | [floating rock, portal, glitch cube] | gravity rifts (pull) | [shadow monster, void creature] | 1,700,000 | 3,230 |

Place **4-6 mobs per stage**, spread out, and **loot crates** (only Smash breaks them) in stages 3-10 that hold 3 bonus items. Keep the first ~20 studs past the Safe Line calm.

## 6. Items

**6 item types per stage (60 total)**, each with a Toolbox model and a 2D icon (render icons from the model with a ViewportFrame or a saved image). Data per item in Config: Id, DisplayName, Stage, WeightClass (Light/Medium/Heavy), BaseValue, SpawnWeight.

| Stage | Items |
|---|---|
| 1 | Tire, Television, Microwave, Toaster, Traffic Cone, Car Battery |
| 2 | Washing Machine, Fridge, Arcade Cabinet, Old Computer, Oven, Vending Machine |
| 3 | Generator, Engine Block, Oil Barrel, Industrial Fan, Toolbox, Forklift Part |
| 4 | Anchor, Ship Wheel, Cargo Crate, Buoy, Outboard Motor, Dock Lamp |
| 5 | Robot Arm, Furnace Core, Gear Assembly, Crucible, Steel Beam, Anvil |
| 6 | Radar Dish, Field Radio, Satellite Dish, Ammo Crate, Night Vision Goggles, Mech Leg |
| 7 | Server Rack, Microscope, Lab Centrifuge, Robot Head, Holo Projector, Quantum Drive |
| 8 | Cryo Pod, Plasma Core, Containment Jar, Mutagen Canister, Biohazard Drum, Reactor Rod |
| 9 | Alien Power Cell, Saucer Fragment, Alien Skull, Energy Crystal, Ray Gun, Alien Egg |
| 10 | Glitch Cube, Floating Orb, Void Shard, Clock Fragment, Mirror Shard, Impossible Ring |

**Values:** Light items BaseValue 20, Medium 50, Heavy 120, all multiplied by the stage value multiplier. **Pickup time:** Light instant, Medium 0.5 s, Heavy 1.0 s, any Mutated item +0.75 s. Keep **10-14 items** spawned per stage at any time (target-density respawn).

**Pickup feel (design doc Section 8):** visible soft ring under the vehicle shows the collection radius (base 12 studs); progress ring fills over the item while it is inside the field and drains over ~1 s if the field leaves it; on completion the 3D item lifts, spins, arcs into the vehicle while shrinking, pops with a small flash and sound; a 2D icon then flies from the vehicle's screen position into its Cargo slot, which bounces. Never weld items onto vehicles.

## 7. Cargo, auto-scrap, banking, death

- **Cargo**: bottom-center slot row, server-owned. When full, show FULL and an arrow home; block further pickups (no auto-swap).
- **Auto-scrap toggle** (Settings, default OFF, saved). When ON: picking up a plain (non-Mutated) item whose type is already in the player's Item Index converts it immediately into **unbanked Cash** shown as a "+$X" counter beside Cargo, and it takes no slot. **Unbanked Cash is lost on death like Cargo.** Mutated items and never-seen item types always go into Cargo.
- **Banking**: crossing the Safe Line inward while RUNNING ends the run: show HAUL SECURED, despawn vehicle, return player to the base, then resolve the haul: plain items -> Cash (counted up), unbanked Cash -> Cash, first-ever item types -> stamp NEW in the Item Index, Mutated items -> reveal card (model turning, name, mutation, size, exact "1 in X", NEW or duplicate result) and into the player's inventory with a PLACE IT prompt. Cards are skippable by tap/click.
- **Death**: at 0 HP the vehicle explodes (short slow-motion burst), camera holds ~2 s, player respawns at their plot, RunState -> BASE, all Cargo and unbanked Cash lost. Warnings: smoke at 30% HP, siren + red screen-edge pulse at 15%.
- **Run states** exactly as design doc Section 6: BASE -> SPAWNING -> RUNNING -> BANKING -> BASE, and RUNNING -> FAILED -> BASE.

## 8. Enemies

One shared EnemyService drives every mob (Toolbox models provide visuals and animations only; remove or override any built-in AI so our rules hold). Five behaviors reused across stages: **Chaser** (runs at you), **Diver** (hovers, telegraphs with a red light, dives), **Sentry** (stationary, shoots slow visible projectiles), **Swarm** (several small fast ones), **Hazard-maker** (leaves damaging puddles). Assign one or two behaviors per stage to fit the mob. State machine PATROL -> CHASE -> ATTACK -> RETURN (design doc Section 11): proximity aggro ~30 studs, pickup-noise aggro ~45 studs when the player completes a pickup nearby, leash to their own stage, never cross the Safe Line or into another stage, only target RUNNING vehicles. Every attack must be telegraphed (wind-up or red flash) so mobile players can dodge. Damage per hit from the stage table.

## 9. Rarity, mutations, size, Item Index

**Mutation** is rolled when an item spawns and is **visible in the world** (material/effect). The exact odds are NOT shown in the world, only at banking.

| Mutation | Odds per spawn | Value mult | Look |
|---|---|---|---|
| Normal | rest | x1 | default |
| Chrome | 1 in 25 | x2 | reflective metal material |
| Golden | 1 in 150 | x5 | gold + soft glow |
| Electrified | 1 in 1,000 | x15 | blue sparks particles |
| Crystal | 1 in 7,500 | x50 | glass/ice material + shard particles |
| Blue Flame | 1 in 60,000 | x200 | blue fire particles, slow spin |
| Glitched | 1 in 500,000 | x1,000 | flickering colors, jittering position |
| Void | 1 in 5,000,000 | x5,000 | black material, purple light, dark particle pull |

**Size** is rolled at banking and revealed on the card: Normal 85% (x1), Big 12% (x1.5, scale 1.25), Huge 2.7% (x3, scale 1.6), Colossal 0.3% (x10, scale 2.5). **Displayed odds** = mutation odds x size odds (e.g. Golden + Colossal = 1 in 50,000). Item value = BaseValue x stage mult x mutation mult x size mult.

**Item Index**: a menu with every item in the game, grouped by stage. Undiscovered entries show a dark silhouette and "???". Discovered entries show the icon, name, and which mutations the player has found (owned mutations lit, unowned dim). Show completion % per stage and overall.

**Announcements**: Blue Flame and rarer -> server-wide banner with player name, item and odds.

## 10. Collection, pedestals, passive income

- Collection key = item type x mutation, keeping the best size. Plain items also count (any discovered item can be placed).
- Duplicates on banking: same key with same or smaller size -> sells for its value as Cash; bigger size -> upgrades the owned entry to the new size and pays the value difference.
- **Pedestals**: each plot has **4 pedestals** at start, buyable up to **12** (prices: 5th $2,000, then each next pedestal costs 4x the previous). Empty pedestals are subtle (no permanent + signs). Placement: press PLACE IT or choose from the inventory; the player's own valid pedestals glow locally; tap/click a pedestal; the item drops onto it with a thump. Clicking a filled pedestal offers Swap / Remove. Other players never see your placement highlights.
- Placed items rotate slowly and keep their mutation effects; a small billboard on approach (within 12 studs) shows name, mutation, size, "1 in X" and $/sec.
- **Passive income**: each placed item earns **Cash/sec = item value x 0.01**. Show a plot income sign ("$X/sec"). Offline income at 50% rate, capped at 8 hours, granted on join with a WHILE YOU WERE GONE popup.

## 11. Upgrades and Trade Up

- **Garage button** on the HUD (only usable in BASE state) opens upgrades for the current vehicle: **Speed** (+6% max speed per level), **HP** (+15% per level), **Cargo** (+1 slot per level), **Boost** (+10% duration and -10% cooldown per level). 5 levels each.
- Upgrade cost for level L of vehicle V = B[V] x 1.6^(L-1), with B = [25, 160, 1,000, 6,000, 36,000, 220,000, 1,300,000, 8,000,000, 48,000,000, 280,000,000]. These are starting values; Phase 9 tunes them.
- **Trade Up** (this is the game's prestige): available when all 4 tracks of the current vehicle are maxed AND the player has banked a run that reached at least stage V. Price = [-, 1,000, 6,500, 40,000, 250,000, 1,500,000, 9,000,000, 55,000,000, 330,000,000, 2,000,000,000] for vehicles 2-10. On Trade Up: unlock and equip the next vehicle with fresh upgrade levels. Cash left over, Collection, pedestals, Item Index and older vehicles are kept. Show a short celebration.
- Number formatting: 1.2K, 3.4M, 5.6B.

## 12. HUD

Cash (top left), Cargo row + unbanked Cash counter (bottom center, during runs), vehicle HP bar (during runs), Boost button (mobile, during runs) and ability button where relevant, START button (in Vehicle Bay only), Garage, Item Index, Inventory, Settings (auto-scrap, music/sfx). A one-time tip "Drive out, collect, come back" that disappears after the first bank. Nothing else permanently on screen. Must be readable on a phone.

## 12b. UI style: match top Roblox simulators

The UI must look and feel like the UI in Steal An Egg and Kick a Lucky Block: chunky, bright, cartoony, bouncy, readable on a phone. **Before building any UI, open every image in `docs/ui-reference/`** (screenshots of those games' menus, HUD and popups) and write a short list in `PROGRESS.md` of the patterns you see. Match their layout density, proportions, colors, motion and feel. **Do not copy their artwork, logos, icons or text**; build our own in the same style.

**UI kit selection**: `assets/ui-kits/` may contain one or more downloaded UI kits, each in its own subfolder as downloaded. If it has any contents: open every subfolder, compare each kit's buttons/panels/icons against `docs/ui-reference/` and the style rules below, pick the single best match, and write one line in `PROGRESS.md` naming the chosen kit and why. Use only that kit everywhere in the game; do not mix pieces from different kits. If a Toolbox search for "simulator UI kit" or "game UI pack" turns up a Roblox-native kit that fits better, that counts as a candidate too. If `assets/ui-kits/` is empty or nothing fits, build UI from scratch per the rules below.

**Roblox-native kits:** The user places these in `ServerStorage.UIKits`. When a phase needs UI-kit work, check that this folder exists and inspect its contents. If missing, stop UI-kit work and ask the user to place the kit(s) there; do not silently create an empty folder or treat it as provided. Missing UIKits does not block unrelated world recovery. Treat native kits as editor-time references only: the shipped game must never read or require `ServerStorage.UIKits` at runtime. Keep runtime UI implementation in repo-managed `src/client/UIKit.luau` and other source files.

**PNG kits:** These live in `assets/ui-kits/`, with each kit in its own subfolder. Select only icons actually used by the game. List their exact original filenames, kit-relative paths, intended uses and any selected copies in `docs/ui-assets.md`. The user uploads the selected PNGs and supplies the resulting Roblox asset IDs. Store only IDs supplied/confirmed by the user for new uploads in the repo's Luau icon module (`src/client/Icons.luau`); do not upload on the user's behalf. Existing prototype IDs must be identified separately until the user confirms or replaces them. Do not begin selection or other UI-kit work during a world-recovery checkpoint.

Build all UI from one shared `UIKit` module (`src/client/UIKit.luau`) so every button and panel looks consistent:

- **Fonts**: `Enum.Font.FredokaOne` for buttons and body text; `Enum.Font.LuckiestGuy` for titles, big numbers and reveal cards. Button labels in ALL CAPS.
- **Text**: white with a black `UIStroke` (thickness ~2-3, scaled for screen size). Numbers formatted 1.2K / 3.4M / 5.6B.
- **Buttons**: `UICorner` (heavily rounded), a vertical `UIGradient` (lighter at the top), a thick dark `UIStroke` outline, and a darker copy of the button offset ~4 px underneath for a 3D "pressable" look. Hover: scale to 1.05. Press: scale to 0.92 and back with a Back easing over ~0.12 s, plus a click sound.
- **Color meaning, used consistently**: green = buy/confirm/START, yellow-gold = Cash, blue = info/menus, red = close/danger, purple = rare/special. Rarity colors: Normal gray, Chrome silver, Golden gold, Electrified cyan, Crystal ice blue, Blue Flame deep blue, Glitched magenta, Void dark purple.
- **Panels**: rounded, thick outline, a colored header bar with the title, a round red X close button at the top right. Open with a scale pop (0.8 to 1.0, Back.Out, ~0.25 s) over a dim translucent backdrop; close with a quick shrink.
- **Layout**: Cash display top-left, large, with a coin icon; "+$X" text that floats up and fades whenever Cash is gained. Menu buttons (Garage, Item Index, Inventory, Settings) as big square icon buttons stacked vertically on the left edge. Toast notifications slide in at top-center. Run HUD (Cargo row, HP bar) bottom-center.
- **Icons**: use image icons, not plain text. Use the chosen UI kit's icons first if it has one that fits; otherwise find icon decals in the Toolbox, or select PNGs and record their filenames in `docs/ui-assets.md`. The user uploads PNGs and provides asset IDs for `src/client/Icons.luau`. If none of those exist for something, draw a simple icon from frames/shapes rather than leaving text.
- **Juice**: every reward gets motion and sound. Number count-ups, card flips on reveal cards, small particle bursts on rare finds, screen-edge flash for big moments.
- **Mobile**: use Scale sizing plus `UIAspectRatioConstraint`, a `UIScale` driven by viewport size, and minimum tap targets of roughly 44 px on a phone. Nothing may overlap Roblox's default thumbstick or jump button.

**UI verification loop**: after building each screen (HUD, Garage, Item Index, Inventory, reveal card, Trade Up, Settings), `screen_capture` it at desktop size and phone size, compare it side by side with the most similar image in `docs/ui-reference/`, write down the three biggest differences, fix them, and capture again. Repeat up to 3 times per screen. Log the result in `PROGRESS.md`.

## 13. Phases (do them in order)

For **every** phase: build it, coordinate an explicit Play handoff with the user, then run a playtest (`start_stop_play`), drive/walk with `user_keyboard_input` / `character_navigation`, take `screen_capture`s, read `get_console_output`, fix errors and failed checks, then `git commit` with a clear message and append to `PROGRESS.md`: what was built, acceptance results (pass/fail per check), screenshots described, known issues, decisions made. Do not mark unverified work done. Write `SAVE POINT <phase>`, stop and tell the user to save/publish the place to Roblox. Wait for confirmation before starting the next phase.

1. **Phase 1, map**: base, plots, Vehicle Bay, Safe Line, walls, all 10 stage bands with ground, atmosphere, arches and props. Check: every stage is visually distinct in a screenshot; nothing floats or clips; walls block leaving.
2. **Phase 2, vehicles**: all 10 vehicles inserted, safety-scanned, set up on the shared controller with Config stats; START button; spawn aligned with the player's position in the bay; camera; flip recovery. Check: all driving requirements in Section 4 for vehicles 1, 5 and 10; no console errors.
3. **Phase 3, runs**: items, pickup field and animation, Cargo, auto-scrap, banking, run states. Check: collect 6 items in Stage 1, bank them, Cash increases by the right amount; full Cargo blocks pickups.
4. **Phase 4, danger**: enemies, hazards, HP, warnings, death. Check: a Skateboard dies within ~20 s in Stage 3; mobs never cross the Safe Line; death loses Cargo and unbanked Cash.
5. **Phase 5, rarity**: mutations, size, reveal cards, Item Index, announcements. Check: force-spawn one of each mutation (debug command) and confirm look, value and odds math.
6. **Phase 6, ownership**: Collection, duplicates, pedestals, placement, passive and offline income. Check: place 4 items, income sign matches the sum.
7. **Phase 7, progression**: Garage upgrades, Trade Up, persistence. Check: upgrades change measured top speed/HP/slots; data survives leaving and rejoining.
8. **Phase 8, polish and mobile**: full UI pass against Section 12b and the reference screenshots (run the UI verification loop on every screen), sounds, particles, mobile layout check at phone resolution, performance pass.
9. **Phase 9, critique**: if you can run sub-agents, fan out reviewers in parallel; otherwise do these passes yourself one at a time. Each reviewer plays the game and critiques one area against the quality bar of top Roblox simulators such as Steal An Egg and Escape Tsunami for Brainrots: (a) first 60 seconds for a new player on a phone, (b) driving feel, (c) visual clarity of stages and rarity, (d) economy pacing (time to first Trade Up should be ~8-12 min), (e) bugs/exploits in remotes. Fix the top issues from every review, re-test, commit.

Add a debug-only admin panel (only for the place owner) with: give Cash, set vehicle, teleport to stage N, force-spawn mutation, reset data. You need it for testing.

## 14. Definition of done

A new player can join, walk to the Vehicle Bay, press START, drive a Skateboard into Stage 1, collect items while dodging rats, bank them, see Cash rise, place a found Chrome or Golden item on a pedestal, buy upgrades, Trade Up to a BMX, and push deeper; deeper stages are visibly different and much more dangerous; everything saves. `PROGRESS.md` honestly lists every check that failed and every placeholder used. Do not claim something works unless you verified it in a playtest.
