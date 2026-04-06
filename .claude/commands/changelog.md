---
description: Add an entry to the CHANGELOG.md file
allowed-tools: Read, Edit
---

Add a changelog entry to the `## Unreleased` section of `CHANGELOG.md`.

Usage:
- `/changelog <description>` - Add an entry under the appropriate category (Added/Changed/Fixed/Removed)
- `/changelog Added: <description>` - Add under a specific category
- `/changelog Fixed: <description>` - Add under a specific category

## Instructions

1. **Read `CHANGELOG.md`** to see the current content

2. **Determine the category** from the description or explicit prefix:
   - **Added** - new features or capabilities
   - **Changed** - modifications to existing behavior
   - **Fixed** - bug fixes
   - **Removed** - removed features or capabilities
   - If a prefix like `Added:`, `Changed:`, `Fixed:`, or `Removed:` is provided, use that category and strip the prefix from the entry text
   - If no prefix, infer the best category from the description

3. **Polish the wording** before inserting:
   - The user's input may be rough/blunt — rewrite it into clear, concise, end-user-friendly language
   - Use consistent tone matching existing changelog entries
   - Start with a verb or noun phrase (e.g., "Support for...", "Switched from...", "Fixed incorrect...")
   - Keep it to one line where possible

4. **Insert the entry** under the correct `### Category` heading within `## Unreleased`:
   - Format as `- <description>` (single dash, one space, then text)
   - Place after any existing entries in that category
   - If the category heading has no entries yet, place on the blank line directly after the heading

5. **Stage the file** with `git add CHANGELOG.md`

## Examples

`/changelog Support for DataTable parameters in step methods`
Result: adds `- Support for DataTable parameters in step methods` under `### Added`

`/changelog Fixed: Incorrect escaping of backslashes in generated code`
Result: adds `- Incorrect escaping of backslashes in generated code` under `### Fixed`

`/changelog Changed: Switched from JUnit 5.10 to 5.14`
Result: adds `- Switched from JUnit 5.10 to 5.14` under `### Changed`
