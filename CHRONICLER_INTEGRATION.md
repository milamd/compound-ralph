# Event Flow with Chronicler Integration

## Current Event Flow

```
task.start → build.task → Builder → build.done → Confessor → confession.clean → Confession Handler → LOOP_COMPLETE → Chronicler → chronicle.complete
```

## Success Event Path

The Chronicler is now properly integrated to receive success events:

1. **Builder** completes implementation → emits `build.done`
2. **Confessor** analyzes work → emits `confession.clean` (only on success)
3. **Confession Handler** verifies clean confession → emits `LOOP_COMPLETE`
4. **Chronicler** triggers on `LOOP_COMPLETE` and `confession.clean` → performs compounding
5. **Chronicler** emits `chronicle.complete`

## Event Details

### Chronicler Triggers
- `confession.clean` - Indicates successful confession-driven development cycle
- `LOOP_COMPLETE` - Final success signal from Confession Handler

### Chronicler Actions
- Analyzes git.diff and mission logs
- Extracts patterns, decisions, fixes, and context
- Adds categorized memories using `ralph tools memory add`
- Emits `chronicle.complete` with summary

## Failure Path (No Chronicler)

```
task.start → build.task → Builder → build.done → Confessor → confession.issues_found → Confession Handler → build.task (loop continues)
```

The Chronicler deliberately does NOT trigger on:
- `confession.issues_found` - Problems found, needs more work
- `build.blocked` - Implementation blocked

This ensures compounding only happens after successful missions.