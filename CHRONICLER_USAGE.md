# Using the Chronicler Hat for Compounding

## Overview

The Chronicler Hat implements "compounding" in the Ralph Orchestrator framework. It serves as the final authority in a loop, performing post-mortem analysis and updating the project's permanent memory after successful missions.

## Quick Start

### Method 1: Use the Preset

```bash
# Initialize with chronicler-enabled workflow
ralph init --preset with-chronicler

# Run your task
ralph run --prompt "Add user authentication system"
```

### Method 2: Add to Existing Configuration

Add the Chronicler hat to your existing `ralph.yml`:

```yaml
hats:
  # ... your existing hats ...
  
  chronicler:
    name: "📚 Chronicler"
    description: "Performs post-mortem analysis and updates permanent memory after successful missions"
    triggers: ["test.passed", "review.approved", "LOOP_COMPLETE"]
    publishes: ["chronicle.complete"]
    instructions: |
      ## CHRONICLER MODE - COMPOUNDING STEP
      [Full instructions from chronicler.hat.md...]
```

### Method 3: Use Built Binary

```bash
# Use the current ralph.yml (now includes Chronicler)
/Users/dougmilam/GitHub/ralph-orchestrator/target/release/ralph run --prompt "Add user authentication"
```

This uses the confession workflow with Chronicler as the final step:
- Builder → Confessor → Confession Handler → LOOP_COMPLETE → Chronicler

## What Chronicler Does

The Chronicler hat performs post-mortem analysis and memory compounding when missions complete successfully:

1. **Triggers on Success**: Only activates on success events like `confession.clean`, `test.passed`, `review.approved`, and `LOOP_COMPLETE`
2. **Analyzes Results**: Reviews git.diff, mission logs, and existing memories
3. **Extracts Learnings**: Identifies patterns, decisions, fixes, and context
4. **Compounds Memory**: Updates permanent memory using `ralph tools memory add`
5. **Never Modifies Code**: Strictly analysis-only, no implementation changes
6. **Ensures Continuous Improvement**: Through knowledge accumulation

## Success-Based Triggering

Since Ralph doesn't have a built-in "missions with conditions" system, the Chronicler achieves success-only execution through strategic event triggering:

### Trigger Events

The Chronicler triggers on success events only:

- **`test.passed`** - All tests are green, functionality verified
- **`review.approved`** - Code quality checks passed  
- **`LOOP_COMPLETE`** - Successful mission completion
- **`confession.clean`** - Confession analysis passed
- **`build.done`** - Successful compilation and basic checks

### What It Ignores

The Chronicler deliberately does NOT trigger on:

- `test.failed` - Tests failed, nothing to compound from failure
- `review.rejected` - Code needs changes, not ready for compounding
- `build.blocked` - Implementation blocked, incomplete work

### Event Flow Examples

#### Successful Mission Flow
```
task.start → architect → plan.ready → builder → build.done → tester → test.passed → chronicler → chronicle.complete
```

#### Failed Mission Flow (No Chronicler)
```
task.start → architect → plan.ready → builder → build.done → tester → test.failed → [back to builder]
```

#### Confession Workflow Flow
```
Builder → Confessor → Confession Handler → LOOP_COMPLETE → Chronicler
```

## Integration Patterns

### 1. Pipeline Pattern (Most Common)

Linear flow where Chronicler runs last:

```yaml
event_loop:
  starting_event: "task.start"

hats:
  planner:
    triggers: ["task.start"]
    publishes: ["plan.ready"]
    
  implementer:
    triggers: ["plan.ready"]
    publishes: ["build.done"]
    
  verifier:
    triggers: ["build.done"]
    publishes: ["test.passed", "test.failed"]
    
  chronicler:
    triggers: ["test.passed"]  # Only on success
    publishes: ["LOOP_COMPLETE"]
```

### 2. Supervisor-Worker Pattern

Multiple specialists feeding into Chronicler:

```yaml
hats:
  frontend_worker:
    triggers: ["task.start"]
    publishes: ["feature.done"]
    
  backend_worker:
    triggers: ["task.start"]
    publishes: ["api.done"]
    
  chronicler:
    triggers: ["feature.done", "api.done"]  # Multiple success paths
    publishes: ["LOOP_COMPLETE"]
```

### 3. Quality Gate Pattern

Multiple quality checks before Chronicler:

```yaml
hats:
  builder:
    triggers: ["task.start"]
    publishes: ["build.ready"]
    
  tester:
    triggers: ["build.ready"]
    publishes: ["test.results"]
    
  reviewer:
    triggers: ["test.results"]
    publishes: ["review.approved", "review.rejected"]
    
  chronicler:
    triggers: ["review.approved"]  # Only after full quality approval
    publishes: ["LOOP_COMPLETE"]
```

## Memory Categories Used

The Chronicler categorizes insights into four memory types:

### Patterns
- Approaches that work well
- Successful techniques
- Reusable solutions
- Best practices discovered

### Decisions
- Architectural choices
- Implementation trade-offs
- Technology selections
- Design rationale

### Fixes
- Problems encountered
- Debugging solutions
- Bug resolutions
- Workarounds used

### Context
- Project-specific knowledge
- Codebase characteristics
- Integration patterns
- Environmental notes

## Best Practices

### 1. Event Design
- Use specific success events (`test.passed`) vs generic (`build.done`)
- Ensure failed paths emit different events than success paths
- Make Chronicler triggers exclusive to success conditions

### 2. Memory Quality
- Be specific about what worked and why
- Include context for future reference
- Categorize correctly for retrieval
- Avoid duplicating existing memories

### 3. Hat Ordering
- Place Chronicler last in hat definitions
- Ensure all quality gates precede it
- Don't give it work that could fail

### 4. Constraint Enforcement
- Chronicler should never modify code
- Focus only on analysis and memory updates
- Use success events as gating mechanism
- Emit completion events after memory updates

## Verification

```bash
# List hats - you should see Chronicler
ralph hats list

# Validate configuration
ralph hats validate
```

## Troubleshooting

### Chronicler Never Activates
- Check that preceding hats emit success events
- Verify event names match triggers exactly
- Ensure no intermediate failures are blocking flow

### Chronicler Activates on Failures
- Review event flow for leaked failure events
- Check that failure paths emit different events
- Add more specific trigger patterns if needed

### Memory Not Persisting
- Verify `ralph tools memory add` commands are correct
- Check memory system is enabled in config
- Ensure proper categorization with `-t` flag

## Example Session

```bash
# Start a feature with chronicler
ralph run --config presets/with-chronicler.yml --prompt "Add password reset"

# Session events:
# 1. architect creates plan
# 2. builder implements feature  
# 3. tester verifies functionality
# 4. chronicler activates on test.passed
# 5. chronicler analyzes git.diff and logs
# 6. chronicler adds memories:
#    - Pattern: Used email service for notifications
#    - Decision: Chose token-based reset for security
#    - Fix: Added rate limiting to prevent abuse
# 7. chronicler emits chronicle.complete
# 8. LOOP_COMPLETE
```

The result is a completed feature AND compounded learnings for future sessions.

The Chronicler ensures your project learns from every successful mission, building a knowledge base over time.