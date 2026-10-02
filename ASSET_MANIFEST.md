# Asset manifest

Creator Store assets are visual shells only. Every insert is quarantined in ServerStorage, scanned, and stripped of executable scripts, remotes, prompts, tools and external loader objects before use. No Toolbox code is needed by the shared controller or enemy system. Per-asset audit entries follow.

| ID | Name | Creator | Use | Scripts kept | Scripts removed | Outcome |
|---|---|---|---|---|---|---|
| 138241998952273 | Grass Realistic Nature Ground Foliage Tufts | Glooc5365 | grass tuft | 0 | CoreValidation, Check [flagged], LocalScript, LocalScript, LocalScript, LocalScript | 1 parts |
| 4559971334 | Small Rock | oddgotbanned | small rock | 0 | none | 1 parts |
| 166226416 | Tree Stump | Sapphiros | tree stump | 0 | none | 71 parts |
| 14629857106 | Wildflowers | Lazy_kitin | wildflower | 0 | none | 1 parts |
| 113212570128450 | 🗑️ Trash Pile Rubbish Debris Junk Material Prop | Echo_Thunder201565 | junk pile | 0 | none | 1 parts |
| 132797525489587 | Industrial Clutter Junk Scrap Pile Debris Dump | Rextwi7406 | scrap pile | 0 | spin, CoreValidation, Check [flagged], LocalScript, LocalScript, LocalScript, LocalScript | REJECTED: 235 parts |
| 9504148189 | Tire Stack | RealgrumpyKitten1 | tire stack | 0 | none | 1 parts |
| 7992120142 | Chain Link Fence | logan3245678 | chain link fence | 0 | none | 1 parts |
| 131022266437920 | Old Fridge Retro Kitchen Appliance Vintage | Her0850N0vaPixel | old fridge | 0 | qPerfectionWeld, LightConfig, Type [flagged], EasyConfiguration | 6 parts |
| 2106113027 | Washing Machine | StarModelX | washing machine | 0 | none | 20 parts |
| 14557683174 | Broken TV (w/ Glitch Effect) | DinoFan234B | broken tv | 0 | none | 9 parts |
| 7406028156 | cargo containers | fgher_gamer | cargo container | 0 | none | REJECTED: 420 parts |
| 684705155 | Dock crane | jack_3362 | dock crane | 0 | none | 145 parts |
| 481477468 | Anchor | Jac16king | anchor | 0 | none | 1 parts |
| 12130179055 | Furnace | Jo_Lua | furnace | 0 | none | 34 parts |
| 60688591 | Old Factory Machine | InvinciNinja | factory machine | 0 | none | 11 parts |
| 1003164316 | brick smokestack | morinabinks | smokestack | 0 | none | 19 parts |
| 13958013198 | Barbed Wire | Sentry Corrections | barbed wire | 0 | none | 2 parts |
| 6883609157 | Military Tent | ForestFireTree1 | military tent | 0 | none | 11 parts |
| 12651656400 | Sandbag Barrier | Aheadit | sandbags | 0 | none | 1 parts |
| 5241611800 | Watchtower | dogdayboy1 | watchtower | 0 | none | 43 parts |
| 4855489831 | Lab Equipment (Breaking Bad) | DionManiac | lab equipment | 0 | qPerfectionWeld | 121 parts |
| 17128613350 | Server Rack | •Games•Studio• | server rack | 0 | none | REJECTED: 271 parts |
| 5297864495 | Desk and computer | MURMELI678 | computer desk | 0 | none | 130 parts |
| 57151893 | containment tank | Johnathon2 | containment tank | 0 | none | 6 parts |
| 70765002 | Biohazard Barrel | Hedonutopia | biohazard barrel | 0 | none | 4 parts |
| 135827610386594 | Test Tube | BeanifyMe | test tube | 0 | none | 57 parts |
| 162741606 | UFO | Roblox | ufo | 0 | Script, ControlScript | 47 parts |
| 131804872643900 | 💥 Sci-Fi Spaceship Wreck Asteroid Space Ship | XzVenatorrXTurbotzX1 | spaceship wreck | 0 | ButtonIgnitionScript, LightConfig, Type [flagged], EasyConfiguration, PoseTexture, TextureConfiguration | REJECTED: 195 parts |
| 10417066479 | alien crystal | Duxcomp | alien crystal | 0 | none | 1 parts |
| 127684722020066 | floating rock | justinzoo123 | floating rock | 0 | none | 1 parts |
| 18506880748 | 💫 Teleport Portal Teleporter Working | Manestronomer | portal | 0 | Script, Script, Credits | 16 parts |
| 129968267658404 | ⚡ Glitch Block Corrupt Debris Error Cube | Lavam8Herod155313 | glitch cube | 0 | LightConfig, Type [flagged], EasyConfiguration | 1 parts |
| 139715416205638 | Trash Waste Litter Junk Scrap Pile Heap RP Decor | ubiquitarniasm | scrap pile | 0 | LightConfig, EasyConfiguration, Type [flagged] | 1 parts |
| 5375958178 | cargo_container | akashi_mizu | cargo container | 0 | none | 1 parts |
| 120631576642977 | Realistic Server Rack | W1therEdBonn1e728 | server rack | 0 | none | 15 parts |
| 142364664 | Massive spaceship wreck | HandiQuack | spaceship wreck | 0 | Script, Script, Detonate, Atom, Shake | REJECTED: 253 parts |
| 138241998952273 | Grass Realistic Nature Ground Foliage Tufts | Glooc5365 | grass tuft | 0 | CoreValidation, Check [flagged], LocalScript, LocalScript, LocalScript, LocalScript | 1 parts |
| 2106113027 | Washing Machine | StarModelX | washing machine | 0 | none | 20 parts |
| 481477468 | Anchor | Jac16king | anchor | 0 | none | 1 parts |
| 12130179055 | Furnace | Jo_Lua | furnace | 0 | none | 34 parts |
| 4855489831 | Lab Equipment (Breaking Bad) | DionManiac | lab equipment | 0 | qPerfectionWeld | 121 parts |
| 135827610386594 | Test Tube | BeanifyMe | test tube | 0 | none | 57 parts |

Full raw safety results are in `docs/asset-audit.json`. Stale sandbox capability metadata is cleared after script removal to allow safe visual cloning. Spaceship wreck: clean six-part broken hull fallback; both Creator Store candidates exceeded the mobile part budget.


## Visual-style sample candidates — pending approval

| Asset ID | Name / creator | Sample use | Scripts kept | Scripts removed | Verification |
|---|---|---|---|---|---|
| 11120912366 | 2008-2024 Stud Materials PBR / ReeceTheUncancelable | Selected regular 2022 Stud color and normal maps for shared SalvageStud | 0 | none present | Definition installed on four isolated samples; remote fetch failed, visual review pending; candidate import deleted |
| 110535478048879 | Diamond Plate Metal Texture Material Kit / CrystalEchoSt3alth20 | Selected PBR maps for shared SalvageDiamondPlate trim | 0 | Constant; TextureConfiguration | Both executable descendants deleted; variant installed on preview trim; remote fetch failed, visual review pending; candidate import deleted |
| 7447638611 | Stud Texture / born2swaos | Tried advertised one-stud tile as alternate | 0 | none present | Remote fetch failed; not adopted; candidate import deleted |

Only `src/shared/VisualStyle.luau` holds the editable map IDs and global scale. These candidates have not been applied to the existing map or template inventory. Fetch failures also affect an existing remote game mesh, so candidate usability is not settled by this session. Do not claim approval or working surface rendering from insertion alone.


Image-level provenance verified with Roblox MarketplaceService.GetProductInfo: stud color-map image 10509831729 is named 2022 studs alb.png and is uploaded by ReeceTheUncancelable (User ID 67061092), also creator of source model 11120912366. Found by the free Creator Store search stud material, then reading the regular 2022 Stud variant after quarantined insertion. Candidate remains unconfirmed and is awaiting replacement by the user's own image ID. The user selected MaterialVariants for block Parts only; MeshParts remain smooth and color-only. No rollout authorized.
