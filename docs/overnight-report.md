# Overnight report — 2026-10-02

Run in progress. Owner authorized unattended work, confirmed the recovery checkpoint saved, and explicitly accepts structural inventory plus zero narrowed plot-border overlaps until T2 replaces the broad gate. The historical 2,773 candidates do not cause rollback.

## Completed / evidence

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
