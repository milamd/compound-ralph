//! Integration tests for EventLoop with Ralph fallback.

use ralph_core::{EventLoop, RalphConfig};
use std::fs;
use tempfile::TempDir;

#[test]
fn test_orphaned_event_falls_to_ralph() {
    // Setup: Create a temp directory with .agent/events.jsonl
    let temp_dir = TempDir::new().unwrap();
    let agent_dir = temp_dir.path().join(".agent");
    fs::create_dir_all(&agent_dir).unwrap();
    
    let events_file = agent_dir.join("events.jsonl");
    
    // Write an orphaned event (no hat subscribes to "orphan.event")
    fs::write(
        &events_file,
        r#"{"topic":"orphan.event","payload":"This event has no subscriber","ts":"2026-01-14T12:00:00Z"}
"#,
    )
    .unwrap();
    
    // Create EventLoop with empty hat registry (no hats configured)
    let yaml = r#"
core:
  scratchpad: ".agent/scratchpad.md"
  specs_dir: "./specs"
  guardrails:
    - "Fresh context each iteration"
    - "Backpressure is law"
event_loop:
  completion_promise: "LOOP_COMPLETE"
  max_iterations: 10
  max_runtime_seconds: 300
"#;
    
    let config: RalphConfig = serde_yaml::from_str(yaml).unwrap();
    let mut event_loop = EventLoop::new(config);
    
    // Change to temp directory so EventReader finds the events file
    let original_dir = std::env::current_dir().unwrap();
    std::env::set_current_dir(temp_dir.path()).unwrap();
    
    // Process events from JSONL
    let has_orphans = event_loop.process_events_from_jsonl().unwrap();
    
    // Restore original directory
    std::env::set_current_dir(original_dir).unwrap();
    
    // Verify: Ralph should handle the orphaned event
    assert!(has_orphans, "Expected orphaned event to trigger Ralph");
}

#[test]
fn test_ralph_completion_only_from_ralph() {
    let yaml = r#"
core:
  scratchpad: ".agent/scratchpad.md"
  specs_dir: "./specs"
event_loop:
  completion_promise: "LOOP_COMPLETE"
  max_iterations: 10
"#;
    
    let config: RalphConfig = serde_yaml::from_str(yaml).unwrap();
    let event_loop = EventLoop::new(config);
    
    // Test: Ralph output with LOOP_COMPLETE should trigger completion
    let ralph_output = "All tasks complete.\n\nLOOP_COMPLETE";
    assert!(
        event_loop.check_ralph_completion(ralph_output),
        "Ralph should be able to trigger completion"
    );
    
    // Test: Any output with LOOP_COMPLETE should be detected
    let output_with_promise = "Some work done\nLOOP_COMPLETE\nMore text";
    assert!(
        event_loop.check_ralph_completion(output_with_promise),
        "LOOP_COMPLETE should be detected anywhere in output"
    );
    
    // Test: Output without LOOP_COMPLETE should not trigger
    let output_without_promise = "Some work done\nNo completion here";
    assert!(
        !event_loop.check_ralph_completion(output_without_promise),
        "Output without LOOP_COMPLETE should not trigger completion"
    );
}

#[test]
fn test_ralph_prompt_includes_core_behaviors() {
    let yaml = r#"
core:
  scratchpad: ".agent/scratchpad.md"
  specs_dir: "./specs"
  guardrails:
    - "Fresh context each iteration"
    - "Backpressure is law"
event_loop:
  completion_promise: "LOOP_COMPLETE"
"#;
    
    let config: RalphConfig = serde_yaml::from_str(yaml).unwrap();
    let event_loop = EventLoop::new(config);
    
    let prompt = event_loop.build_ralph_prompt("Test context");
    
    // Verify prompt includes core behaviors
    assert!(prompt.contains("You are Ralph"), "Prompt should identify Ralph");
    assert!(prompt.contains("CORE BEHAVIORS"), "Prompt should include core behaviors section");
    assert!(prompt.contains("Scratchpad:"), "Prompt should mention scratchpad");
    assert!(prompt.contains("Specs:"), "Prompt should mention specs");
    assert!(prompt.contains("Backpressure:"), "Prompt should mention backpressure");
    assert!(prompt.contains("LOOP_COMPLETE"), "Prompt should include completion promise");
}

#[test]
fn test_ralph_prompt_solo_mode() {
    let yaml = r#"
core:
  scratchpad: ".agent/scratchpad.md"
  specs_dir: "./specs"
event_loop:
  completion_promise: "LOOP_COMPLETE"
"#;
    
    let config: RalphConfig = serde_yaml::from_str(yaml).unwrap();
    let event_loop = EventLoop::new(config);
    
    let prompt = event_loop.build_ralph_prompt("");
    
    // In solo mode (no hats), Ralph should see SOLO MODE section
    assert!(prompt.contains("SOLO MODE"), "Solo mode should be indicated");
    assert!(prompt.contains("You're doing everything yourself"), "Solo mode instructions should be present");
    assert!(!prompt.contains("MULTI-HAT MODE"), "Multi-hat mode should not be present");
}

#[test]
fn test_ralph_prompt_multi_hat_mode() {
    let yaml = r#"
core:
  scratchpad: ".agent/scratchpad.md"
  specs_dir: "./specs"
hats:
  planner:
    name: "Planner"
    triggers: ["task.start"]
    publishes: ["build.task"]
  builder:
    name: "Builder"
    triggers: ["build.task"]
    publishes: ["build.done"]
event_loop:
  completion_promise: "LOOP_COMPLETE"
"#;
    
    let config: RalphConfig = serde_yaml::from_str(yaml).unwrap();
    let event_loop = EventLoop::new(config);
    
    let prompt = event_loop.build_ralph_prompt("");
    
    // In multi-hat mode, Ralph should see hat topology
    assert!(prompt.contains("MULTI-HAT MODE"), "Multi-hat mode should be indicated");
    assert!(prompt.contains("MY TEAM"), "Hat team table should be present");
    assert!(prompt.contains("Planner"), "Planner hat should be listed");
    assert!(prompt.contains("Builder"), "Builder hat should be listed");
    assert!(!prompt.contains("SOLO MODE"), "Solo mode should not be present");
}
