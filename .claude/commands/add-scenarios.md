---
description: Add scenarios to feature file or rule
allowed-tools: Read, Edit, Grep, mcp__jetbrains__get_all_open_file_paths
---

Add Gherkin Scenario statements to a feature file or rule to describe specific test cases and behaviors.

Usage:
- `/add-scenarios` - Suggest and add plausible scenarios for the currently open feature file (analyzes feature/rule context)
- `/add-scenarios <scenario_description>` - Add a specific scenario based on the provided description text

## Instructions

### Mode 1: Without Parameter (Suggest Scenarios)

When called without parameters, analyze the feature/rule and suggest relevant scenarios:

1. **Identify the target file:**
   - Get the currently open file
   - Read the entire feature file

2. **Analyze the context:**
   - Determine cursor position or last edit location
   - Identify if cursor is within a Rule block or at feature level
   - Extract the feature name and user story (if present)
   - If under a Rule: extract the rule description
   - Look at existing scenarios to avoid duplication

3. **Extrapolate scenarios:**
   Based on the feature/rule description, suggest 2-5 plausible scenarios that:
   - Test different aspects or variations of the behavior
   - Cover happy path, edge cases, and error conditions
   - Follow naming pattern: clear, descriptive, lowercase with spaces
   - Are specific and testable
   - Complement existing scenarios (don't duplicate)

   Naming patterns:
   - Happy path: "successful operation", "valid input", "basic workflow"
   - Edge cases: "empty input", "maximum length", "boundary values"
   - Error cases: "invalid input", "missing required field", "unauthorized access"
   - Variations: "with optional parameter", "without authentication", "when disabled"

4. **Format the scenarios:**
   - Each scenario as "Scenario: [description]" or "Scenario Outline: [description]" if parameterized
   - Proper indentation:
     - 2 spaces for feature-level scenarios
     - 4 spaces for rule-level scenarios
   - Blank line before each scenario
   - Leave scenario body empty (no steps yet)

5. **Insert the scenarios:**
   - **If under a Rule**: Insert after the rule statement, before next rule or end of file
   - **If at feature level**: Insert after feature header/rules, before end of file
   - Leave blank lines for proper spacing
   - Use Edit tool to insert

### Mode 2: With Parameter (Add Specific Scenario)

When called with a scenario description parameter:

1. **Parse the scenario description:**
   - Extract the key behavior/condition from the provided text
   - Identify if it should be a regular Scenario or Scenario Outline
   - Clean up and format the description (lowercase, concise)

2. **Formulate as Gherkin Scenario:**
   - Create proper "Scenario: " or "Scenario Outline: " statement
   - Keep description concise (typically 3-8 words)
   - Use lowercase with spaces (Gherkin convention)
   - Example: "Scenario: with valid authentication credentials"

3. **Determine insertion point:**
   - **If cursor position is available**: Use the cursor location
   - **Check context**: Determine if inserting under a Rule or at feature level
   - **Check legality**: Ensure insertion point is valid for Gherkin:
     - ✓ After feature/ability header
     - ✓ After a rule statement (becomes rule-level scenario)
     - ✓ Between existing scenarios
     - ✗ NOT inside another scenario (between steps)
     - ✗ NOT inside a background block
     - ✗ NOT inside an examples block
   - **If position is illegal**: Find nearest legal position (after current scenario block, or end of file)

4. **Insert the scenario:**
   - Add blank line before (if not already present)
   - Insert "Scenario: " statement with proper indentation
   - Leave body empty (no steps yet - use /add-steps to add steps)
   - Add blank line after
   - Use Edit tool

### Gherkin Structure Reference

Valid positions for Scenario insertion:
```
Ability: ...              ← Feature header
  [user story]
                          ← ✓ VALID (feature-level scenario)
  Scenario: existing      ← Feature-level scenario
    Given ...             ← Steps
                          ← ✗ INVALID (inside scenario)

                          ← ✓ VALID (between scenarios)
  Rule: business rule     ← Rule block
                          ← ✓ VALID (rule-level scenario)
    Scenario: under rule  ← Rule-level scenario
      Given ...           ← Steps
                          ← ✗ INVALID (inside scenario)

                          ← ✓ VALID (between scenarios)
  Scenario: another one   ← Feature-level scenario
    Given ...

                          ← ✓ VALID (end of file)
```

### Output Format

**For Mode 1 (Suggest Scenarios):**
- List suggested scenarios with brief reasoning
- Explain which scenarios cover which aspects (happy path, edge cases, etc.)

**For Mode 2 (Add Specific Scenario):**
- Show the formulated scenario statement
- Report insertion location (line number)
- Indicate if it's feature-level or rule-level
- Suggest using /add-steps to add steps to the scenario

## Examples

### Example 1: Suggest Scenarios (No Parameter)

Feature file content:
```
Ability:
  As a developer writing BDD specifications
  I want to fold code blocks in the editor
  So that I can focus on specific sections

  Rule: activating fold should collapse the entire code block
```

Cursor position: After the Rule statement (line 6)

Generated scenarios (rule-level):
```
    Scenario: folding a single scenario

    Scenario: folding nested rules

    Scenario: folding with multiple scenarios under rule

    Scenario: unfolding preserves original state
```

### Example 2: Suggest Scenarios at Feature Level

Feature file content:
```
Ability:
  As a user
  I want to authenticate
  So that I can access protected resources
```

Generated scenarios (feature-level):
```
  Scenario: successful login with valid credentials

  Scenario: failed login with invalid password

  Scenario: failed login with non-existent user

  Scenario: session timeout after inactivity
```

### Example 3: Add Specific Scenarios (With Parameter)

Input: `/add-scenarios the button should be disabled when no text is selected`

Context: Cursor at feature level

Generated:
```
  Scenario: button disabled when no text selected
```

### Example 4: Add Scenario Outline

Input: `/add-scenarios test with different valid input formats`

Generated:
```
  Scenario Outline: with different valid input formats
    Examples:
      | input |
```

## Quality Checklist

Ensure scenarios:
- [ ] Have clear, descriptive names (3-8 words typically)
- [ ] Use lowercase with spaces (Gherkin convention)
- [ ] Are properly indented (2 spaces for feature-level, 4 spaces for rule-level)
- [ ] Have blank lines before and after
- [ ] Are inserted at legal Gherkin positions
- [ ] Don't duplicate existing scenarios
- [ ] Test specific, distinct behaviors
- [ ] Follow the Given-When-Then pattern (when steps are added)
- [ ] Are focused on business behavior, not implementation details

## Notes

- Scenarios are created without steps initially
- Use `/add-steps` command to add appropriate steps to the scenario
- Scenario Outline should be used when testing the same behavior with different data sets
- Keep scenario names focused on "what" is being tested, not "how" it's tested