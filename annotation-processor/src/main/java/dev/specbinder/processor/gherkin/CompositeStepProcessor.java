package dev.specbinder.processor.gherkin;

import com.squareup.javapoet.*;
import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.gherkin.utils.DataTableCollector;
import dev.specbinder.processor.gherkin.utils.EnumImportCollector;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.processor.support.OptionsSupport;
import dev.specbinder.processor.utils.MethodNamingUtils;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.cucumber.messages.types.Step;
import org.apache.commons.lang3.function.TriConsumer;
import org.junit.jupiter.api.Assertions;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.TypeMirror;
import java.util.*;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Processes composite step patterns where a Given/When/Then/And/But step is followed by
 * one or more '*' steps.
 */
class CompositeStepProcessor implements LoggingSupport, OptionsSupport {

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final DataTableCollector dataTableCollector;
    private final EnumImportCollector enumImportCollector;
    private final TypeElement baseType;

    private static final Pattern parameterPattern = Pattern.compile("(?<parameter>(\")(?<parameterValue>([^\"\\\\]|\\\\.)*?)(\"))");

    public CompositeStepProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options,
                                   DataTableCollector dataTableCollector, EnumImportCollector enumImportCollector,
                                   TypeElement baseType) {
        this.processingEnv = processingEnv;
        this.options = options;
        this.dataTableCollector = dataTableCollector;
        this.enumImportCollector = enumImportCollector;
        this.baseType = baseType;
    }

    @Override
    public ProcessingEnvironment getProcessingEnv() {
        return processingEnv;
    }

    @Override
    public GeneratorOptions getOptions() {
        return options;
    }

    public void processCompositeStep(
            CompositeStepGroup compositeGroup,
            MethodSpec.Builder scenarioMethodBuilder,
            List<MethodSpec> scenarioStepsMethodSpecs,
            List<String> resolvedStepKeywords,
            TypeSpec.Builder classBuilder,
            List<MethodSpec> allMethodSpecs,
            Set<String> baseClassMethodNames,
            List<String> scenarioParameterNames,
            List<String> testMethodParameterNames,
            List<Class<?>> scenarioParameterTypes,
            Map<Integer, TypeMirror> enumParameterTypes) {

        Step parentStep = compositeGroup.getParentStep();
        List<Step> subSteps = compositeGroup.getSubSteps();

        // Extract parameters from parent step
        String parentStepText = parentStep.getKeyword() + " " + parentStep.getText();
        List<String> parameterValues = extractParameterValues(parentStepText);

        // Determine the effective keyword for the parent step
        String parentKeyword = parentStep.getKeyword().trim().toLowerCase();
        Class<?> effectiveAnnotation = determineEffectiveAnnotation(parentKeyword, parentStep.getLocation().getLine(), scenarioStepsMethodSpecs);

        // Generate composite method
        MethodSpec compositeMethod = generateCompositeMethod(parentStep, parameterValues, effectiveAnnotation, scenarioStepsMethodSpecs);

        // Add composite method to class if it doesn't already exist
        String compositeMethodName = compositeMethod.name;
        if (allMethodSpecs.stream().noneMatch(m -> m.name.equals(compositeMethodName))
                && !baseClassMethodNames.contains(compositeMethodName)) {
            classBuilder.addMethod(compositeMethod);
        }

        // Add composite method to scenario steps list so that sub-steps can inherit from it
        scenarioStepsMethodSpecs.add(compositeMethod);

        // Resolve and track the parent step's GWT keyword for And/But/* inheritance
        String resolvedParentKeyword = resolveParentKeyword(parentKeyword, resolvedStepKeywords, parentStep.getLocation().getLine());
        resolvedStepKeywords.add(resolvedParentKeyword);

        // Generate sub-step methods
        List<MethodSpec> subStepMethods = new ArrayList<>();
        List<Step> wrappedSubSteps = new ArrayList<>();
        for (Step subStep : subSteps) {
            MethodSpec subStepMethod;

            // Wrap $pN references in quotes so StepProcessor treats them as parameters
            Step wrappedStep = wrapParameterReferences(subStep);
            wrappedSubSteps.add(wrappedStep);

            // Use StepProcessor for sub-steps
            StepProcessor stepProcessor = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType);
            subStepMethod = stepProcessor.processStep(
                    wrappedStep, null, scenarioStepsMethodSpecs,
                    resolvedStepKeywords,
                    scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes
            );

            subStepMethods.add(subStepMethod);
            scenarioStepsMethodSpecs.add(subStepMethod);

            // Add sub-step method to class if needed
            String subStepMethodName = subStepMethod.name;
            if (allMethodSpecs.stream().noneMatch(m -> m.name.equals(subStepMethodName))
                    && !baseClassMethodNames.contains(subStepMethodName)) {
                classBuilder.addMethod(subStepMethod);
            }
        }

        // Generate lambda call in scenario method - use wrapped steps
        generateLambdaCall(scenarioMethodBuilder, parentStep, compositeMethodName, parameterValues, wrappedSubSteps, subStepMethods);
    }

    /**
     * Resolves the GWT keyword for a parent composite step.
     * For Given/When/Then, returns the keyword directly. For And/But/*, inherits from the previous step.
     */
    private String resolveParentKeyword(String keyword, List<String> resolvedStepKeywords, long stepLine) {
        if (keyword.equals("given") || keyword.equals("when") || keyword.equals("then")) {
            return keyword;
        } else if (keyword.equals("and") || keyword.equals("but") || keyword.equals("*")) {
            if (resolvedStepKeywords.isEmpty()) {
                throw new ProcessingException(
                        "Step on line - " + stepLine
                                + " starts with '" + keyword + "', but there are no previous scenario steps defined");
            }
            return resolvedStepKeywords.get(resolvedStepKeywords.size() - 1);
        }
        throw new ProcessingException("Invalid step keyword: " + keyword);
    }

    /**
     * Determines the effective Cucumber annotation for a step based on its keyword.
     * For And/But/* keywords, inherits from the previous step's annotation.
     */
    private Class<?> determineEffectiveAnnotation(String keyword, long stepLine, List<MethodSpec> scenarioStepsMethodSpecs) {
        if (keyword.equals("given")) {
            return Given.class;
        } else if (keyword.equals("when")) {
            return When.class;
        } else if (keyword.equals("then")) {
            return Then.class;
        } else if (keyword.equals("and") || keyword.equals("but") || keyword.equals("*")) {
            // Inherit from previous step
            if (scenarioStepsMethodSpecs.isEmpty()) {
                throw new ProcessingException(
                        "Step on line - " + stepLine
                                + " starts with '" + keyword + "', but there are no previous scenario steps defined");
            }

            MethodSpec lastScenarioMethodSpec = scenarioStepsMethodSpecs.get(scenarioStepsMethodSpecs.size() - 1);

            // Determine keyword from method name prefix (same logic as MethodNamingUtils.getPreviousGWTStepWord)
            String lastMethodName = lastScenarioMethodSpec.name;
            if (lastMethodName.startsWith("given")) {
                return Given.class;
            } else if (lastMethodName.startsWith("when")) {
                return When.class;
            } else if (lastMethodName.startsWith("then")) {
                return Then.class;
            }

            // When useStepKeywordInStepMethodName is false, method names don't have keyword prefixes,
            // so we can't determine the annotation from the method name. Return null - the caller
            // only uses the annotation when addCucumberStepAnnotations is enabled.
            return null;
        }

        return null;
    }

    private List<String> extractParameterValues(String stepText) {
        List<String> parameterValues = new ArrayList<>();
        Matcher matcher = parameterPattern.matcher(stepText);
        while (matcher.find()) {
            String value = matcher.group("parameterValue");
            value = value.replaceAll("\\\\([\"\\\\])", "$1");
            parameterValues.add(value);
        }
        return parameterValues;
    }

    private MethodSpec generateCompositeMethod(Step parentStep, List<String> parameterValues, Class<?> effectiveAnnotation, List<MethodSpec> scenarioStepsMethodSpecs) {
        String parentStepText = parentStep.getKeyword() + " " + parentStep.getText();
        long stepLine = parentStep.getLocation().getLine();

        // Replace quoted strings with placeholders ($p1, $p2, etc.) for method naming
        String stepPattern = replaceParametersWithPlaceholders(parentStepText, parameterValues);
        String methodName = MethodNamingUtils.getStepMethodName(stepPattern, scenarioStepsMethodSpecs, stepLine,
                getOptions().isUseStepKeywordInStepMethodName());

        MethodSpec.Builder methodBuilder = MethodSpec.methodBuilder(methodName)
                .addModifiers(Modifier.PROTECTED);

        // Add Cucumber annotation if option is enabled
        if (effectiveAnnotation != null && options.isAddCucumberStepAnnotations()) {
            AnnotationSpec annotationSpec = buildCucumberAnnotation(effectiveAnnotation, stepPattern, parameterValues);
            methodBuilder.addAnnotation(annotationSpec);
        }

        // Add parameters from parent step
        for (int i = 0; i < parameterValues.size(); i++) {
            String paramName = deriveParameterName(i, parameterValues.get(i));
            methodBuilder.addParameter(String.class, paramName);
        }

        // Add varargs Consumer parameter
        TypeName consumerType = getConsumerType(parameterValues.size());
        ArrayTypeName varargsType = ArrayTypeName.of(consumerType);
        methodBuilder.addParameter(
                ParameterSpec.builder(varargsType, "composite")
                        .build()
        );
        methodBuilder.varargs(true);

        // Generate method body
        CodeBlock.Builder bodyBuilder = CodeBlock.builder();
        bodyBuilder.beginControlFlow("if (composite.length > 0)");

        // Build the accept/run call based on parameter count
        int paramCount = parameterValues.size();
        if (paramCount == 0) {
            // Runnable has run() method
            bodyBuilder.addStatement("stream(composite).forEach(r -> r.run())");
        } else {
            // Consumer/BiConsumer have accept() method
            String acceptParams = buildAcceptParameters(paramCount);
            bodyBuilder.addStatement("stream(composite).forEach(action -> action.accept($L))", acceptParams);
        }

        bodyBuilder.nextControlFlow("else");
        bodyBuilder.addStatement("$T.fail($S)", Assertions.class, "Step is not yet implemented");
        bodyBuilder.endControlFlow();

        methodBuilder.addCode(bodyBuilder.build());

        return methodBuilder.build();
    }

    private String deriveParameterName(int index, String value) {
        // Use p1, p2, p3 naming convention
        return "p" + (index + 1);
    }

    private TypeName getConsumerType(int paramCount) {
        return switch (paramCount) {
            case 0 -> ClassName.get(Runnable.class);
            case 1 -> ParameterizedTypeName.get(
                    ClassName.get(Consumer.class),
                    ClassName.get(String.class)
            );
            case 2 -> ParameterizedTypeName.get(
                    ClassName.get(BiConsumer.class),
                    ClassName.get(String.class),
                    ClassName.get(String.class)
            );
            case 3 -> ParameterizedTypeName.get(
                    ClassName.get(TriConsumer.class),
                    ClassName.get(String.class),
                    ClassName.get(String.class),
                    ClassName.get(String.class)
            );
            default -> throw new ProcessingException(
                    "Composite steps with " + paramCount + " parameters not yet supported. " +
                            "Only 0-3 parameters are currently supported."
            );
        };
    }

    private String buildAcceptParameters(int paramCount) {
        if (paramCount == 0) return "";

        // Build p1, p2, p3, etc.
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < paramCount; i++) {
            if (i > 0) sb.append(", ");
            sb.append("p").append(i + 1);
        }
        return sb.toString();
    }

    private void generateLambdaCall(
            MethodSpec.Builder scenarioMethodBuilder,
            Step parentStep,
            String compositeMethodName,
            List<String> parameterValues,
            List<Step> subSteps,
            List<MethodSpec> subStepMethods) {

        // Add block comment for the composite step
        String stepText = parentStep.getKeyword() + parentStep.getText();
        scenarioMethodBuilder.addCode("/*");
        if (options.isAddSourceLineNumbers()) {
            scenarioMethodBuilder.addCode("\n * [$L] $L", parentStep.getLocation().getLine(), stepText);
        } else {
            scenarioMethodBuilder.addCode("\n * $L", stepText);
        }
        scenarioMethodBuilder.addCode("\n */\n");

        // Build the complete method call as a single statement string
        StringBuilder callBuilder = new StringBuilder();

        // Method name and parameter values
        callBuilder.append(compositeMethodName).append("(");
        for (int i = 0; i < parameterValues.size(); i++) {
            if (i > 0) callBuilder.append(", ");
            callBuilder.append("\"").append(escapeForJavaStringLiteral(parameterValues.get(i))).append("\"");
        }

        // Lambda expression
        if (!parameterValues.isEmpty()) {
            callBuilder.append(", ");
        }
        String lambdaParams = buildLambdaParameters(parameterValues.size());
        callBuilder.append("(").append(lambdaParams).append(") -> {\n");

        // Sub-step calls (with proper indentation)
        for (int i = 0; i < subSteps.size(); i++) {
            Step subStep = subSteps.get(i);
            MethodSpec subStepMethod = subStepMethods.get(i);
            String subStepCall = buildSubStepCall(subStep, subStepMethod, parameterValues.size());
            callBuilder.append("    ").append(subStepCall).append(";\n");
        }

        callBuilder.append("})");

        // Add as a single code block statement using $L to prevent JavaPoet from interpreting special characters
        scenarioMethodBuilder.addCode("$L;\n", callBuilder.toString());
    }

    private String buildLambdaParameters(int paramCount) {
        if (paramCount == 0) return "";
        if (paramCount == 1) return "p1";
        if (paramCount == 2) return "p1, p2";

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < paramCount; i++) {
            if (i > 0) sb.append(", ");
            sb.append("p").append(i + 1);
        }
        return sb.toString();
    }

    private String buildSubStepCall(Step subStep, MethodSpec subStepMethod, int parentParamCount) {
        String methodName = subStepMethod.name;
        String stepText = subStep.getText();

        // Extract all quoted parameter values from the step (including "$p1", "Welcome", etc.)
        // After wrapParameterReferences, both $pN and literal strings are wrapped in quotes
        List<String> quotedValues = extractParameterValues(subStep.getKeyword() + " " + stepText);

        // Build call parameters based on method signature
        List<String> callParams = new ArrayList<>();
        int paramCount = subStepMethod.parameters.size();

        // Pattern to match $pN references
        Pattern dollarPattern = Pattern.compile("^\\$p(\\d+)$");

        for (int i = 0; i < paramCount && i < quotedValues.size(); i++) {
            String value = quotedValues.get(i);
            Matcher matcher = dollarPattern.matcher(value);

            if (matcher.matches()) {
                // It's a parameter reference like "$p1", pass the lambda parameter
                int paramNum = Integer.parseInt(matcher.group(1));
                if (paramNum <= parentParamCount) {
                    callParams.add("p" + paramNum);
                }
            } else {
                // It's a literal quoted string, convert to appropriate type literal
                TypeName paramType = subStepMethod.parameters.get(i).type;
                String literal = convertToLiteral(paramType, value);
                callParams.add(literal);
            }
        }

        return methodName + "(" + String.join(", ", callParams) + ")";
    }

    /**
     * Converts a string value to the appropriate Java literal based on the target type.
     * For example: "120" -> 120 for Integer, "true" -> true for Boolean, "Alice" -> "Alice" for String
     */
    private String convertToLiteral(TypeName typeName, String value) {
        String typeString = typeName.toString();

        // Handle primitive and wrapper types
        if (typeString.equals("int") || typeString.equals("java.lang.Integer")) {
            try {
                Integer.parseInt(value);
                return value; // No suffix for int
            } catch (NumberFormatException e) {
                // Fall through to default string literal
            }
        } else if (typeString.equals("long") || typeString.equals("java.lang.Long")) {
            try {
                Long.parseLong(value);
                return value + "L";
            } catch (NumberFormatException e) {
                // Fall through to default string literal
            }
        } else if (typeString.equals("double") || typeString.equals("java.lang.Double")) {
            try {
                Double.parseDouble(value);
                if (value.contains(".")) {
                    return value;
                } else {
                    return value + ".0";
                }
            } catch (NumberFormatException e) {
                // Fall through to default string literal
            }
        } else if (typeString.equals("boolean") || typeString.equals("java.lang.Boolean")) {
            if ("true".equalsIgnoreCase(value) || "false".equalsIgnoreCase(value)) {
                return value.toLowerCase();
            }
        } else if (typeString.equals("char") || typeString.equals("java.lang.Character")) {
            if (value.length() == 1) {
                return "'" + value + "'";
            }
        }

        // Default: return as quoted string
        return "\"" + escapeForJavaStringLiteral(value) + "\"";
    }

    private static String escapeForJavaStringLiteral(String value) {
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"");
    }

    /**
     * Wraps $p1, $p2, etc. references in quotes so StepProcessor treats them as parameters.
     * For example: "login as customer $p1" becomes "login as customer \"$p1\""
     */
    private Step wrapParameterReferences(Step step) {
        String originalText = step.getText();
        String modifiedText = originalText.replaceAll("\\$p(\\d+)", "\"\\$p$1\"");

        // If no changes, return original step
        if (modifiedText.equals(originalText)) {
            return step;
        }

        // Create a new Step with modified text
        return new Step(
                step.getLocation(),
                step.getKeyword(),
                step.getKeywordType().orElse(null),
                modifiedText,
                step.getDocString().orElse(null),
                step.getDataTable().orElse(null),
                step.getId()
        );
    }

    /**
     * Replaces quoted parameter values with placeholders ($p1, $p2, etc.) in the step text.
     * This is used to generate method names that use placeholders instead of actual values.
     */
    private String replaceParametersWithPlaceholders(String stepText, List<String> parameterValues) {
        Matcher matcher = parameterPattern.matcher(stepText);
        int lastEnd = 0;
        int paramIndex = 1;
        StringBuilder result = new StringBuilder();

        while (matcher.find()) {
            // Append text before the match
            result.append(stepText.substring(lastEnd, matcher.start()));
            // Append placeholder
            result.append("$p").append(paramIndex);
            paramIndex++;
            lastEnd = matcher.end();
        }

        // Append remaining text
        if (lastEnd < stepText.length()) {
            result.append(stepText.substring(lastEnd));
        }

        return result.toString();
    }

    /**
     * Builds a Cucumber annotation (@Given, @When, @Then) with the proper regex pattern value.
     * This ensures the annotation includes the step text pattern as required by Cucumber.
     */
    private AnnotationSpec buildCucumberAnnotation(Class<?> annotationClass, String stepPattern, List<String> parameterValues) {
        // Build the annotation value with regex pattern
        // Replace $p1, $p2 with regex capture groups
        String annotationValue = stepPattern;

        // Split by whitespace to get words, then skip the keyword (Given/When/Then)
        String[] words = annotationValue.split("\\s+");
        String[] stepWords = Arrays.copyOfRange(words, 1, words.length);
        String stepText = String.join(" ", stepWords);

        // Replace placeholders with JavaPoet format strings ($L)
        for (int i = parameterValues.size(); i >= 1; i--) {
            stepText = stepText.replace("$p" + i, "$L");
        }

        // Escape regex special characters
        stepText = escapeRegexSpecialCharacters(stepText);

        // Escape literal dollar signs that are not part of JavaPoet placeholders ($L)
        stepText = stepText.replaceAll("\\$(?!L)", "\\$\\$");

        // Escape literal double quotes for regex pattern
        stepText = stepText.replace("\"", "\\\"");

        // Add regex anchors
        stepText = "^" + stepText + "$L";

        // Build the format arguments for JavaPoet
        String[] args = new String[parameterValues.size() + 1];
        for (int i = 0; i < parameterValues.size(); i++) {
            args[i] = "(?<p" + (i + 1) + ">.*)";
        }
        args[args.length - 1] = "$"; // for the '$' at the end of the pattern

        // Build the annotation
        AnnotationSpec.Builder builder = AnnotationSpec.builder(annotationClass);
        builder.addMember("value", "\"" + stepText + "\"", (Object[]) args);

        return builder.build();
    }

    /**
     * Escapes special regex characters in the step text while preserving $L placeholders for JavaPoet.
     * Special regex characters that need escaping: . ^ $ * + ? { } [ ] ( ) | \
     */
    private String escapeRegexSpecialCharacters(String text) {
        StringBuilder result = new StringBuilder();

        for (int i = 0; i < text.length(); i++) {
            char ch = text.charAt(i);

            // Check if this is a $L placeholder (skip escaping)
            if (ch == '$' && i + 1 < text.length() && text.charAt(i + 1) == 'L') {
                result.append("$L");
                i++; // skip the 'L'
                continue;
            }

            // Escape regex special characters
            switch (ch) {
                case '.':
                case '^':
                case '$':
                case '*':
                case '+':
                case '?':
                case '{':
                case '}':
                case '[':
                case ']':
                case '(':
                case ')':
                case '|':
                case '\\':
                    result.append("\\\\").append(ch);
                    break;
                default:
                    result.append(ch);
                    break;
            }
        }

        return result.toString();
    }
}
