# Studio save-lock recovery — 2026-10-02

DataService is the custom src/server/DataService.luau. PlayerRemoving in init.server.luau calls Data.Release, which calls Save(player,true) before clearing local tables. DataService.Init registers BindToClose, which starts release saves and waits up to Config.Timing.ShutdownDeadline=25 seconds. Release is attempted on both paths, but API failure or shutdown ending before completion can leave the prior lock. This explains a plausible cause of the reported kick; the historical incident was not reproduced.

## Studio-only change

Studio continues to use SalvageRun_v1_Studio. Lock acquisition and renewal record UserId, UpdatedAt and JobId alongside Token/Expires. A foreign-token lock on the same user's player_<id> record is reclaimable when its last renewal is at least 10 seconds old. A legacy lock lacking UserId is associated with the user by that record key; its age is inferred as now - (Expires - 180). A different recorded user ID with an unexpired lock remains protected.

Studio saves/renews every 5 seconds so a healthy current test does not normally appear stale after 10 seconds. A refused Studio load warns with profile user, recorded lock user, owner token, job and lock age/remaining lease. Reclaim uses the existing atomic UpdateAsync and preserves Data; the old token cannot overwrite the new owner. Existing six-second busy retries mean an immediate reconnect may be refused at ages 0 and 6, then reclaim at age 12.

Production still uses SalvageRun_v1, the original 180-second lease, 60-second save interval, Token/Expires record shape, foreign-lock rejection until expiry, release callbacks, retries and shutdown deadline. Studio-only short reclaim and refusal diagnostics do not run in production.

## Validation and limits

Verified new source/config are synced in the connected Studio Edit place; PlayerRemoving and BindToClose hooks are present. Syntax compilation passed. tools/test-data-service.luau runs the real DataService source against injected mock services (no real DataStore reads/writes, real players, or Play). Ten checks passed: 10-second same-user reclaim with data preservation; fresh refusal/owner-age log and retry; legacy lock; different-user rejection; production refusal; production expiry/record shape; player-removal release; shutdown release; displaced-token write protection; and Studio/production renewal intervals.

A real stopped-playtest/rejoin check is **not performed**. No user or other Studio session was started/stopped. An already running server retains its previously required module until a fresh session. User controls when to restart testing.
