# SpecBinder IntelliJ plugin: revision markup is not highlighted when strip patterns are constants

Bug report for the SpecBinder IntelliJ plugin, written up on a work machine for fixing on the personal one.
Everything below was verified against the installed plugin jar and the running project — no part of it is inferred
from documentation alone.

- **Where to file:** the plugin's declared bug tracker,
  <https://github.com/users/dmytro-stasyuk/projects/1/views/1?layout=table> (from the Marketplace listing's
  `bugtrackerUrl`, plugin 30540 `dev.specbinder.intellij-plugin`, vendor SpecBright).
  Note the plugin's own repo (`dmytro-stasyuk/spec-binder-intellij-plugin`) has no issue template, and the
  Marketplace points at the project board rather than repo issues.
- **Severity:** low functional impact, moderate trust impact — nothing is generated incorrectly, but the editor
  silently disagrees with the build.

## Environment

| Component | Version |
| --- | --- |
| Plugin | `spec-binder-intellij-plugin-2026.17.0` (`SpecBinder (Beta)`, `dev.specbinder.intellij-plugin`) |
| IDE | IntelliJ IDEA Ultimate 2026.1, build `IU-261.24374.151` |
| SpecBinder annotations / annotation-processor | `2026.47.0` |
| JDK | Temurin 25.0.3 |
| Project | `reports-hub`, `ci/integration-tests` module, specs are `.specb` |

## Symptom

With `stripPatterns` / `stripBetweenPatterns` configured on `@Gherkin2JUnitOptions`, revision markup in a `.specb`
file is **not** highlighted as markup — it is painted as ordinary Gherkin text — whenever the entries are written as
references to compile-time constants instead of string literals.

There is no warning, no log entry and no inspection highlight: the plugin behaves exactly as if no strip patterns
were configured at all. Generation is unaffected — the annotation processor resolves the constants correctly and
strips the markers — so the editor and the build disagree, which is what makes this confusing to diagnose from the
outside.

Everything downstream of pattern resolution is affected the same way, because it all depends on knowing the
patterns: markup colouring, `Ctrl/Cmd+Click` from a marked-up step to its step method, Find Usages, step
completion, rename, and the recorded execution status matching.

## Reproduction

1. Put the patterns in a constants holder:

   ```java
   package lu.crx.reportshub.tests;

   @UtilityClass
   public class CtcMarkerPatterns {
       public static final String REMOVED_SPAN_START = "(?i)<\\s*(REMOVED?|DEPRECATED)\\b[^<>]*(?<!/)>";
       public static final String REMOVED_SPAN_END = "(?i)</\\s*(REMOVED?|DEPRECATED)\\b[^<>]*>";
       public static final String REVISION_MARKER_START = "(?i)<\\s*(NEW|CHANGED)\\s+[^<>]*>";
       public static final String REVISION_MARKER_END = "(?i)</\\s*(NEW|CHANGED)\\b[^<>]*>";
       public static final String ISSUE_REF_MARKER = "</?\\s*(BR|EA)-\\s*\\d+\\s*>";
   }
   ```

2. Reference them from the marker class:

   ```java
   @Gherkin2JUnit
   @Gherkin2JUnitOptions(
           classSuffixIfConcrete = "_IT",
           shouldBeAbstract = false,
           stripBetweenPatterns = @StripBetween(
                   start = CtcMarkerPatterns.REMOVED_SPAN_START,
                   end = CtcMarkerPatterns.REMOVED_SPAN_END),
           stripPatterns = {
                   CtcMarkerPatterns.REVISION_MARKER_START,
                   CtcMarkerPatterns.REVISION_MARKER_END,
                   CtcMarkerPatterns.ISSUE_REF_MARKER
           }
   )
   abstract class SomeFeature { }
   ```

3. Put a marker in a spec in that package:

   ```gherkin
   Given the cap is <CHANGED by BR-5709>5.00%</CHANGED by BR-5709> by default
   ```

4. Open the spec.

**Expected:** the two `<CHANGED by BR-5709>` markers are painted with the `Strip pattern` colour
(`Settings > Editor > Color Scheme > Gherkin`), as they are when the same regexes are written as literals.

**Actual:** the markers are painted as ordinary step text. Replacing the constant references with the identical
string literals — changing nothing else — makes the highlighting appear immediately, which isolates the cause to
how the entries are written rather than to the patterns, the spec, or the options.

## Root cause

`dev.specbinder.plugin.revisionmarkup.b` — `SourceFile: StripPatternResolver.java` — resolves the attribute values
and accepts **only** `PsiLiteralExpression`. Recovered from the shipped jar with `javap -p -c`:

```
private static void a(PsiAnnotationMemberValue, List<String>)      // array entries, e.g. stripPatterns
    19: instanceof    // class com/intellij/psi/PsiLiteralExpression
    26: checkcast     // class com/intellij/psi/PsiLiteralExpression
    31: invokeinterface PsiLiteralExpression.getValue:()Ljava/lang/Object;
    40: instanceof    // class java/lang/String
    54: invokeinterface java/util/List.add:(Ljava/lang/Object;)Z
    60: return                                                     // else: silently dropped

private static String b(PsiAnnotation, String)                     // single value, e.g. @StripBetween.start / .end
    20: invokeinterface PsiAnnotation.findDeclaredAttributeValue:(Ljava/lang/String;)L…PsiAnnotationMemberValue;
    27: instanceof    // class com/intellij/psi/PsiLiteralExpression
    34: checkcast     // class com/intellij/psi/PsiLiteralExpression
    39: invokeinterface PsiLiteralExpression.getValue:()Ljava/lang/Object;
    48: instanceof    // class java/lang/String
```

A constant reference is a `PsiReferenceExpression`, not a `PsiLiteralExpression`, so both paths fail their
`instanceof` and contribute nothing. The array is still unwrapped correctly
(`PsiArrayInitializerMemberValue.getInitializers()`), and the single-`@StripBetween` shorthand without braces is
handled too (the resolver tests `instanceof PsiAnnotation` as well as the array form) — the failure is purely at the
leaf.

Nothing else in the plugin compensates: across the whole jar,

```
computeConstantValue        → 0 files
PsiConstantEvaluationHelper → 0 files
```

so there is no constant-evaluating path anywhere.

The same limitation reaches the inspection. `inspectionDescriptions/SpecBinderStripPattern.html` promises

> Reports a `stripPatterns` entry of `@Gherkin2JUnitOptions` that is not a valid regular expression.

but since `StripPatternInspection` resolves entries through the same resolver, an invalid regex held in a constant is
never reported in the editor — it surfaces only as a failed build. That is a second, quieter symptom of one cause.

## Suggested fix

In `StripPatternResolver`, evaluate each member value as a constant expression and keep the literal check as a
fallback. Both leaf paths need it — the array-entry collector and the single-value reader:

```java
private static @Nullable String stringValueOf(@Nullable PsiAnnotationMemberValue value) {
    if (value instanceof PsiExpression expression) {
        Object constant = JavaPsiFacade.getInstance(expression.getProject())
                .getConstantEvaluationHelper()
                .computeConstantExpression(expression);
        if (constant instanceof String string) {
            return string;
        }
    }
    if (value instanceof PsiLiteralExpression literal && literal.getValue() instanceof String string) {
        return string;
    }
    return null;
}
```

`computeConstantExpression` also covers concatenation (`"(?i)" + BASE`), a static import of a constant, and a
constant declared in the marker class itself — all of which fail today for the same reason. `JavaPsiFacade` is
already imported by the resolver, so this needs no new dependency.

Worth considering alongside it: when an entry resolves to nothing, log at debug or surface a weak warning on the
annotation. The current silence is the reason this took a bytecode read to explain rather than a glance at the
editor — an "entry could not be resolved to a string" hint would have made it self-evident.

## Why constants are worth supporting

Sharing the patterns is not a stylistic preference here; the processor forces the duplication it would avoid. A
`@Gherkin2JUnit` marker class that both **declares** `@Gherkin2JUnitOptions` and **inherits** one crashes the
annotation processor (see the separate note below), so the options cannot be hoisted onto a shared test base class.
Each marker class must declare its own copy. In this project that is 5 classes × 5 regexes, and constants were the
natural way to keep them from drifting.

Because of this bug we reverted to inlined literals in all 5 marker classes, and recorded why in
`ci/integration-tests/src/test/java/lu/crx/reportshub/tests/BDD Tests.md` so nobody refactors them back. Once the
plugin resolves constants, that decision is worth revisiting.

## Workaround

Write every entry as a string literal in each marker class. Highlighting and the regex inspection then work as
documented.

## Separately observed: annotation-processor crash (different component, worth its own ticket)

Found while configuring the above; recording it here so it is not lost. This is in `spec-binder`, not the plugin.

A `@Gherkin2JUnit` marker class that has both a **declared** and an **inherited** `@Gherkin2JUnitOptions` — the
latter picked up from a base class, since the annotation is `@Inherited` — kills the processor:

```
java.lang.IllegalArgumentException: unused arguments: expected 3, received 4
    at com.squareup.javapoet.Util.checkArgument(Util.java:53)
    at com.squareup.javapoet.CodeBlock$Builder.add(CodeBlock.java:298)
    at com.squareup.javapoet.AnnotationSpec$Builder.addMember(AnnotationSpec.java:203)
    at dev.specbinder.processor.gherkin.StepProcessor.buildGWTAnnotation(StepProcessor.java:1601)
    at dev.specbinder.processor.gherkin.StepProcessor.processStep(StepProcessor.java:218)
    at dev.specbinder.processor.TestSubclassCreator.createTestSubclass(TestSubclassCreator.java:110)
    at dev.specbinder.processor.AnnotationProcessor.process(AnnotationProcessor.java:193)
```

Reproduced on `2026.47.0` with the declared values **identical** to the inherited ones, and with both the bare
`@Gherkin2JUnitOptions` and a fully parameterised form — so it is the presence of two annotation mirrors, not their
contents. Duplicated annotation members reaching `AnnotationSpec.Builder.addMember` would explain the arity
mismatch.

Two things make it expensive to diagnose:

1. The crash aborts annotation processing before any SpecBinder class is written, so the reported failure is ~140
   `cannot find symbol` errors in unrelated files (page objects missing their generated `*Accessors`, test suites
   missing their generated `*_IT`). The stack trace is the only honest signal; the error list points nowhere near
   the cause.
2. Since `@Gherkin2JUnitOptions` is `@Inherited`, hoisting it onto a shared base class and overriding per feature
   looks like the intended design. It compiles, reads naturally, and then fails this way.

A clear diagnostic ("options are declared on X and inherited from Y; declare them in one place") would be enough,
even if merging the two is not worth supporting.
