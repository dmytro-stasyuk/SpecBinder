---
description: Add suitable Gherkin steps to selected scenario
allowed-tools: Read, Edit, Grep
---

Add appropriate Gherkin steps to an empty scenario based on:
1. The scenario name and context
2. Similar scenarios in the same feature file
3. Common step patterns from other feature files
4. Available step definitions in the codebase

Usage:
- `/add-steps` - Add steps to the currently selected scenario (line {{SELECTION_START}})
- `/add-steps <line_number>` - Add steps to the scenario in currently open file on <line_number>

## Instructions

1. **Identify the target scenario:**
   - Use the provided file path and line number, OR
   - Use the current selection if no arguments provided
   - Read the feature file and locate the empty scenario

2. **Analyze the scenario context:**
   - Extract the scenario name (e.g., "with rule level scenarios only")
   - Check if it's under a Rule block
   - Look at similar completed scenarios in the same file
   - Understand what the scenario is testing based on its name

3. **Find similar scenarios:**
   - Look at other scenarios in the same feature file
   - Identify the pattern of steps they use

5. **Insert the steps:**
   - Use the Edit tool to add the generated steps
   - Maintain proper indentation (2 spaces for steps under a scenario)
   - Add a blank line after the scenario if needed

