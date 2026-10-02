# SALVAGE RUN: Game Design Spec

Version for a from-scratch build, October 2026. Nothing from any earlier version of this game exists in the project. This document describes what to build. `CODEX_PROMPT.md` adds the exact numbers, asset lists and build order; where the two differ, `CODEX_PROMPT.md` wins.

## 1. The game

**Pitch:** Drive a vehicle into increasingly dangerous salvage regions, collect temporary cargo, survive the trip home, bank the haul, display your best finds, upgrade your vehicle, and push farther for stranger and rarer discoveries.

**Core loop:** press START at the Vehicle Bay -> vehicle spawns past the Safe Line -> drive deeper -> the vehicle's collection field pulls items into temporary Cargo -> stage mobs and hazards damage the vehicle -> decide when to turn back -> cross the Safe Line to bank -> place finds and buy upgrades -> go again, farther.

The return trip is part of the risk, which is what makes travel meaningful instead of dead time.

## 2. Design principles

- **Clarity first.** A child on a phone should understand what to do within seconds, without reading.
- **One obvious core action.** Drive, and the vehicle collects. No interact key per item, no minigames.
- **The vehicle is the collector.** There is no handheld tool.
- **The plot is simple.** It is for displaying finds, not a factory.
- **Temporary cargo creates risk.** Nothing is owned until it crosses the Safe Line.
- **One permanent currency: Cash.**
- **Rare finds become visible possessions** that sit on the player's plot, not anonymous resources.
- **No permanent UI clutter.** Show information only when it is useful.
- **Progression is visually obvious:** better vehicles, stranger regions, bigger and flashier finds.
- **Active play stays necessary.** Passive income exists, but only runs can find new items.
- **Server authority for anything of value** (Section 19).

## 3. Map layout

A wide base compound with one forward salvage strip. Not a circle, plaza, quarry or hub.

```
            STAGE 10  (farthest from home)
               ...
            STAGE 2
            STAGE 1
          |         |
          +=========+
           SAFE LINE  (green, full width of the entrance)

         [ VEHICLE BAY ]   shared, centered

        open walkway / gap

 [ PLOT 1 ][ PLOT 2 ][ PLOT 3 ][ PLOT 4 ]
 +-----------------------------------------+
   wide base compound
```

- Exactly 4 plots, in one row across the back of the base.
- The base is clearly wider than the salvage strip; the strip is centered on it.
- One shared Vehicle Bay strip, centered, about 85% of the strip's width.
- A real empty walkway between the Vehicle Bay and the plots. Do not fill it.
- The salvage strip runs straight forward through all 10 stages at the same width. No climbing, no narrowing.
- Tall, simple, collidable walls around the outside of the base and the strip. Invisible barriers only as backup. The far end of Stage 10 gets an end wall.
- Orientation: read lateral/forward directions from config, never hard-code them.

## 4. Plots

- **Your own plot:** no label above it.
- **Another player's plot:** only their Roblox avatar headshot above it.
- **Empty plot:** nothing.
- Never show text like PLOT 1, OPEN, CLAIMED or AVAILABLE.
- A plot holds only **display pedestals** and a small **income sign**. No machines or buildings.
- Pedestals are subtle when empty. A + or glow appears only in the owner's placement mode, only on their own valid pedestals, and only on their screen.
- Once an item is placed, the item is what draws attention.

## 5. Vehicle Bay and run start

- When a player stands in the Vehicle Bay in BASE state, an on-screen **START** button appears (works by click and touch). If they own several vehicles, a small picker sits next to it, defaulting to the best one.
- No giant permanent Vehicle Bay text.
- **Spawn alignment:** the vehicle spawns just past the Safe Line, inside Stage 1, at the same lateral position where the player stood in the bay, facing forward. If another vehicle blocks that spot, use the nearest free spot beside it.
- On START: validate, spawn, place, face forward, seat the player instantly, switch to vehicle camera, set RUNNING, enable Cargo/pickups/enemy targeting. The player never walks to a parked vehicle or drives out of the base.

## 6. Run state machine

Server-authoritative and explicit; never inferred only from trigger zones.

```
BASE -> (START) -> SPAWNING -> (spawned + seated) -> RUNNING
RUNNING -> (crosses Safe Line inward) -> BANKING -> (rewards resolved) -> BASE
RUNNING -> (vehicle HP reaches 0) -> FAILED -> (respawn at plot) -> BASE
```

Only a RUNNING player collects items, has Cargo, can be targeted by mobs, can fail, and can bank. The run starts when the vehicle spawns.

## 7. Vehicles and driving

**Controls:** desktop W accelerate, S brake/reverse, A/D steer. Mobile uses Roblox's default touch controls. No mouse steering, no on-screen GO/BACK/arrow buttons. Vehicles drive through a **VehicleSeat**, which gives WASD, thumbstick and gamepad input through one code path.

**Feel (arcade, not simulator):** immediate predictable steering, strong low-speed turning, easy reversing, not twitchy at top speed, little unwanted sliding, collisions do not spin or flip the vehicle, automatic flip recovery, stable camera that shows what is ahead. Think of Roblox's walking controls, applied to a vehicle.

**Architecture:** one shared controller plus per-vehicle config (max speed, acceleration, reverse speed, turn rate, braking, grip, stability, HP, cargo slots, boost, perk). Toolbox vehicle models may be used as visual shells; their own chassis scripts are kept only if the config values truly control how they drive, because upgrades must change the vehicle's behavior. The driver gets network ownership for responsiveness; the server still owns run state, Cargo, HP and rewards.

**10 vehicles:** Skateboard (starter), BMX Bike, Go-Kart, Dirt Bike, Quad ATV, Jeep, Armored Truck, Monster Truck, Hovercraft, Hover Bike. Each later vehicle is clearly faster, tougher and carries more, and most add one perk (Hop, sustained boost, mud grip, wider pickup field, armor, smash crates, crush small mobs, hover over hazards, phase dash). Perks stack: every vehicle keeps all earlier perks.

**No vehicle-gated stages.** Any vehicle can drive into any stage. Danger is the gate: weak vehicles die fast in deep stages. (Hard checkpoints at Stages 5 and 10 may be considered later; not in this build.)

**Trade Up** is the game's only prestige. When all four upgrade tracks (Speed, HP, Cargo, Boost) of the current vehicle are maxed and the player has banked a run from deep enough, they pay to Trade Up to the next vehicle. Its upgrade tracks start fresh; everything else is kept. The next vehicle's base stats must already beat the previous vehicle fully upgraded.

## 8. Item pickup

- A visible soft ring under the vehicle shows its collection radius.
- Collection starts automatically while an item is inside the ring. No button press, no exact collision.
- The player should be able to keep moving or circle an item instead of stopping.
- **Pickup time, not item health:** light items instant, medium ~0.5 s, heavy ~1 s, mutated items longer. A progress ring fills over the item; if the ring leaves the item, progress drains over about a second instead of resetting.
- **Animation:** the item lifts, spins and arcs toward the vehicle while shrinking, then pops with a small flash and sound. A 2D icon then flies from the vehicle's position on screen into its Cargo slot, which bounces.
- Never stack items on the vehicle, never weld them on, never morph the 3D object into a flat image mid-air.

## 9. Cargo and auto-scrap

- Cargo is a temporary run inventory shown as a slot row at the bottom center. Server owns its contents.
- One item per slot. When full: show FULL, point toward home, block further pickups. No inventory management screen.
- **Auto-scrap** (setting, off by default): plain items whose type the player has already discovered turn into **unbanked Cash** on pickup instead of taking a slot. Unbanked Cash is lost on death exactly like Cargo. Mutated and never-seen items always go into Cargo.

## 10. Items

Each stage has its own set of item types, from familiar junk (tires, TVs, microwaves) in Stage 1 to impossible objects in Stage 10. Items are data-driven: Id, DisplayName, Stage, WeightClass, BaseValue, SpawnWeight, model reference, icon reference. Each stage keeps a steady number of items spawned (refilled as they are collected), enough for real route choices but with clear driving lanes.

## 11. Enemies, hazards, HP and death

- Mobs damage the **vehicle**, not the player's character. No player weapons. The skill is dodging and routing.
- Each stage has its own mobs and one hazard type, spread out, never clustered at the entrance. The first ~20 studs past the Safe Line stay calm.
- **Behavior:** one shared enemy system, state machine PATROL -> CHASE -> ATTACK -> RETURN. Aggro by proximity (~30 studs) and by pickup noise (~45 studs when a nearby pickup completes). Mobs only target RUNNING vehicles.
- **Leash:** each mob belongs to one stage, never crosses the Safe Line or into another stage, and returns home when its target leaves. It may switch to another valid vehicle nearby.
- Every attack is telegraphed (wind-up or red flash) so mobile players can react.
- **HP warnings:** smoke at ~30%, siren and pulsing red screen edges at ~15%.
- **Death at 0 HP:** the vehicle explodes, the player respawns at their plot, all Cargo and unbanked Cash from that run are lost. Cash, Collection and placed items are always safe. Never let a death keep or bank anything, because that can be exploited by dying on purpose.

## 12. Safe Line and banking

Crossing the Safe Line inward while RUNNING:

1. leave RUNNING immediately (mobs can no longer target);
2. show HAUL SECURED;
3. resolve Cargo on the server and clear it;
4. despawn the vehicle, put the player back at the base with normal controls; state becomes BASE.

Resolution: plain items become Cash; unbanked Cash becomes Cash; first-ever item types are stamped NEW in the Item Index; Mutated items show a reveal card (model, name, mutation, size, exact "1 in X") and go to the player's inventory with a PLACE IT prompt. Cards are skippable and never freeze control for long. The whole entrance is the bank line; there is no small pad to hit.

## 13. Rarity, mutations and size

- **Mutation** is rolled when an item spawns and is **visible in the world** through its material and effects, so players can choose to risk a detour for it. The exact odds are never shown over world items.
- **Size** (Normal, Big, Huge, Colossal) is rolled at banking and revealed on the card. Colossal items display at about 2.5x scale.
- **Displayed odds** combine mutation and size odds, and appear only on the reveal card, the Item Index, a placed item's nameplate, and announcements.
- **Visual ladder:** each rarer mutation adds a new layer of spectacle: material, then glow, then particles, then animation, then world/light effects. Rarer within a stage should always look cooler.
- Stage colors use muted environmental tones; rarity uses bright metallic and glowing effects, so rare items always stand out.
- Very rare finds trigger a server-wide announcement.

## 14. Collection, placement and passive income

- **Collection key:** item type x mutation, keeping the best size found (e.g. Microwave, Golden Microwave, Blue Flame Microwave).
- **Duplicates resolve themselves:** same entry with same or smaller size sells for Cash; a bigger size upgrades the owned entry and pays the difference; a new mutation of a known type is a new entry. No manual selling or cleanup.
- **Any owned entry can be placed,** including plain items. Players naturally replace them with better finds.
- **Item Index:** every item in the game grouped by stage; undiscovered entries are silhouettes with ???; discovered ones show which mutations have been found; completion % per stage.
- **Placement is manual and fast (two taps):** choose PLACE IT or pick from inventory, the owner's valid pedestals glow, tap one, the item drops on with a satisfying thump. Tapping a filled pedestal offers Swap or Remove.
- Plots start with 4 pedestals and can buy up to 12.
- **Passive income:** placed items earn Cash per second based on their value. A sign on the plot shows the total. Offline income runs at half rate, capped at 8 hours, shown on join.
- Passive income must never replace runs: better items only come from runs, Trade Up needs a deep enough banked run, and pedestals are limited.

## 15. Stages and theme

The theme is a **salvage expedition**: it starts with familiar junk so the first minute is instantly readable, then gets stranger the farther you go.

1. Scrap Lot
2. Appliance Graveyard
3. Industrial Yard
4. Shipping Docks
5. Foundry
6. Restricted Zone
7. Research Facility
8. Containment
9. Crash Site
10. The Anomaly

Each stage must be recognizable at a glance through its floor color, fog/sky tint, props, an entry arch with its number, name and danger level, a short entry banner, and music. Deeper stages pay much more and are much more dangerous.

## 16. UI and UX

- **Always:** Cash (top left).
- **In the Vehicle Bay:** START (and vehicle picker).
- **During a run:** Cargo row and unbanked Cash, vehicle HP bar, Boost button on mobile, ability button where relevant.
- **Buttons:** Garage (upgrades, base only), Item Index, Inventory, Settings (auto-scrap, sound).
- One short first-time hint ("Drive out, collect, come back") that disappears after the first bank.
- Nothing else permanently on screen. Readable on a phone.

## 17. Economy

- **Sources:** banked items, auto-scrap Cash, duplicate sales, passive and offline income.
- **Sinks:** vehicle upgrades, Trade Ups, extra pedestals.
- Active runs at the player's frontier should always earn faster than idling.
- All numbers live in one config file so the game can be rebalanced in one place.

## 18. Save data

Versioned schema with session locking. Save: Cash, owned vehicles, current vehicle, upgrade levels per vehicle, deepest stage banked, Collection entries with best size, pedestal loadout and count, Item Index discoveries, settings, last-online timestamp for offline income.

## 19. Server authority and anti-exploit

The server validates run start and state changes, vehicle spawning, pickup eligibility and completion, Cargo contents and capacity, banking, Cash awards, HP, damage and death, stage bounds, all rarity rolls, Collection ownership, placement and passive income. The client only animates and asks.

Prevent: double pickups, fake pickup or banking remotes, banking someone else's Cargo, duplicate vehicles or runs, client-chosen rarity or value, Cargo surviving a bank or death.

## 20. Code structure

Separate services, for example: RunService, VehicleService, VehicleController (client), VehicleConfig, StageService, CollectibleService, CargoService, BankingService, EnemyService, EconomyService, CollectionService, DisplayService, RarityService, DataService, HUDController. Never one giant script.

## 21. Assets

- Toolbox (Creator Store) first for vehicles, mobs, props and environment pieces. Built-in Terrain materials, parts, materials, particles and lights are always fine.
- Scan every inserted model for malicious script patterns and remove them; log every asset used.
- Pick one visual palette so assets from different creators look like one game.
- Mutations are built from Roblox materials, particles, Highlights, lights, scale and animation, not separate models per variant.

## 22. Not in this build

Parties, rescue and player collisions (all players are ghosted to each other), trading, weather and live-ops events, serial numbers and global feeds, monetization, extra currencies or crafting, weapons, guilds, season pass, vehicle-gated stages.

## 23. First-session target

1. Spawn on your plot. Walk to the Vehicle Bay. START appears; press it.
2. The Skateboard appears just past the Safe Line where you stood; you are already riding it.
3. WASD drives. Nearby items visibly pull into your Cargo.
4. A rat chases you; your HP drops; you turn back.
5. Cross the line: HAUL SECURED, Cash goes up.
6. Within the first few minutes, a visibly special item sits somewhere risky. You grab it and make it home. The card shows its odds and size. You place it on a pedestal and the income sign ticks up.

That sequence is the emotional core of the game.

## 24. Playtest questions

- Can a new player drive immediately, and do they keep driving for 5+ minutes?
- Do players turn back earlier as danger rises?
- Does dying feel tense or rage-inducing?
- Does pickup feel forgiving without forcing players to park?
- Does a visible mutation deep in danger tempt a risky detour?
- Do players ignore all plain items? If so, rebalance values.
- Do players understand why to place a find, and do rarer items look cooler without reading a label?
- Does passive income motivate collecting without letting players idle through progression?
- Can someone explain the game after 20 seconds?

Log simple events to support these: run started/ended (reason, duration, deepest stage, items, damage, Cash banked), Cargo full, placements, Trade Ups.
