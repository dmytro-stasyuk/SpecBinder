---
description: Add an entry to the CHANGELOG.md file
allowed-tools: Read, Edit
---

Add a changelog entry to the `## Unreleased` section of `CHANGELOG.md`.

**CRITICAL: Only the `## Unreleased` section is editable.** Never modify, reword, rename, or "correct" an entry grouped under a past/already-released version heading (e.g. `## [2026.42.0]`) — those entries are an immutable historical record of what actually shipped, even when later refactoring makes the wording technically inaccurate (e.g. an API was renamed afterwards). When a change (including a rename or correction of something that shipped in a prior release) needs a note, add a NEW entry under `## Unreleased`.

Usage:
- `/changelog` - Add an entry about the most recent change in the conversation (infer from context)
- `/changelog <description>` - Add an entry under the appropriate category (Added/Changed/Fixed/Removed)
- `/changelog Added: <description>` - Add under a specific category
- `/changelog Fixed: <description>` - Add under a specific category

## Instructions

1. **If no description provided**, infer the changelog entry from the most recent change or task discussed in the conversation. Look at what was just implemented, fixed, or modified and summarize it appropriately.

2. **Read `CHANGELOG.md`** to see the current content

3. **Determine the category** from the description or explicit prefix:
   - **Added** - new features or capabilities
   - **Changed** - modifications to existing behavior
   - **Fixed** - bug fixes
   - **Removed** - removed features or capabilities
   - If a prefix like `Added:`, `Changed:`, `Fixed:`, or `Removed:` is provided, use that category and strip the prefix from the entry text
   - If no prefix, infer the best category from the description

4. **Polish the wording** before inserting:
   - The user's input may be rough/blunt — rewrite it into clear, concise, end-user-friendly language
   - Use consistent tone matching existing changelog entries
   - Start with a verb or noun phrase (e.g., "Support for...", "Switched from...", "Fixed incorrect...")
   - Keep it to one line where possible

5. **Flag breaking API changes prominently.** If the change breaks source/binary compatibility for client projects — e.g. a renamed/removed/relocated public annotation, a renamed/removed public type or method, a changed annotation parameter, or any change that requires consumers to edit their code — prefix the entry text with **`**⚠️ BREAKING:** `** (the bold marker, then a space, then the description). The entry still goes under its normal `### Added` / `### Changed` / `### Removed` category; the prefix just makes it stand out. Non-breaking entries get no prefix. When in doubt about whether a change is breaking, ask the user.

6. **Insert the entry** under the correct `### Category` heading within `## Unreleased`:
   - Format as `- <description>` (single dash, one space, then text), with the optional `**⚠️ BREAKING:** ` prefix immediately after the `- `
   - Place after any existing entries in that category
   - If the category heading has no entries yet, place on the blank line directly after the heading

7. **Stage the file** with `git add CHANGELOG.md`

## Examples

`/changelog Support for DataTable parameters in step methods`
Result: adds `- Support for DataTable parameters in step methods` under `### Added`

`/changelog Fixed: Incorrect escaping of backslashes in generated code`
Result: adds `- Incorrect escaping of backslashes in generated code` under `### Fixed`

`/changelog Changed: Switched from JUnit 5.10 to 5.14`
Result: adds `- Switched from JUnit 5.10 to 5.14` under `### Changed`

`/changelog Changed: Renamed the @JUnitInject annotation to @JUnitResolved`
Result (breaking — requires consumers to update their code): adds `- **⚠️ BREAKING:** Renamed the @JUnitInject annotation to @JUnitResolved ...` under `### Changed`
