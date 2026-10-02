# OVERNIGHT_BACKLOG.md

Salvage Run overnight work order. Written Oct 2, 2026. Read this whole file before doing anything.

The owner is asleep. Nobody will answer questions, press Save in Studio, or press Play. Work through the queue in order, keep every batch small and verified, and write down what you did.

CODEX_PROMPT.md and its exact numbers still win, except for the items in section 2 (Overrides), which are newer owner decisions. Your first action after reading is to copy section 2 into CODEX_PROMPT.md so the decisions survive context compaction.

---

## 1. Operating rules for an unattended run

1. **Do not stop for confirmation.** Earlier you stopped at each SAVE POINT and waited for the owner to save. Tonight, do not wait. Add a line to `docs/overnight-report.md` and keep going. The owner will save in the morning.
2. **Studio health gate before every world batch.** Call `list_roblox_studios`. The PlaceId must be `120476079479285`. Then run `tools/verify-world.luau`. If either fails, or the MCP is unreachable, switch to script-only mode: edit files, docs and mocked tests only, log it, and retry the gate at the start of the next task. If the place looks reverted or the PlaceId changed, do NOT rebuild the world from memory. Stop world edits and write `docs/recovery-needed.md`. (Last time, Reconnect reopened an older cloud version and the damage came from building on top of an unchecked base.)
3. **Everything replayable.** Every world change must be done by a script committed under `tools/` or `src/`, so it can be re-run on a fresh copy of the place. No live-only edits except trivial ones.
4. **Small atomic batches.** One batch means: change, `verify-world.luau` passes, commit. Never leave a batch half-applied. If verification fails, revert that batch before moving on. Usage can run out or the PC can crash at any moment, so every commit must leave the project in a good state.
5. **Git.** Commit after each batch with a clear message. Run `git push origin main` after each commit group. If the push fails (auth, non-fast-forward), do not force-push, do not retry in a loop, log it and continue. Never rewrite history. Update `PROGRESS.md` only after verifying in Studio.
6. **Scripts are files.** Edit scripts only as files under `src/` (Rojo syncs them). Never use the Studio MCP script editing tools. Use the MCP only for the world (parts, models, lighting objects) and for playtests.
7. **Playtests.** Allowed since nobody is playing. Run exactly one at a time and always stop it. **The run must END with no playtest running and Studio in Edit mode**, because an open playtest holds the owner's save lock and will kick them in the morning. Studio uses `SalvageRun_v1_Studio`. Do not change production behavior of `SalvageRun_v1` except by adding fields with safe defaults.
8. **Creator Store / Toolbox safety.** For any inserted asset: put it in `ServerStorage.AssetQuarantine` first, delete every Script, LocalScript and ModuleScript inside it, never `require()` an asset, and record owner, asset ID and pack link in `docs/third-party-assets.md`.
9. **No irreversible deletes.** Before changing a template, copy the original to `ServerStorage.ArtBackups` (not referenced by code, not synced by Rojo). Do not touch `ServerStorage.UIKits`; the owner places it by hand.
10. **No false visual claims.** If screenshot captures are black or unavailable, do not claim visual acceptance. Frame the camera first, using the method that worked for the VisualStylePreview comparison. If it still fails, write "unverified visually" in the report.
11. **Things you cannot do:** upload images or audio, click Save/Publish in Studio, place the UIKits. List what you need in `docs/owner-todo.md` and move on without waiting.
12. **Ask nothing.** Pick the most reasonable reading, and record the assumption in the report.
13. **Do not:** add monetization, change DataStore names, use Terrain, change core economy numbers except as stated here, delete large groups of files, or force-push.
14. **Budget.** The owner can reset usage, so do not rush or skip verification to save it. Still keep batches atomic and every finished task useful on its own, in case the run is cut off.

---

## 2. Overrides (newer owner decisions, these beat CODEX_PROMPT.md)

- **O1 Art direction is cartoony.** Bright, colorful, chunky, toy-like. Mobs, vehicles, collectible items, props and UI currently look too realistic. Nothing may look realistic or gritty. No gore.
- **O2 No stage name flag and no stage start arch.** The flag/banner above the start of every stage that shows the stage name must be removed, and so must the whole arch (structure, skulls, lights, labels) at each stage start.
- **O3 Perimeter walls are taller and slightly thicker** (numbers in task T3).
- **O4 Stud style stays.** Block Parts use the shared stud MaterialVariant; MeshParts stay smooth, color only. All new world pieces use the VisualStyle helper from the start.
- **O5 Under-tier vehicles collect slower.** A vehicle below a stage's recommended tier takes noticeably longer to collect there, so the stage feels like a death trap until the player upgrades (task T6).
- **O6 An AFK progression system is in scope** (task T10). Trade Up remains the only prestige. AFK progress persists across Trade Up and must never become a second prestige.

---

## 3. Work queue (in this order)

### T0. Build the master backlog (no world edits yet)
Read `PROGRESS.md`, `CODEX_PROMPT.md`, `docs/SALVAGE_RUN_DESIGN.md`, `docs/world-recovery.md`, `docs/world-overlaps.md`, `docs/visual-style-preview.md`, and `git log`. Write `docs/backlog.md`: every spec item that is not implemented or not verified, marked Done / Partial / Not started with evidence (a file path or a verified world fact). Phases 8 and 9 are known unfinished. Include everything in this file. Then copy section 2 into `CODEX_PROMPT.md`. Also check whether the spec defines audio/music, a tutorial or first-time-player flow, performance targets (instance counts, streaming), or mobile specifics, and add anything it defines to the backlog. Do not invent features it does not define. Do not spend long on this.

### T1. Remove the stage name flags and the stage start arches
The owner wants the flag above the start of each stage (the one that shows the stage name) AND the whole arch gone: arch structure, skulls, lights, name signs, BillboardGui/SurfaceGui text, all of it, at all 10 stage starts.
- Before deleting, search `src/` and the world for anything that depends on the arch parts (stage-enter detection, trigger zones, lighting, effects). If gameplay code needs an entrance trigger, keep or recreate it as an invisible, non-colliding Part with the same position and size, and note it in the report. Removing the arch must not open gaps in the perimeter or change collision.
- Keep stage names in code and config. Other systems use them.
- Do it in the build routine (not just the live world), update the inventory expectations in `verify-world.luau` (arch count becomes 0), and list exactly what was removed in the report.
- Done when: the 10 stage starts have no flag, arch, or name text, stage entry detection still works (playtest drive-through of at least stages 1, 5 and 10), and verify passes.

### T2. Floor flicker (z-fighting) check
The owner saw the starting area floor flicker "like two floors inside each other". Plot border corner overlaps were already fixed (8 borders lowered 0.06).
- Rewrite the overlap check as: pairs of visible Parts, both with a top face wider than 8 studs in each direction (floor-like slabs), vertical gap under 0.3 studs, footprints overlapping. Include base ground, plot grounds, Safe Line, Vehicle Bay and any slab under them. Also flag pairs whose volumes overlap.
- `verify-world.luau` fails only on this narrowed set. Keep the old 2,773-item list in `docs/world-overlaps.md` as reference, not as a failing check.
- Fix real findings with the smallest change (delete a redundant duplicate, or lower one surface by 0.05 to 0.1). Do not change collision or alignment.
- Done when: the narrowed check reports zero pairs.

### T3. Walls taller and thicker
- The 26 perimeter walls: height x1.5, thickness x1.25.
- Keep each wall's base on the ground. Grow thickness outward so the playable area does not shrink. Keep collision on and keep the stud variant (block Parts only).
- Change sizes in the build routine and in `verify-world.luau`, not just the live world. Log before and after numbers in the report.
- Check by driving the fastest vehicle at a wall from several angles in a playtest. It must not clip through or launch over.
- Done when: verify passes with the new dimensions and the driving test passes.

### T4. Small hygiene items
- **Make `build-world.luau` runnable from the Studio command context:** fix or wrap the `Config` require/capability failure without changing game behavior. Generate any command-only literal values from the repo source rather than maintaining a second hand-written configuration. Test the complete builder in protected mode with a recoverable world backup and verification/rollback on failure. Document the exact working procedure in `docs/world-recovery.md`.
- **DataService real rejoin test** (the mocked test is not enough): in Studio, one playtest, join, stop, wait for the Studio-only 10 second reclaim, join again. It must not kick. Log the lock owner/age lines you print.
- **UI references:** write `docs/ui-reference/README.md`: one line per PNG saying what to copy (outline thickness, fonts, panel shapes, button style, palette). Use style only, never copy art.
- **Git:** check `git status`, `git log origin/main..HEAD`, and push. Note in `docs/owner-todo.md` that `assets/ui-kits` (a third-party icon pack, plus a PDF) is already public on GitHub and the owner should check its license for redistribution. Do not delete or rewrite it.

### T5. Prop grounding
The report logged prop grounding issues (floating or sunken props). Write a check that finds props whose lowest point is more than 0.3 studs above or below the surface beneath them, fix them through the build routine, and add the check to `verify-world.luau` as a warning (not a failure).

### T6. Collect-time scaling (O5)
Goal: a lower-tier vehicle in a higher-tier stage should think "I need to upgrade first". Collecting takes long enough that mobs catch a stationary vehicle. It must not be insane.
- First inspect how collection works today (instant touch, proximity hold, timed channel). **Today's behavior is the on-tier baseline and must not change.** If collection has no time component today, add base times to Config (plain 0.6 s, mutated 1.0 s), record that assumption, and apply the multiplier to those.
- In `Config`: `StageRecommendedTier[stage]`. Use the design doc if it defines one; otherwise stage N recommends vehicle tier N.
- `gap = max(0, recommendedTier(stage) - vehicleTier)`. `timeMultiplier = min(CAP, BASE ^ gap)` with defaults `BASE = 1.6`, `CAP = 4.0`. Gap 0 means exactly 1.0x. Keep both as named, easily tunable constants.
- The owner is unsure about the numbers and will judge them while playtesting. So: add `UnderTierScalingEnabled = true` in Config, keep BASE and CAP as easy-to-edit constants at the top of Config, and document in `docs/balance.md` exactly which lines to change. Do not tune further than the defaults.
- Server-authoritative: the server computes it. The client never sends a multiplier.
- Apply to collection time only. Do not change mob damage, speed or health.
- HUD: when the multiplier is above 1, show a small text on the existing HUD like "Underpowered here: collecting 2.6x slower". Not a world sign, and not at stage starts.
- Write `tools/balance-sim.luau` and `docs/balance.md`: a table of (stage x vehicle tier) showing the multiplier and the time to fill Cargo. Flag cells above 3.0x. The owner will tune constants from this table.
- Done when: gap 0 unchanged (test), gap 1/2/3 produce 1.6/2.56/4.0 (test), cap respected, HUD text shows, table written.

### T7. Stud style rollout (O4)
Finish what Stage 1 started: Stages 2-10 (floors, walls, arches), base ground, Vehicle Bay, Safe Line, plot grounds/borders/pedestal bases, and the new perimeter walls.
- One batch per stage / area using `tools/restyle-batch.luau`. Block Parts only. MeshParts untouched. Colors, sizes and collision unchanged.
- Run the Studio health gate and `verify-world.luau` after each batch. Commit each batch.
- Do not undo the 0.06 border fix.
- Done when: every block Part in the ground, wall and structure categories uses the variant and the T2 check still reports zero.

### T8. Cartoon pass, level 1 (O1)
Write `docs/art-direction.md` first: chunky simplified silhouettes, bright saturated colors, SmoothPlastic/Plastic only, no PBR textures, no photoreal textures, mobs that read as friendly-menacing not horror, stylized skulls only, existing rarity colors reused. Reference: `docs/ui-reference` and the blocky stud-and-neon style of the game's reference screenshots.

Then run a scripted, reversible pass over all 113 templates (60 items, 10 vehicles, 10 mobs, 33 props):
- Copy originals to `ServerStorage.ArtBackups` first.
- Remove SurfaceAppearance and mesh TextureID on MeshParts; remove realistic Decals/Textures. Keep face details on mobs if they are decals that read as cartoon.
- Set realistic materials (Metal, Concrete, Rock, Slate, Granite, Wood, Fabric, Marble and similar) to SmoothPlastic or Plastic.
- Push colors toward saturation: in HSV keep hue, saturation at least 0.55, value between 0.55 and 0.95.
- Never change size, CanCollide, mass, joints or pivot. Vehicles must still drive: run the existing driving verification after the vehicle batch.
- Write a per-template table in `docs/art-audit.md`: what was removed or changed, MeshPart count, and a "still looks realistic or too detailed" flag (high MeshPart count, complex silhouette). Mobs and vehicles come first.
- Lighting: add `src/server` code that sets cartoon lighting at startup from Config toggles (not world-only state): slightly higher Brightness, lighter OutdoorAmbient, ColorCorrection (Saturation +0.12, Contrast +0.05), subtle Bloom, low-density Atmosphere. No DepthOfField, no SunRays, mobile-safe.
- Done when: audit table exists, vehicles drive, verify passes, and captures (if available) show no PBR-looking assets.

### T9. Finish the original spec
Complete Phases 8 and 9 from `CODEX_PROMPT.md` and every gap in `docs/backlog.md`. Follow the exact numbers in `CODEX_PROMPT.md`. Reorder only if a dependency forces it. If a phase needs UIKits or an uploaded asset, build everything else and put the missing piece in `docs/owner-todo.md`.

### T10. AFK progression: "Rev Dyno" (O6)
Purpose: like squatting with a barbell in Kick a Lucky Block, the player can stand still and progress, with an upgradable rig that makes it faster. For a vehicle game the rig is a dynamometer in the base. Working name: Rev Dyno. "Torque" is the AFK currency.

Design (put it in `docs/afk-design.md` first, then implement):
- **Where:** one Dyno Pad per plot, built from block Parts in the stud style with a neon gauge and spinning roller cylinders.
- **Use:** ProximityPrompt "Rev up". While active, the player's current vehicle model (a cosmetic clone) sits on the rollers, wheels spin, exhaust puffs, the gauge needle moves. It stops when the player leaves the pad (distance), dies, presses Stop, or starts a run. Add a Stop button on the Dyno panel.
- **Earning:** server-side only. `torque += torquePerSecond * dt`, ticking from server time. The client only displays. **There is no cap and no session limit on how much Torque can be earned** (the owner wants it infinite). The better the equipped vehicle, the faster it earns.
  - Config defaults: `DynoBaseTorquePerSec = 1`, `DynoRollerGainPerLevel = 0.35`, `DynoVehicleTierGrowth = 1.35`.
  - `torquePerSec = base * (1 + gain * rollerLevel) * (growth ^ (vehicleTier - 1))`. With these defaults tier 10 earns about 15x tier 1. Treat the numbers as placeholders and keep them in Config.
- **Dyno upgrade ("Rollers"):** paid in Cash. Cost curve `cost(L) = DynoRollerBaseCost * 1.9^L`. Calibrate `DynoRollerBaseCost` against existing Cash numbers so the first level is affordable after roughly 1 to 2 successful runs.
- **Tuning shop (spends Torque):** three permanent account-wide boosts with no hard level cap, so infinite Torque always has somewhere to go. Each level costs more (`cost(L) = base * 1.35^L`) and gives less, so the total bonus approaches a ceiling without ever hitting a wall: `bonus(L) = A * (1 - 0.96^L)` with A = 0.5 for Engine Tune (speed), 1.0 for Hull Plating (HP), 0.6 for Winch Tune (collect speed). Tuning is applied before the T6 under-tier multiplier and can never remove it. Keep all numbers in Config.
- **Balance guardrail:** Torque only buys the soft-capped tuning above. It never converts to Cash, so AFK cannot replace active play. In `docs/balance.md`, estimate Torque per hour per vehicle tier and the level reached per hour, and show where the curve flattens, so the owner can tune.
- **Persistence:** add `torque`, `dynoRollerLevel`, and tuning levels to the profile with safe defaults. Old saves must load unchanged. Torque and tuning persist across Trade Up. Record that as a decision for the owner to confirm.
- **No idle-kick workaround.** Roblox kicks idle players after roughly 20 minutes. Do not try to circumvent it.
- **UI:** a Dyno panel (roller level, torque/sec, upgrade button, Tuning list) and a small Torque counter on the HUD only while revving, using the UI theme from T11 once it exists.
- **Tests:** mocked-store tests for accrual math, caps, level costs, and a save/load round trip with an old-format profile. Then one real playtest: rev, leave the pad, confirm accrual stops, rejoin, confirm Torque persisted.
- Done when: all tests pass, one real playtest passes, verify passes, and the pad is built through a script.

### T11. UI cartoon restyle (O1)
Create `src/shared/UITheme.luau` (fonts, palette, stroke thickness, corner radius, gradients) and move existing UI onto it. Use Roblox built-in fonts that fit a chunky bubbly style, thick dark UIStroke outlines, UICorner, UIGradient fills, text stroke on numbers, and small tween bounce on press. Cover: HUD (cash, Cargo, health), the Garage/Index/Inventory/Settings buttons, the upgrade shop, Trade Up, the rarity reveal, the Index, pedestal and income signs, damage numbers, and the new Dyno panel. Reference `docs/ui-reference`.
- Do not change behavior or layout logic. Mobile-safe: respect screen size, no tiny tap targets.
- You cannot upload icons. For icons you do not have, keep what exists and add the needed ones to `docs/ui-assets.md` (file name, size, purpose) for the owner to upload. Store asset IDs only in a Luau module once the owner supplies them.
- If `ServerStorage.UIKits` exists, you may inspect it for style ideas. Never depend on it at runtime.

### T11b. Juice pass (game feel)
Make the core loop feel good. Everything here is code in `src/` plus world pieces built by script.
- **Sound:** use free, public Creator Store audio only. Put all IDs in one `SoundConfig` module mapped to events, record owner and ID in `docs/third-party-assets.md`, and test that each loads in a playtest (`Sound.IsLoaded` / no errors in Output); drop any that fail or are restricted. Events: pickup (pitch rising with a quick combo), cash banked at the Safe Line, rarity reveal (stronger by rarity), purchase, Trade Up, damage taken, mob warning, button hover/click, Dyno rev loop (volume tied to the rev gauge), and quiet background music. Use SoundGroups for Music and SFX and add on/off toggles to the Settings screen if it exists.
- **Effects:** lightweight ParticleEmitters and tweens: pickup burst, floating cash numbers, rarity glow, mutation sparkle, bank confetti at the Safe Line, damage smoke or sparks on the vehicle. Cap emitter counts and lifetimes for mobile. No per-frame allocations.
- **UI motion:** count-up animation on cash and Torque, button bounce, panel open/close tweens, a short reveal sequence for rarity.
- **Camera:** a very small screen shake on heavy hits, with an off toggle in Settings.
- Since you cannot hear audio, verify by loading and event wiring, and note in the report that sound quality is unverified by ear.
- Done when: all events fire, toggles work, no Output errors over one full run playtest.

### T12. Replacement asset shortlist (do NOT swap overnight)
For the worst offenders in `docs/art-audit.md` (mobs and vehicles first, then items), search the free Creator Store for cartoony, low-poly, toy-like replacements (search terms: cartoon, low poly, toy, stylized, chibi, simple, blocky). Do not insert or replace anything permanently. Write `docs/asset-shortlist.md`: per category, up to 3 candidates with asset ID, creator, pack link, and what it would replace. Capture preview images only if captures work. Prefer one or two creators per category for consistency. Never include assets with embedded scripts in the recommended list unless the scripts can be stripped.

### T13. Final report (always do this last, and at minimum before stopping)
Write `docs/overnight-report.md`:
1. Done (with commit hashes), Partial, Skipped (and why).
2. Decisions and assumptions made.
3. Test results, including anything unverified visually.
4. `docs/owner-todo.md` contents: Save to Roblox with Notes, Download a Copy, upload `stud_tile.png` and replace the third-party stud texture ID, place UIKits, check the `assets/ui-kits` license, confirm Torque persists across Trade Up, tune `balance.md` constants.
5. Final state: confirm no playtest is running and Studio is in Edit mode.

---

## 4. Definition of done for the night

- `tools/verify-world.luau` passes on the final world state.
- Everything committed and pushed (or the push failure logged).
- `docs/overnight-report.md` and `docs/owner-todo.md` exist and are accurate.
- No playtest running, Studio in Edit mode.
