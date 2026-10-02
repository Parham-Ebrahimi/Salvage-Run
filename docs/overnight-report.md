# Overnight report — 2026-10-02

Run in progress. Owner authorized unattended work, confirmed the recovery checkpoint saved, and explicitly accepts structural inventory plus zero narrowed plot-border overlaps until T2 replaces the broad gate. The historical 2,773 candidates do not cause rollback.

## Completed / evidence

- T5: all80 stage props grounded through10 separate verified/committed batches.
  Initial43 >0.3 bounds warnings now0. Builder translates by actual world-space
  lower bounds, fixing template pivot offsets. Verifier includes floor-only
  ray grounding warnings without turning warnings into failure. Stage6 first
  attempt rolled back completely on overly tight0.0001 residual assertion;
  retry with0.01 float tolerance passed (well below0.3 warning). All structural,
  floor and plot-border gates passed. SAVE POINTs in world-batches.md.

- T4 real rejoin PASS: stopped first session, >10 seconds elapsed while doing
  source work, joined again; both had one player, BASE, Scratch=false and
  original current vehicle2. No kick or refused load. Output acquired owner
  :ef0e8243-0643-433e-a9a9-32d5dbab4675 age0s, then released; next acquired
  :5b222d0b-a2b4-486c-a249-79ec92b8074d age0s, then released. Namespace
  SalvageRun_v1_Studio; production180s/60s unchanged, Studio reclaim10s/renew5s.
  All10 mocked lock tests pass, including refused owner/age logging, Release
  and BindToClose. Studio-only acquired/released diagnostics added.
- T4 UI-reference README covers all8 inspected PNGs. Public-kit license review
  is in owner-todo. Commits through90a8949 pushed successfully.

- T3 driving PASS: Hover Bike, actual W, angles0/30/60; max speeds100.34/
  103.82/103.94; maxX74.535/73.974/74.625 (inside inner face78), maxY2.21
  (wall top48). No clipping/launch. Initial fixture hit a prop before reaching
  a wall; moved fixture to the clear entrance. Temporary tier10 ownership and
  upgrades restored before stopping Play. No script errors in Output.

- T3 world batch: all26 walls verified at height48/thickness5. CenterY16→24,
  baseY0 unchanged; outward offset0.5 keeps inner faces X=±78 (strip),
  X=±178 (base), shoulder Z=2, back Z=178, end Z=-3498 unchanged.
  Collision, colors and contact physics preserved; all26 use SalvageStud.
  Builder and verifier share WorldGeometry. Fastest-vehicle tests pending.
  SAVE POINT recorded.

- T2: narrowed visible slab/volume check replaces broad pass criterion. Initial
  three separated overlay pairs cleared; Studio reports zero floor pairs and
  zero plot-border pairs, eight borders at0.54, structural inventory PASS.
  Bay top0.16→0.30; SafeLine top0.25→0.30; seven Bay marks follow Bay.
  Assumption/deviation: raised overlays to preserve supporting floor heights;
  suggested lowering would embed the overlays or move the playable floors.
  Sizes, XZ positions and collider settings preserved. Historical broad list
  retained. SAVE POINT recorded; owner should visually inspect on return.

- T1 acceptance: actual W-driven crossings at Stage1 Z=-26.18, Stage5
  Z=-1412.55, Stage10 Z=-3217.42 (X=10 to avoid existing cosmetic grid).
  Stage entry remains functional. Fixed stage-0 client Fog lookup; subsequent
  playtest Output had no script errors. All playtests stopped afterward.
- T4 rejoin evidence so far: multiple stop/rejoin cycles separated by >10s
  loaded the real Studio profile (Scratch=false), without lock refusal or kick.
  No refused-load owner/age lines occurred; final dedicated lock test pending.
- Source-only Rojo server reconnected and accepted through its UI. Verified
  EntryFixture arrived from repo and arches/Baseplate remained absent.

- T1 world batch: removed 10 Arch models containing 50 Parts (20 pillars,
  10 headers, 20 lights) and 10 SurfaceGuis with stage names/skulls. Originals
  copied to ServerStorage.ArtBackups.StageArchesBeforeO2. No gameplay source
  references Arch; StageService remains coordinate-based. Builder and verifier
  now expect zero arches. Studio structural and plot-border gates passed.
  Drive-through acceptance remains pending. SAVE POINT recorded.
- Git push succeeded after verification of the existing owner repository and
  explicit work-order authorization: origin/main includes 084620a and 40fc7bd.

- T4-first: generated command-context module factories from repo sources;
  full protected builder test passed in Studio Edit and restored the exact
  original world. Inventory: 4 plots / 48 pedestals / 10 stages / 80 props /
  26 walls / 113 templates; missing templates 0, Baseplate absent, narrowed
  plot-border pairs 0. Procedure in world-recovery.md. SAVE POINT recorded;
  continue under overnight authorization.

- T0: read spec, prompt, progress, recovery/overlap/style documents and history; master backlog and copied owner overrides recorded. No world edits in T0.
- T0 local commit: 084620a. Automatic approval review rejected git push because it considered origin unverified and remote publication unauthorized. Read-only git remote verification identifies origin as https://github.com/Parham-Ebrahimi/Salvage-Run.git. The work order explicitly requires push origin main; no credentials or remote have been changed. Local commits are retained.

## Partial / pending

See backlog.md for the complete queue. T1 is next. No overnight playtest has started yet. Final state will be verified before completion.

## Decisions

- The added T4 command-context builder item runs immediately after T0 because later builder changes depend on it.
- Saved Stage1 means 150 processed block Parts:145stud/3trim/2Neon, not 150 identical stud Parts; original role behavior is preserved.
- Use live.project.json for sync; default.project.json is a snapshot/build artifact and can overwrite newer live edits.
- Older SAVE POINT waits are suspended for this explicitly authorized overnight run; record checkpoints here and continue.

## Owner handoff

See owner-todo.md. Final commit hashes, tests, screenshots, skipped work and Studio state will be appended as batches complete.
