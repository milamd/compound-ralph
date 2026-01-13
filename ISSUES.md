# Known Issues

> **Note:** When a known issue is fixed, remove it from this file. An empty file means no known issues.

## Loop Thrashing (Consequence of Hat Mismatch)

**Severity:** Critical

**Symptom:** The loop thrashes indefinitely, never reaching a terminal state. Each iteration emits `build.blocked` which triggers the next planner iteration, which also emits `build.blocked`.

**Root Cause:** When the planner receives builder instructions (due to the hat mismatch bug above):
1. Builder instructions say to pick a task from the scratchpad
2. Scratchpad doesn't exist (planner should create it)
3. Builder instructions say to emit `build.blocked` when stuck
4. `build.blocked` triggers the planner
5. Planner again receives builder instructions → goto step 1

**Flow:**
```
planner (wrong instructions) → build.blocked → triggers planner
                                    ↑                    │
                                    └────────────────────┘
```

**Note:** The `max_consecutive_failures` safeguard doesn't catch this because the iterations "succeed" (CLI exits 0), they're just logically stuck.

**Potential Fix:** Add detection for repeated `build.blocked` events from the same hat within N iterations.

**Investigation Status:** Debug logging has been added to `crates/ralph-core/src/event_loop.rs` in the `build_prompt()` method to trace hat routing. This will help identify if the hat mismatch is actually occurring and where in the flow it happens.

