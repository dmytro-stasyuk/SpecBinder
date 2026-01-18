---
description: Add business rules to feature file
allowed-tools: Read, Edit, Grep, mcp__jetbrains__get_all_open_file_paths
---

Add Gherkin Rule statements to a feature file to describe business rules and behaviors.

Usage:
- `/add-rule` - Suggest and add plausible business rules for the currently open feature file (analyzes feature header/description)
- `/add-rule <rule_description>` - Add a specific rule based on the provided description text

## Instructions

### Mode 1: Without Parameter (Suggest Rules)

When called without parameters, analyze the feature and suggest relevant business rules:

1. **Identify the target file:**
   - Get the currently open file
   - Read the entire feature file

2. **Analyze the feature:**
   - Extract the feature name from the "Ability:" or "Feature:" line
   - Read the user story (As a... I want... So that...)
   - Understand the feature's purpose and scope
   - Look at existing scenarios if any (to avoid duplicating what's already covered)

3. **Extrapolate business rules:**
   Based on the feature description, suggest 2-6 plausible business rules that:
   - Cover different aspects or behaviors of the feature
   - Are testable and specific
   - Follow the pattern: "Rule: [when/if condition], [expected behavior/outcome]"
   - Focus on business logic, edge cases, validation, or user workflows

   Examples:
   - For a folding feature: "Rule: triggering fold action should collapse all visible scenarios"
   - For a validation feature: "Rule: invalid syntax should display error markers in real-time"
   - For a search feature: "Rule: search should be case-insensitive by default"

4. **Format the rules:**
   - Each rule on its own line with "Rule: " prefix
   - Multi-line rules: continuation lines start with "- " (dash + space) for distinct aspects
   - Proper indentation (2 spaces for rules at feature level)
   - Blank line before and after the rule block

5. **Insert the rules:**
   - Insert after the user story section (Ability block)
   - Before any existing scenarios
   - Leave blank lines for proper spacing
   - Use Edit tool to insert

### Mode 2: With Parameter (Add Specific Rule)

When called with a rule description parameter:

1. **Parse the rule description:**
   - Extract the key concept/behavior from the provided text
   - Identify conditions, actions, and expected outcomes

2. **Formulate as Gherkin Rule:**
   - Create proper "Rule: " statement
   - If description is long or multi-faceted, split into:
     - Main rule line: "Rule: [primary behavior]"
     - Continuation lines: "  - [aspect 1]", "  - [aspect 2]"
   - Keep it concise and testable

3. **Determine insertion point:**
   - **If cursor position is available**: Use the cursor location (from selection or last edit)
   - **Check legality**: Ensure insertion point is valid for Gherkin:
     - ✓ After feature/ability header
     - ✓ After another rule (before its scenarios)
     - ✓ Between scenarios at feature level
     - ✗ NOT inside a scenario (between steps)
     - ✗ NOT inside a background block
     - ✗ NOT inside an examples block
   - **If position is illegal**: Find nearest legal position (after current scenario, or end of file)

4. **Insert the rule:**
   - Add blank line before (if not already present)
   - Insert "Rule: " statement with proper indentation
   - Add blank line after
   - Use Edit tool

### Gherkin Structure Reference

Valid positions for Rule insertion:
```
Ability: ...              ← Feature header
  [user story]
                          ← ✓ VALID (after feature header)
  Rule: existing rule     ← Feature-level rule
    Scenario: ...         ← Scenario under rule
      Given ...           ← Steps
                          ← ✗ INVALID (inside scenario)

                          ← ✓ VALID (between scenarios)
  Scenario: ...           ← Feature-level scenario
    Given ...
                          ← ✗ INVALID (inside scenario)

                          ← ✓ VALID (end of file)
```

### Output Format

**For Mode 1 (Suggest Rules):**
- Explain the reasoning for each rule

**For Mode 2 (Add Specific Rule):**
- Show the formulated rule statement
- Report insertion location (line number)

## Examples

### Example 1: Suggest Rules (No Parameter)

Feature file content:
```
Ability:
  As a developer writing BDD specifications
  I want to fold code blocks in the editor
  So that I can focus on specific sections
```

Generated rules:
```
  Rule: activating fold should collapse the entire code block including all child elements

  Rule: unfolding should restore the full content and maintain cursor position

  Rule: nested folds should be supported with independent collapse/expand states
```

### Example 2: Add Specific Rule (With Parameter)

Input: `/add-rule the button should be disabled when no text is selected`

Generated:
```
  Rule: the button should be disabled when no text is selected
```

### Example 3: Multi-line Rule

Input: `/add-rule validation should check syntax errors and highlight them with red underlines and show error messages on hover and update in real-time as user types`

Generated:
```
  Rule: validation should provide comprehensive error feedback
    - syntax errors highlighted with red underlines
    - error messages displayed on hover
    - real-time validation as user types
```

## Quality Checklist

Ensure rules:
- [ ] Are specific and testable
- [ ] Use clear, simple language
- [ ] Focus on one behavior or constraint per rule
- [ ] Are properly indented (2 spaces for feature-level rules)
- [ ] Have blank lines before and after
- [ ] Are inserted at legal Gherkin positions
- [ ] Don't duplicate existing rules
- [ ] Align with the feature's purpose
