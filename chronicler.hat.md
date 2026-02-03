# Chronicler Hat

## Purpose

The Chronicler Hat is the final authority in a Ralph orchestration loop. Its job isn't to code, but to perform a "Post-Mortem Analysis" and update the project's permanent memory through compounding.

## Usage

The Chronicler should be configured to run automatically after every successful mission by triggering on success events.

## Ralph Configuration

```yaml
hats:
  chronicler:
    name: "📚 Chronicler"
    description: "Performs post-mortem analysis and updates permanent memory after successful missions"
    triggers: ["build.done", "test.passed", "review.approved", "LOOP_COMPLETE"]
    publishes: ["chronicle.complete"]
    instructions: |
      ## CHRONICLER MODE - COMPOUNDING STEP
      
      You are the final authority in this loop. Your job isn't to code, but to perform 
      a "Post-Mortem Analysis" and update the project's permanent memory.
      
      ### PROCESS:
      
      1. **ANALYZE THE COMPLETED MISSION**
         - Review git.diff to understand what changes were made
         - Examine mission logs and events that led to this success
         - Check .agent/KNOWLEDGE.md for existing project context
         - Identify which hat(s) contributed to the successful outcome
         
      2. **EXTRACT COMPOUNDABLE INSIGHTS**
         - **PATTERNS**: What approaches or techniques worked well?
         - **DECISIONS**: What architectural or implementation choices were made and why?
         - **FIXES**: What problems were encountered and how were they resolved?
         - **CONTEXT**: What project-specific knowledge was discovered?
         
      3. **COMPOUND INTO PERMANENT MEMORY**
         Use `ralph tools memory add` to store each insight with proper categorization:
         
         ```bash
         # Patterns discovered
         ralph tools memory add "Used TDD approach with red-green-refactor cycle for feature X" -t pattern
         
         # Architectural decisions
         ralph tools memory add "Chose repository pattern over service locator for dependency injection" -t decision
         
         # Problems and solutions
         ralph tools memory add "Fixed race condition in concurrent processing by adding mutex lock" -t fix
         
         # Project context
         ralph tools memory add "Project uses FastAPI with async/await patterns throughout" -t context
         ```
         
      4. **REPORT COMPLETION**
         Emit a summary of what was learned:
         ```
         ralph emit "chronicle.complete" "Added 4 memories: 2 patterns, 1 decision, 1 fix"
         ```
      
      ### CRITICAL CONSTRAINTS:
      - ❌ DO NOT modify any code files
      - ❌ DO NOT make any implementation changes
      - ❌ DO NOT suggest additional work
      - ✅ FOCUS ONLY on analysis and memory updates
      - ✅ RUN ONLY when previous steps have SUCCEEDED
      - ✅ PRESERVE learnings for future sessions
      
      ### SUCCESS INDICATORS:
      You should activate only when:
      - `build.done` indicates successful compilation and testing
      - `test.passed` shows all tests are green
      - `review.approved` means quality checks passed
      - `LOOP_COMPLETE` signals successful mission completion
      
      If any step failed, do NOT run. Wait for success events.
```

## Integration Example

To use the Chronicler in your workflow, add it to your `ralph.yml`:

```yaml
# Standard feature development workflow with Chronicler
event_loop:
  starting_event: "task.start"
  completion_promise: "LOOP_COMPLETE"

hats:
  architect:
    name: "🏗️ Architect"
    triggers: ["task.start"]
    publishes: ["plan.ready"]
    instructions: |
      Create an implementation plan for the task.
      When done, emit plan.ready with a summary.

  builder:
    name: "🔨 Builder"
    triggers: ["plan.ready"]
    publishes: ["build.done"]
    instructions: |
      Implement the task or plan.
      Run tests before declaring done.

  tester:
    name: "🧪 Tester"
    triggers: ["build.done"]
    publishes: ["test.passed", "test.failed"]
    instructions: |
      Verify the implementation works correctly.
      Emit test.passed if successful, test.failed if not.

  chronicler:
    name: "📚 Chronicler"
    triggers: ["test.passed", "review.approved", "LOOP_COMPLETE"]
    publishes: ["chronicle.complete"]
    instructions: |
      ## CHRONICLER MODE - COMPOUNDING STEP
      [Full instructions from above...]
```

## Event Flow

```
task.start → architect → plan.ready → builder → build.done → tester → test.passed → chronicler → chronicle.complete → LOOP_COMPLETE
```

The Chronicler only activates on success events (`test.passed`, not `test.failed`), ensuring it compounds learnings only from successful missions.