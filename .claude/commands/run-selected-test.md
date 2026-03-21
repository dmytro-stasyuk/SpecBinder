---
description: Run the test method or class currently selected in the IntelliJ editor
---

Run the test at the current cursor position in IntelliJ IDEA's run window.

## Steps to follow:

1. **Execute the trigger script** by running:
   ```
   .idea_scripts/trigger_run_test_shortcut.sh
   ```
   This script activates IntelliJ, focuses the editor (via Alt+Shift+Cmd+F), then sends Ctrl+Shift+R to run the test at the cursor.

2. **Report to the user** that the test has been triggered in IntelliJ's run window.
