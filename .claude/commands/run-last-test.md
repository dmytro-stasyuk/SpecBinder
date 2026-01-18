---
description: Execute the last run test via IntelliJ IDEA and inspect results
---

Execute the most recently run test configuration using IntelliJ IDEA's run window and analyze the results.

## Steps to follow:

1. **Get available run configurations** using `mcp__jetbrains__get_run_configurations`

2. **Identify the relevant test** to run:
   - run the last executed test configuration
   - do not run 'AllTests' configuration unless explicitly requested
   - If context is unclear, ask the user which test configuration to execute

3. **Execute the test** using `mcp__jetbrains__execute_run_configuration` with:
   - `configurationName`: the identified test configuration
   - `timeout`: 60000 (60 seconds, adjust if needed for longer tests)
   - `maxLinesCount`: 1000 (adjust if needed)

4. **Analyze the results**:
   - Check if the test passed or failed
   - If failed, identify which scenarios/tests failed
   - Examine error messages and stack traces
   - Look for compilation errors, assertion failures, or runtime exceptions
   - Summarize the findings for the user

5. **Provide actionable feedback**:
   - Report pass/fail status
   - Highlight specific failures with line numbers if available
   - Suggest next steps if there are failures