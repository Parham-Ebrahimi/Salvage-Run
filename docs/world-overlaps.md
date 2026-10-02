# Read-only top overlap audit — 2026-10-02

Place 120476079479285, Studio Edit. This full inventory records the read-only scan **before** the subsequently approved border repair. The CSV/JSON files preserve that pre-repair evidence; see the current repair result below.

Checked 2211 Workspace BaseParts (including Part subclasses and MeshParts, excluding Terrain). 1349 distinct parts form 2789 pairs within 0.05 studs in world bounding-box top height and with positive-area XZ box-footprint overlap. Edge-only contact is excluded. Rotated/curved/mesh geometry is flagged as a conservative box candidate, not proof of visible coplanarity. Invisible parts are included and marked. These candidates include internal prop pieces and intentional overlays.

The complete list of every matching part, name, position, size, material and new-stud flag is in [world-overlaps-parts.csv](world-overlaps-parts.csv). Every pair is in [world-overlaps-pairs.csv](world-overlaps-pairs.csv); audit IDs disambiguate repeated sibling names. The complete structured output is in [world-overlaps.json](world-overlaps.json).

## Starting plots

Exactly 16 qualifying pairs in the plots: four corner overlaps per plot. All 16 border Parts are visible, level blocks with top Y=1.100000024. None uses SalvageStud. No qualifying pair involves a plot Ground, and no Baseplate exists.

| Audit ID | Instance | Position (X, Y, Z) | Size (X, Y, Z) | New stud variant |
|---|---|---|---|---|
| 622 | Workspace.SalvageWorld.Plots.1.Border | (-129.000, 0.600, 170.000) | (76.000, 1.000, 1.000) | No |
| 623 | Workspace.SalvageWorld.Plots.1.Border | (-129.000, 0.600, 94.000) | (76.000, 1.000, 1.000) | No |
| 624 | Workspace.SalvageWorld.Plots.1.Border | (-167.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |
| 625 | Workspace.SalvageWorld.Plots.1.Border | (-91.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |
| 626 | Workspace.SalvageWorld.Plots.2.Border | (-43.000, 0.600, 170.000) | (76.000, 1.000, 1.000) | No |
| 627 | Workspace.SalvageWorld.Plots.2.Border | (-43.000, 0.600, 94.000) | (76.000, 1.000, 1.000) | No |
| 628 | Workspace.SalvageWorld.Plots.2.Border | (-5.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |
| 629 | Workspace.SalvageWorld.Plots.2.Border | (-81.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |
| 630 | Workspace.SalvageWorld.Plots.3.Border | (43.000, 0.600, 170.000) | (76.000, 1.000, 1.000) | No |
| 631 | Workspace.SalvageWorld.Plots.3.Border | (43.000, 0.600, 94.000) | (76.000, 1.000, 1.000) | No |
| 632 | Workspace.SalvageWorld.Plots.3.Border | (5.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |
| 633 | Workspace.SalvageWorld.Plots.3.Border | (81.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |
| 634 | Workspace.SalvageWorld.Plots.4.Border | (129.000, 0.600, 170.000) | (76.000, 1.000, 1.000) | No |
| 635 | Workspace.SalvageWorld.Plots.4.Border | (129.000, 0.600, 94.000) | (76.000, 1.000, 1.000) | No |
| 636 | Workspace.SalvageWorld.Plots.4.Border | (167.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |
| 637 | Workspace.SalvageWorld.Plots.4.Border | (91.000, 0.600, 132.000) | (1.000, 1.000, 76.000) | No |

The border rectangles overlap by 0.5 × 0.5 studs at each corner, with exactly coplanar tops. None is a redundant whole-Part duplicate, so deleting a full border would remove a needed side. Proposed minimal height-only repair: lower each plot's two 1 × 1 × 76 side borders from center Y=0.60 to Y=0.54 (eight Parts total). Their tops become 1.04; 0.06 separation from the other borders exceeds the requested 0.05 tolerance. Keep all sizes, colors and variants. Update the builder's side-border Y to reproduce the fix only after approval.

**Historical proposal: approval was subsequently received and the repair below applied.** The new overlap portion of verify-world.luau reports FAIL / needs review for the current 2,789 broad candidates; structural inventory independently passes (4 plots, 48 pedestals, 10 stages/arches, 80 props, 113 templates, 26 walls, no Baseplate). Fixing plot corners will not clear unrelated prop/overlay candidates. No candidates have been silently whitelisted. Restyle batches now refuse to run when this combined verification reports Passed=false.



## Current repair result — user approved

Lowered exactly eight 1 × 1 × 76 side-border Parts from center Y=0.60 to Y=0.54. Positions X/Z, sizes, colors and materials/variants are unchanged. New side-border top is 1.04; front/back borders remain at 1.10. The complete repair ran with rollback snapshots and checks before returning success.

- Plot overlap pairs: **16 → 0**.
- Broad world candidate pairs: **2,789 → 2,773**. Remaining prop/overlay/bounds candidates are not silently ignored or treated as verified z-fighting.
- Structural inventory: PASS (4 plots, 48 pedestals, 10 stages/arches, 80 props, 113 templates, 26 walls, no Baseplate).
- Outside the repair: 2,192 SalvageWorld Parts checked unchanged.
- Whole-world overlap gate: needs review / Passed=false, because unrelated candidates remain.

Builder now uses Config.World.PlotSideBorderDrop=.06 for the side-border height so the repair is reproducible. The saved binary snapshot is older; do not overwrite the current live world from it without refreshing/replaying recorded edits. User notified to save/publish; awaiting confirmation. No additional restyle batch and no Play session were started.

## Persistent floor flicker: reappeared Baseplate removed — 2026-10-02

The user still observed flicker on the base and Stage 1 floors. A subsequent read-only inspection found Workspace.Baseplate present again: position (0,-10,0), size (512,20,512), top Y=0, Plastic, empty MaterialVariant, visible. Its XZ footprint is [-256,256] on both axes, overlapping BaseGround and Stage 1 Ground at exactly the same top height. The screenshot shows this large gray platform. Its reappearance cause is unknown. No occupied Terrain voxels were found around the starting area, and no floor texture/decal/surface overlays were found.

After explicit user approval, deleted only Workspace.Baseplate. Verified the canonical structural inventory, zero plot overlap pairs, and all 2,212 other Workspace BaseParts unchanged. A separate live check confirms the Baseplate remains absent and the intended base and Stage 1 floors remain at top Y=0. Stage 1 retains SalvageStud. Broad overlap candidates remain 2,773; InventoryPassed=true but overall Passed=false. User visual confirmation of flicker resolution and Roblox save/publish are pending. No Play control or further styling batch occurred.

## Current state after Rojo reset and repair restoration — 2026-10-02

The stale Rojo server was serving a Baseplate definition and restored it on Play-server reconnect. The user's first reset loaded the older world snapshot, reverting the border drop and Stage 1 styling. Source-only salvage-run-live is now verified active, with no static-world/Baseplate definitions served. Reapplied the eight already approved side-border drops and verified plot overlap pairs zero, Baseplate absent and structural inventory passing. Stage 1 styling has not been restored; the earlier SalvageStud observation is historical.

A requested 26-wall enlargement subsequently failed its new verifier's CFrame comparison. Its transaction restored every wall, and the wall-related repo changes were also reverted. The overlap repair remains applied. Current walls remain 32 studs high, 4 thick, anchored/collidable, with their original materials. The canonical verifier reports 2,773 other broad overlap candidates and overall Passed=false. User notified to save/publish the overlap repair; no wall retry or Play control taken.
