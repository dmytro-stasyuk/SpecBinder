# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**spec2junit** is a compile-time code generator that converts natural-language behavior specifications (Gherkin/JBehave) into pure JUnit 5 test code. It eliminates runtime step discovery and regex glue patterns by generating strongly-typed Java test classes during compilation via annotation processing.

**Key principles:**
- Compile-time safety: Undefined steps become compiler errors, not runtime failures
- No regex glue: Eliminates brittle annotation patterns
- Plain JUnit 5: No custom test runners required
- Per-feature steps: No global step library to avoid ambiguity

## Build Commands

**IMPORTANT: Running Tests**
- **Use a hybrid approach** to ensure reliable test execution:
  1. **First**, trigger a full project rebuild using the rebuild script
  2. **Then**, execute tests using IntelliJ IDEA's MCP server tools
- This two-step approach is necessary because IntelliJ's automatic build is asynchronous - running tests immediately after code changes may execute against stale compiled classes
- Use the `mcp__jetbrains__get_run_configurations` tool to list available run configurations
- Use the `mcp__jetbrains__execute_run_configuration` tool to execute specific tests
- To run ALL tests in the feature-processor module, run the test class: `dev.specbinder.feature2junit.tests.AllTests`
- When the AllTests output is too large to parse, run individual test suites from `feature-processor/src/test/java/dev/specbinder/feature2junit/tests/` instead (e.g., `MappingStepsTest`, `MappingRuleTest`, `GeneratorOptionsTest`, etc.)
- This hybrid approach provides compile-time guarantees + IntelliJ's better test integration and IDE support
- **Never use `mvn test` commands** unless explicitly requested by the user

**Example test execution workflow:**
```bash
# Step 1: Trigger full project rebuild in IntelliJ IDEA
.idea_scripts/trigger_rebuild_project_shortcut.sh

# Step 2: Run tests via IntelliJ MCP server
mcp__jetbrains__execute_run_configuration(configurationName="AllTests")
```

**IMPORTANT: Compilation and Project Rebuild**
- **NEVER USE MAVEN FOR COMPILATION** - DO NOT RUN `mvn clean compile`, `mvn compile`, `mvn test-compile`, OR ANY MAVEN BUILD COMMANDS
- **ALWAYS use the rebuild script** to trigger full project rebuilds in IntelliJ IDEA:
  ```bash
  .idea_scripts/trigger_rebuild_project_shortcut.sh
  ```
- **When to trigger a rebuild:**
  - After making code changes and before running tests
  - When verifying that tests are passing
  - When checking for regressions across the project
  - Any time you need to ensure all code is compiled with the latest changes
- The rebuild script triggers IntelliJ IDEA's "Rebuild Project" action, which:
  - Cleans all compiled output
  - Runs the annotation processor on all modules
  - Compiles all source and test code from scratch
  - Ensures no stale compiled classes exist
- IntelliJ IDEA also builds automatically when files are saved, but this automatic build is asynchronous and may not complete before tests run
- **The rebuild script guarantees synchronous, complete compilation** before proceeding to test execution
- ONLY USE MAVEN BUILD COMMANDS WHEN EXPLICITLY REQUESTED BY THE USER

## Multi-Module Architecture

This is a Maven multi-module project with these modules:

### 1. `common/`
Foundation module containing shared infrastructure:
- **GeneratorOptions**: Immutable configuration object controlling code generation behavior
- **Interface traits**: LoggingSupport, OptionsSupport, BaseTypeSupport (mixin pattern)
- **SourceLine**: Annotation for tracking feature file line numbers
- **ProcessingException**: Custom exception for annotation processing errors

### 2. `annotations/`
Lightweight module containing public annotations for Cucumber `.feature` file processing:
- `@Feature2JUnit("path/to/file.feature")` - Marks a class for test generation
- `@Feature2JUnitOptions` - Configures generation behavior (inheritable)

**Dependencies:** Only depends on `common` module.

**Client usage:** Client projects add this as a compile dependency to access the annotations without pulling in the heavy annotation processor dependencies.

### 3. `feature-processor/` (PRIMARY MODULE)
Annotation processor for Cucumber `.feature` files. This is the most mature and actively developed module.

**Processing pipeline:**
```
Feature2JUnitGenerator (APT entry point)
  └→ TestSubclassCreator (orchestration)
      ├→ FeatureFileParser (Gherkin parsing)
      └→ FeatureProcessor (top-level)
          ├→ BackgroundProcessor (@BeforeEach generation)
          ├→ RuleProcessor (@Nested classes)
          └→ ScenarioProcessor (@Test/@ParameterizedTest)
              └→ StepProcessor (step method generation)
```

**Key processors location:**
- Entry: `feature-processor/src/main/java/dev/specbinder/feature2junit/Feature2JUnitGenerator.java`
- Orchestration: `feature-processor/src/main/java/dev/specbinder/feature2junit/TestSubclassCreator.java`
- Most complex: `feature-processor/src/main/java/dev/specbinder/feature2junit/gherkin/StepProcessor.java` (~478 lines)

**Utilities:** Located in `feature-processor/src/main/java/dev/specbinder/feature2junit/gherkin/utils/`
- MethodNamingUtils, ParameterNamingUtils, JavaDocUtils, TableUtils, TagUtils, etc.

**Dependencies:** Depends on `annotations`, `common`, and heavy processing libraries (JavaPoet, Cucumber parser, etc.)

**Client usage:** Client projects add this as an annotation processor dependency (used only during compilation).

### 4. `user-story-processor/`
Annotation processor for JBehave `.story` files. Less mature than feature-processor.

### 5. `examples/`
Contains usage examples for feature2junit with 6 sub-example modules covering various use cases.

**Module build order:** common → annotations → feature-processor/user-story-processor (parallel) → examples

## Code Architecture

### Annotation Processing Flow
1. User annotates a class with `@Feature2JUnit("specs/cart.feature")`
2. During `javac`, Feature2JUnitGenerator runs
3. Parser reads .feature file using Cucumber's Gherkin parser
4. Processors convert Gherkin AST to JavaPoet code model
5. Generated test class written to `target/generated-test-sources/test-annotations/`

### Generation Pattern

The generator always produces abstract test classes:
```
UserFeature.java (@Feature2JUnit, abstract marker)
  ↓ generates
UserFeatureScenarios.java (abstract test class with abstract step methods)
  ↓ user creates
UserFeatureTest.java (implements abstract step methods)
```

### Key Architectural Patterns

1. **Mixin Traits Pattern**: Processors implement LoggingSupport, OptionsSupport, BaseTypeSupport interfaces instead of inheritance
2. **Delegation over Inheritance**: Processors compose child processors rather than extending base classes
3. **Immutability**: GeneratorOptions is immutable (all fields final, no setters)
4. **Type-Safe Code Generation**: Uses JavaPoet, not string concatenation
5. **Layered Processing**: Generator → Creator → Parser → Processors → Utilities

### Gherkin Mapping

The codebase includes comprehensive test features documenting the Gherkin-to-JUnit mapping:
- `feature-processor/src/test/resources/features/MappingFeature.feature` - Feature-level mappings
- `feature-processor/src/test/resources/features/MappingRule.feature` - Rule mappings
- `feature-processor/src/test/resources/features/MappingScenario.feature` - Scenario mappings
- `feature-processor/src/test/resources/features/steps/MappingSteps.feature` - Step mappings

Key mappings:
- Feature → JUnit test class
- Background → @BeforeEach method
- Rule → @Nested test class
- Scenario → @Test method
- Scenario Outline → @ParameterizedTest with @CsvSource
- Steps → Method calls with extracted parameters
- Tags → @Tag annotations
- DataTables → DataTable objects
- DocStrings → String parameters

## Code Style Guidelines

**CRITICAL: Always Use Import Statements**

When writing or modifying Java code, **NEVER use fully qualified class names directly in the code**. Always add proper import statements at the top of the file instead.

**IMPORTANT: Avoid Java Reflection**

When creating or updating Java code, **avoid using Java reflection** (e.g., `Class.forName()`, `Method.invoke()`, `Field.set()`, etc.) unless the existing class or method being modified already uses reflection. The project emphasizes compile-time safety and type safety, which reflection undermines.

## Technology Stack

- **Java:** 17+
- **Build:** Maven 3.x
- **Code Generation:** JavaPoet 1.13.0
- **Gherkin Parsing:** Cucumber Java 7.23.0
- **Testing:** JUnit 5.10.2, Mockito 5.18.0, Cucumber JUnit Platform Engine 7.14.0
- **APT Registration:** Google Auto Service 1.1.1

## Common Development Tasks

### Adding a New Gherkin Element Processor
1. Create processor class in `feature-processor/src/main/java/dev/specbinder/feature2junit/gherkin/`
2. Implement LoggingSupport, OptionsSupport, BaseTypeSupport
3. Add processing logic in parent processor
4. Add utilities to `utils/` if needed
5. Add test cases in `src/test/`

### Modifying Generation Behavior
1. Add option to `common/src/main/java/dev/specbinder/common/GeneratorOptions.java`
2. Add annotation parameter to `annotations/src/main/java/dev/specbinder/annotations/Feature2JUnitOptions.java`
3. Update GeneratorOptions construction in `feature-processor/src/main/java/dev/specbinder/feature2junit/Feature2JUnitGenerator.process()`
4. Use option in relevant processor
5. Update tests

### Debugging Generated Code

**Production Code Generation:**
- Generated sources: `target/generated-test-sources/test-annotations/`
- Processor logs prefixed with `[Feature2JUnitGenerator]`
- Use @SourceLine annotations for navigation back to .feature files

**Test Execution Output Structure:**

When feature tests execute, they write test artifacts to a structured output directory for debugging and verification:

```
target/feature-tests-output/
  └── <feature-file-path>/           # Path of the currently running feature
      └── <scenario-line-number>/    # Directory for each scenario (identified by line number)
          └── <package-directories>/ # Package structure for base classes and feature files
```

**Purpose:**
- **Debugging test failures**: Inspect what base classes and feature files were created by each scenario
- **Verifying compilation**: Check what was actually compiled during test execution
- **Analyzing verification failures**: Compare actual generated output against expected values

**When to use:**
- When a test fails, navigate to the corresponding scenario's output directory to examine:
  - Base classes generated as preconditions
  - Feature files used for context
  - Compiled artifacts produced by the annotation processor
- When verification assertions fail, inspect these directories to understand the discrepancy between actual and expected output

**Example:**
For a feature file at `features/steps/MappingSteps.feature` with a scenario at line 42:
```
target/feature-tests-output/features/steps/MappingSteps/Scenario_line_42/...
```

### Working with Step Processing
Most step-related logic is in StepProcessor.java:478. Key responsibilities:
- Extract parameters from quoted text using regex: `(?<parameter>(\")(?<parameterValue>[^\"]+?)(\"))`
- Handle DataTables and DocStrings
- Generate method signatures
- Deduplicate methods (check base class hierarchy)
- Optional Cucumber annotation generation (@Given, @When, @Then)

## Working with Files

**IMPORTANT: When the user asks you to update, modify, or change a file, do it immediately without asking for permission.**

The user expects you to make changes directly when requested. Only ask clarifying questions if the requirements are ambiguous, not for permission to proceed.

**CRITICAL: Do NOT modify .feature files to match implementation behavior**

When tests fail because the actual behavior doesn't match the expected behavior defined in a .feature file:
- **NEVER** modify the .feature file to match the current implementation
- **ALWAYS** modify the implementation code to match the .feature file specification
- .feature files define the expected behavior and serve as the specification
- The implementation must conform to the specification, not the other way around
- Only modify .feature files when explicitly asked by the user

**IMPORTANT: Reading Tool Results**

You have permission to read files from the `.claude/projects/` directory, particularly tool-results files. These contain output from previous tool executions (like test runs) and can be read freely without asking for permission. Use the `Bash` tool or `Read` tool to access these files when you need to analyze test results or other tool outputs.

**IMPORTANT: No Absolute Paths in Settings Files**

When updating `.claude/settings.local.json` or any other settings file, **never use absolute file paths**. Always use relative paths instead. Absolute paths (e.g., `/Users/dmytro/Projects/...`) are machine-specific and should not appear in settings files.

## Working with Cucumber .feature Files

**IMPORTANT: Feature File Naming Convention**

When creating a new `.feature` file, always follow this naming rule for IntelliJ IDEA integration:

The first line of the feature file should be:
```gherkin
Feature: FeatureFileName
```

Where `FeatureFileName` is the name of the feature file WITHOUT the `.feature` extension.

**Example:**
If creating a file named `MappingStepDataTables.feature`, the first line must be:
```gherkin
Feature: MappingStepDataTables
```

**Why this matters:**
- IntelliJ IDEA uses the Feature name as a node in the Run tool window
- This convention ensures the feature file name is clearly visible when running tests
- It provides consistency between the file name and the feature name displayed in test results

**Additional .feature File Guidelines:**
- Place test feature files in `feature-processor/src/test/resources/features/`
- Feature files serve as living documentation of the Gherkin-to-JUnit mapping
- Always run tests using IntelliJ IDEA's MCP server tools, NOT MAVEN COMMANDS

## Git Workflow

**IMPORTANT: Always stage changes immediately after making them.**

Whenever you create OR modify a file, you MUST run `git add <file>` to stage it to the git index. This applies to:
- New files created
- Modified files (source code, tests, documentation, feature files, etc.)
- Deleted files

Example:
```bash
# After creating or modifying files
git add path/to/modified/file.java
git add path/to/modified/test.feature

# Or stage multiple files at once
git add file1.java file2.feature file3.md
```

This ensures all changes are tracked and ready for commit.

## Important Notes

- **Module dependency chain**: common → annotations → feature-processor/user-story-processor
- **feature-processor is primary**: Most mature and actively developed module
- **Annotations separated**: annotations module contains only public API; feature-processor contains the implementation
- **user-story-processor is experimental**: Less mature, fewer features
- **Examples are active**: 6 sub-example modules in `examples/` directory
- **No .cursorrules**: This project doesn't have AI assistant rules configured
- **Comprehensive README**: 1800+ lines of detailed documentation in README.md
- **Self-documenting tests**: Test .feature files serve as living documentation of the Gherkin-to-JUnit mapping

## Testing Strategy

The project uses a self-hosting approach - Cucumber tests validate the Cucumber-to-JUnit generator:
- Test features in `feature-processor/src/test/resources/features/`
- Test implementations verify generated code correctness
- MappingSteps.feature documents the complete mapping specification

**Test Execution and Verification:**

Tests in the feature-processor module follow a structured execution and verification pattern:

1. **Test Preconditions**: Test scenarios create base classes and feature files as preconditions using Given steps
2. **Code Generation**: The annotation processor generates test classes from the feature files
3. **Compilation**: Generated code is compiled to verify it's syntactically correct
4. **Verification**: Assertion steps verify the generated output matches expected values

**Test Output Directory Structure:**

During test execution, all test artifacts (base classes, feature files, and compiled output) are written to:
```
target/feature-tests-output/<feature-path>/<scenario-identifier>/
```

This structured output enables:
- **Isolated scenario testing**: Each scenario's artifacts are in a separate directory
- **Post-failure analysis**: Inspect what was generated and compiled when tests fail
- **Verification debugging**: Compare actual generated code against expected values
- **Compilation verification**: Check compiled artifacts to ensure code is not just generated but also compilable

**Debugging Failed Tests:**

When a test fails:
1. Locate the scenario's output directory in `target/feature-tests-output/`
2. Examine the base classes and feature files created as preconditions
3. Review the generated test code produced by the annotation processor
4. Compare actual output against the expected values in the assertion
5. Check compilation artifacts to verify the generated code compiles correctly

This approach ensures comprehensive testing of the entire code generation pipeline, from parsing through generation to compilation.

## Generated Code Location

By default: `target/generated-test-sources/test-annotations/`

Can be customized via GeneratorOptions.placeGeneratedClassNextToAnnotatedClass to place generated files next to annotated classes.