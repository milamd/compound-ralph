# Gap Analysis Results

> Analysis date: 2026-01-13
> Specs analyzed: 13

## Summary

| Priority | Issue | Spec | Status |
|----------|-------|------|--------|
| 🔴 P0 | Custom backend args/prompt_flag missing | cli-adapters.spec.md | NEW |
| 🔴 P0 | Custom backend validation missing | cli-adapters.spec.md | NEW |
| 🔴 P0 | Kiro adapter settings missing | cli-adapters.spec.md | NEW |
| 🟡 P1 | Interactive idle timeout doesn't reset | interactive-mode.spec.md | NEW |
| 🟡 P1 | Per-adapter timeout not enforced | cli-adapters.spec.md | NEW |
| 🟡 P1 | CLI executor working directory | cli-adapters.spec.md | NEW |
| 🟡 P1 | Planner behaviors instruction-only | event-loop.spec.md | By Design |
| 🟡 P1 | Builder behaviors instruction-only | event-loop.spec.md | By Design |
| 🟢 P2 | Scratchpad persistence not verified | event-loop.spec.md | By Design |
| 🟢 P2 | Hat display order is random | event-loop.spec.md | Minor UX |

---

## Critical Gaps (Spec Violations)

### 🔴 P0: Custom Backend Args Field Missing

**Spec:** cli-adapters.spec.md (lines 335-337)

- **Spec says:** Custom backends accept `args: ["--headless", "--json"]` configuration
- **Implementation:** `CliConfig` lacks `args` field, `CliBackend::custom()` initializes with empty vec
- **Location:** `crates/ralph-core/src/config.rs:547-571`, `crates/ralph-adapters/src/cli_backend.rs:108-114`

**Impact:** Users cannot pass custom arguments to proprietary/internal CLI tools.

---

### 🔴 P0: Custom Backend prompt_flag Field Missing

**Spec:** cli-adapters.spec.md (line 102)

- **Spec says:** Custom backends accept `prompt_flag: "--prompt"` configuration
- **Implementation:** `CliConfig` lacks `prompt_flag` field, hardcoded to `None`
- **Location:** `crates/ralph-core/src/config.rs:549-571`, `crates/ralph-adapters/src/cli_backend.rs:108-112`

**Impact:** Custom backends cannot use prompt flags other than positional arguments.

---

### 🔴 P0: Custom Backend Validation Missing

**Spec:** cli-adapters.spec.md (lines 340-341)

- **Spec says:** "an error indicates custom backend requires a command"
- **Implementation:** Falls back to `"echo"` instead of returning an error
- **Location:** `crates/ralph-adapters/src/cli_backend.rs:101`

**Impact:** Silent fallback instead of clear error message.

---

### 🔴 P0: Kiro Adapter Settings Missing

**Spec:** cli-adapters.spec.md (line 65, Quick Reference table)

- **Spec says:** All 5 backends (claude, gemini, kiro, codex, amp) should have adapter settings
- **Implementation:** `AdaptersConfig` only defines claude, gemini, codex, amp - no kiro field
- **Location:** `crates/ralph-core/src/config.rs:154-171`, `adapter_settings()` at line 386-394

**Impact:** Cannot configure kiro-specific timeout or enabled status.

---

## Missing Features (Spec Not Implemented)

### 🟡 P1: Interactive Idle Timeout Doesn't Reset on Activity

**Spec:** interactive-mode.spec.md (lines 155-159)

- **Acceptance criterion:** "timeout resets on... User input (any key forwarded to agent)"
- **Status:** `run_interactive` creates fixed timeout future; doesn't track `last_activity` like `run_observe`
- **Location:** `crates/ralph-adapters/src/pty_executor.rs:474-479`

**Impact:** Interactive sessions may timeout despite active user input.

---

### 🟡 P1: Per-Adapter Timeout Not Enforced

**Spec:** cli-adapters.spec.md (lines 359-361)

- **Acceptance criterion:** "adapters.claude.timeout: 60... Ralph sends SIGTERM and marks iteration as timed out"
- **Status:** Timeout configured in `AdapterSettings` but never read during execution
- **Location:** Timeout defined at `config.rs:178` but not used in `cli_executor.rs` or `pty_executor.rs`

**Impact:** Per-adapter timeouts have no effect; all adapters use default timeout.

---

### 🟡 P1: CLI Executor Working Directory Not Set

**Spec:** cli-adapters.spec.md (lines 365-372)

- **Acceptance criterion:** "agent's working directory is `/home/user/project/src`" (where ralph was invoked)
- **Status:** PTY executor sets `current_dir()` explicitly; CLI executor does not
- **Location:** `crates/ralph-adapters/src/cli_executor.rs:40-106` (no `current_dir()` call)

**Impact:** Autonomous mode agents may execute in unexpected working directory.

---

## Spec Improvements Needed

### event-loop.spec.md

**Issue:** Loop thrashing detection mechanism differs from spec

- **Spec says:** "same hat emits 3+ consecutive `build.blocked` events" triggers termination
- **Implementation:** Uses task-level redispatch counting instead of hat-level consecutive blocks
- **Suggestion:** Update spec to document actual behavior, which provides equivalent safety

**Issue:** Escape hatch instructions incomplete

- **Spec says:** Planner can mark tasks `[~]` with explanation
- **Implementation:** `build.task.abandoned` event exists but planner instructions don't explicitly mention `[~]` marking
- **Suggestion:** Add explicit instruction for planner to mark abandoned tasks as `[~]`

---

### cli-adapters.spec.md

**Issue:** Explicit backend validation not implemented

- **Spec says:** "error indicates Gemini was requested but not found" (line 325-327)
- **Implementation:** No validation that explicitly-selected backend exists before execution
- **Suggestion:** Add PATH check when backend is explicitly configured (not auto)

---

## By-Design Decisions (Not Bugs)

These issues were previously documented and confirmed as intentional per Ralph Tenets:

### 🟡 P1: Planner/Builder Behaviors Instruction-Only

Per **Ralph Tenets #2: "Backpressure Over Prescription"**:
> Don't prescribe how—create gates that reject bad work... Backpressure is enforceable; instructions are suggestions.

- Planner behaviors (gap analysis, scratchpad management, one-task-at-a-time) are instruction-only
- Builder behaviors (commit on success, mark [x], handle missing files) are instruction-only
- **Backpressure** (tests pass, lint pass, typecheck pass) IS enforced in `build.done` parsing

**No code changes needed** - this is the intended design.

### 🟢 P2: Scratchpad Persistence Not Verified

Orchestrator tells hats about scratchpad path but doesn't verify it exists or was updated. Works in practice because agents follow instructions. Low risk.

### 🟢 P2: Hat Display Order Random

`HashMap.keys()` iteration is non-deterministic. Cosmetic only.

---

## Specs Not Yet Implemented

These specs are in draft/review status and represent planned future work:

| Spec | Status | Purpose |
|------|--------|---------|
| behavioral-verification.spec.md | draft | Test catalog for all behaviors |
| test-tools.spec.md | review | VCR, mock, LLM-as-judge testing infrastructure |
| benchmark-harness.spec.md | — | Recording/replay for benchmarks |
| benchmark-tasks.spec.md | — | Benchmark task definitions |
| benchmark-ux.spec.md | — | Terminal capture for benchmarks |

These are NOT spec violations - they're planned features not yet built.

---

## Verification Summary

| Spec | Implementation | Notes |
|------|----------------|-------|
| event-loop.spec.md | 98% ✅ | All critical behaviors implemented |
| cli-adapters.spec.md | 75% ⚠️ | Custom backends incomplete |
| interactive-mode.spec.md | 95% ✅ | Idle timeout bug |
| terminal-ui.spec.md | 100% ✅ | Fully implemented |
| scaffolding.spec.md | 100% ✅ | Project structure complete |
| feature-parity.spec.md | — | Informational/migration guide |
| v1-v2-feature-parity.spec.md | — | Informational/migration guide |
| homebrew-tap.spec.md | — | External distribution |
