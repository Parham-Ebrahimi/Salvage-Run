# Shared stud material approval sample

Current authorization (2026-10-02): temporary use of third-party stud image 10509831729, with rollout restricted to block Parts and one stage or plot per batch. Every batch requires Studio inventory verification and a stop for the user to save/publish before continuing. Earlier sections below record the sample history; the current approval supersedes their unconfirmed-candidate status. Do not run a whole-map restyle.

## Reference inspection

Inspected all eight PNGs under `docs/ui-reference`: `Screenshot 2026-09-14 232559.png`, `shop_ui_featured.png`, `shop_ui_money.png`, `shop_ui_speed.png`, `shop_ui_speed2.png`, `index_ui.png`, `shop_icon.png`, and `index_icon.png`. They show repeated square studs, dark borders, large outlined text, and bright accent panels. No README was present when inspected. These are references, not imported UI kits; UIKits work is outside this task.

## Definition and reproduction

`src/shared/VisualStyle.luau` is the single editable source for both variant definitions and the global tiling value. The candidate `StudsPerTile` is 1, with Regular tiling. Body surfaces use `SalvageStud`, trim uses `SalvageDiamondPlate`, and glowing elements use Neon. Applying the helper preserves a part's color and removes imported surface overlays from the styled instance. It does not override base materials globally.

Execute `tools/preview-visual-style.luau` in Studio Edit, then execute `tools/verify-world.luau`. The preview creates `Workspace.VisualStylePreview` outside the existing map at (225, 42, 65):

- Floor: 14 × 1 × 12 Part.
- Wall: 14 × 8 × 1 Part.
- Box: 4 × 4 × 4 Part.
- MeshPart: cloned audited small-rock geometry, sized 4 × 4 × 4; imported texture cleared on the clone.
- Diamond plate top trim and a cyan Neon accent.

The four body samples have the same neutral tint and reference the same stud variant. Select the group and press F to frame it. Samples are temporary review geometry, not part of the production world snapshot. They can be recreated from the repo. The shared module is synced through Rojo; material installation is an Edit operation. MaterialService artifact packaging and conversion of other builders remain pending approval.

## Toolbox provenance

Stud candidate: [2008-2024 Stud Materials PBR](https://create.roblox.com/store/asset/11120912366), ReeceTheUncancelable. Selected the regular `2022 Stud` variant, using its color and normal maps. Import contained no executable scripts. Only the two selected map references are used; the candidate collection was removed from quarantine after inspection.

Trim candidate: [Diamond Plate Metal Texture Material Kit](https://create.roblox.com/store/asset/110535478048879), CrystalEchoSt3alth20. Selected its color, normal, metalness and roughness maps. Removed both executable descendants (`Constant`, `TextureConfiguration`) and retained no imported code. Candidate import removed from quarantine after inspection.

Also tried [Stud Texture](https://create.roblox.com/store/asset/7447638611), born2swaos, advertised as a 1 × 1 stud tile. It did not fetch successfully and was not adopted.

## Verification status

Verified in the reopened place 120476079479285, Studio 6826b07e-51dc-4354-9b62-f61d51c00698, in Edit; no Play session started or stopped.

- PASS: all four sample classes/sizes and shared variant references exist; no per-part Texture, Decal or SurfaceAppearance overlays remain on samples.
- PASS: both MaterialVariants installed in MaterialService with the shared scale and Regular pattern; six preview parts total.
- PASS: zero existing SalvageWorld parts use these variants. All ten stage floor colors and materials remain equal to existing Config.
- PASS: repeated world inventory verification after mutations: 4 plots, 48 pedestals, 10 stages/arches, 80 props, 113 templates, 26 perimeter walls, no Baseplate.
- PENDING: real visual review, equal apparent stud scale on the MeshPart, seamless tiling and user approval. Both attempted Studio captures returned black. All six remote candidate map fetches failed; an existing remote game mesh also failed, while a built-in particle texture loaded. This does not establish that the candidates themselves are unusable. Do not label them visually verified.

If the candidate remains unusable after remote asset loading is restored, ask the user to upload a seamless square-stud tile: square PNG, opaque neutral white/gray base, one centered raised square stud per tile, matching flat pixels at every edge, no baked perspective or lettering. A 512 × 512 or 1024 × 1024 tile is suitable. Optional matching tangent-space normal map gives raised detail. The image should contain one stud so global StudsPerTile=1 yields one stud per world stud. For trim, request a matching seamless grayscale diamond plate tile and optional PBR maps. The user supplies permitted image asset IDs; store them only in VisualStyle, then rerun the four-sample check and show a visible capture before rollout.


## A/B comparison update

The preview routine now creates two matching sets at X offsets -9 and +9 from the original origin. Row A (left) uses Plastic, no MaterialVariant, and SurfaceType.Studs on all six surface properties. Row B (right) uses the shared stud variant with all surfaces Smooth. Each pair has exactly matching colors and dimensions; the earlier trim/Neon demonstrations are removed from this focused comparison. Each row also contains a hidden BillboardGui label anchor.

The user message still contains <paste ID>, so the intended replacement image ID is missing. Row B retains the prior unapproved candidate and is labeled Texture ID pending. VisualStyle.PreviewTextureConfirmed is false. Do not substitute an ID or treat the current candidate as confirmed. Once the user supplies the image ID, update the central ColorMap; remove the old normal map unless it is a matching map for that image, then rerun the sample and inventory checks.

Current Studio captures render successfully. Built-in studs show on the three Parts, but the MeshPart stays smooth despite all six SurfaceType properties being set. The MaterialVariant is visible on the MeshPart as well as the three Parts. All color/size pairs and stored surface properties passed assertions. Actual appearance approval remains pending. No existing map parts have been restyled.


## Current decision: block Parts only

The user chose the Row B approach for block Parts only, without approving candidate image 10509831729. CODEX_PROMPT and the shared helper now restrict MaterialVariants to block Parts. MeshParts use SmoothPlastic and color only, with empty MaterialVariant/TextureID and Smooth on all six surface properties. Both preview MeshParts now follow this rule; earlier comparisons showing a textured mesh are historical. The map and templates have not been converted.

Verified directly with Roblox MarketplaceService asset metadata: 10509831729 is the Image asset named 2022 studs alb.png, uploaded by ReeceTheUncancelable (User ID 67061092). The source model 11120912366, 2008-2024 Stud Materials [PBR], has the same creator. Discovery was the free Creator Store query stud material, followed by quarantined insertion and inspection of the regular 2022 Stud MaterialVariant.ColorMap. The ID was taken from the pack; it was not supplied by the user.

PreviewTextureConfirmed remains false. Await the user's own image ID, replace the central color map and remove the old normal map unless the user supplies a matching normal map, then verify/show the updated sample. Explicit approval is still required before rollout. World inventory verification passed after making the preview meshes smooth.


## Third-party dependency approved temporarily — 2026-10-02

| Dependency | Owner / uploader | Source pack | Approval date | Release requirement |
|---|---|---|---|---|
| Stud color map: 10509831729, 2022 studs alb.png | ReeceTheUncancelable, Roblox User ID 67061092 | [2008-2024 Stud Materials PBR, asset 11120912366](https://create.roblox.com/store/asset/11120912366) | 2026-10-02 | **Replace with an owned upload before release.** |
| Matching stud normal map: 10509831753 | Extracted alongside the color map from the same creator's pack; image-level ownership not separately checked | Same pack | Kept with the temporarily approved Row B material | Replace with an owned matching map, or clear when replacing the color map. |

The color-map uploader and image name were verified using Roblox MarketplaceService asset metadata. Discovery used the free Toolbox/Creator Store query stud material, followed by quarantined insertion and inspection of the regular 2022 Stud MaterialVariant. Temporary approval does not imply this asset is owned by the game creator. All editable map IDs remain in src/shared/VisualStyle.luau; PreviewTextureConfirmed is now true for the temporary approval.

## Batch execution contract

Use tools/restyle-batch.luau with exactly one stage number and tools/verify-world.luau as the verifier callback. The runner verifies the starting world, checks installed variants, takes all rollback snapshots before applying changes, and applies/verifies the whole batch without yielding. Any application or verification error restores the full batch and returns Stop=true. The caller must stop on any error or usage limit rather than retrying or beginning another batch.

Each stage batch includes that stage's eligible block Parts and its two StripWall side walls. Block body surfaces use SalvageStud; metal arch trim uses SalvageDiamondPlate; existing Neon accents remain Neon. Colors, geometry and contact physics are preserved. MeshParts and non-block Parts remain untouched in this rollout. The helper's smooth-mesh policy is available for future explicitly authorized work; this rollout does not change existing meshes.

After successful verification, stop for the user's save/publish confirmation. Source-defined variants and the batch script are repo-reproducible; the older binary world snapshot and whole-world builder do not yet include batch edits. Do not cold-build/overwrite the place from that old snapshot during rollout. When packaging is authorized, refresh the snapshot/MaterialService artifact or replay recorded batches after a static-world rebuild and verify before use.


## Completed batch ledger

| Batch | Scope | Studio verified result | Roblox save/publish |
|---|---|---|---|
| 1 — 2026-10-02 | Stage 1, including its two side walls | PASS: 150 block Parts (145 stud, 3 diamond plate trim, 2 retained Neon); colors, geometry and physics preserved; all 2,050 non-target parts unchanged; canonical world inventory PASS | User notified; awaiting confirmation |

No other stage or plot has been restyled. Batch 1 did not modify any MeshPart. Stage 1 stores VisualStyleBatchComplete=true and the matching color map/global tiling attributes for recovery inspection. No error occurred, and rollback was not needed. Stop here until the user confirms save/publish; never treat source-only or unsaved edits as a published checkpoint.
