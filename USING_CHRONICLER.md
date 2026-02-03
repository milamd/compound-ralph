# Using the Built Ralph with Chronicler Hat

## Quick Start

Your new Ralph binary includes the Chronicler hat implementation. Here's how to use it:

### Method 1: Use the Updated Main Config

```bash
# Use the current ralph.yml (now includes Chronicler)
/Users/dougmilam/GitHub/ralph-orchestrator/target/release/ralph run --prompt "Add user authentication"
```

This will use the confession workflow with Chronicler as the final step:
- Builder → Confessor → Confession Handler → LOOP_COMPLETE → Chronicler

### Method 2: Use the Chronicler Preset

```bash
# Initialize a new config with chronicler workflow
/Users/dougmilam/GitHub/ralph-orchestrator/target/release/ralph init --preset with-chronicler

# Run with the new config
/Users/dougmilam/GitHub/ralph-orchestrator/target/release/ralph run --prompt "Build a REST API"
```

## What's Chronicler Does

The Chronicler hat now performs post-mortem analysis and memory compounding when missions complete successfully:

1. **Triggers on Success**: Only activates on `confession.clean` and `LOOP_COMPLETE`
2. **Analyzes Results**: Reviews git.diff, mission logs, and existing memories
3. **Extracts Learnings**: Identifies patterns, decisions, fixes, and context
4. **Compounds Memory**: Updates permanent memory using `ralph tools memory add`
5. **Never Modifies Code**: Strictly analysis-only, no implementation changes
6. **Ensures Continuous Improvement**: Through knowledge accumulation

## Verification

```bash
# List hats - you should see Chronicler
/Users/dougmilam/GitHub/ralph-orchestrator/target/release/ralph hats list

# Validate configuration
/Users/dougmilam/GitHub/ralph-orchestrator/target/release/ralph hats validate
```

## Example Workflow

```bash
# Run a confession-driven development session with compounding
/Users/dougmilam/GitHub/ralph-orchestrator/target/release/ralph run --prompt "Add password reset feature"

# Event flow:
# 1. Builder implements the feature
# 2. Confessor analyzes and finds it clean
# 3. Confession Handler verifies success
# 4. Chronicler performs post-mortem and compounds learnings
# 5. LOOP_COMPLETE
```

The Chronicler ensures your project learns from every successful mission, building a knowledge base over time.