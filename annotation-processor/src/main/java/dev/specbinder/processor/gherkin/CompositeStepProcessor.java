package dev.specbinder.processor.gherkin;

import com.squareup.javapoet.*;
import dev.specbinder.annotations.output.composite.PentaConsumer;
import dev.specbinder.annotations.output.composite.QuadConsumer;
import dev.specbinder.annotations.output.composite.TriConsumer;
import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.gherkin.utils.DataTableCollector;
import dev.specbinder.processor.gherkin.utils.EnumImportCollector;
import dev.specbinder.processor.gherkin.utils.RecordMetadata;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.processor.support.OptionsSupport;
import dev.specbinder.processor.utils.*;
import dev.specbinder.processor.utils.StepKeywordUtils.ResolvedStepKeyword;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.cucumber.messages.types.Step;
import io.cucumber.messages.types.TableCell;
import io.cucumber.messages.types.TableRow;
import org.junit.jupiter.api.Assertions;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.*;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import java.util.*;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.IntStream;

import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;
import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

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
    private final Map<String, List<Class<?>>> preComputedStepTypes;
    private final Map<String, List<ElementMethodUtils.MethodSignature>> baseClassMethodSignatures;

    private static final Pattern parameterPattern = Pattern.compile("(?<parameter>(\")(?<parameterValue>([^\"\\\\]|\\\\.)*?)(\"))");
    // A reference from a sub-step to its parent step, e.g. <$p1>, <$email> or <$name[2]>; a leading backslash escapes it
    private static final Pattern referencePattern =
            Pattern.compile("(?<escape>\\\\)?<\\$(?<name>[^<>\\[\\]\"]+?)(?<rowNumber>\\[[^\\]]*])?>");
    private static final Pattern parentValueNamePattern = Pattern.compile("p(?<number>[1-9]\\d*)");
    private static final String DATA_TABLE_REFERENCE_NAME = "dataTable";
    private static final String DOC_STRING_REFERENCE_NAME = "docString";
    private static final String DATA_TABLE_PLACEMENT = "\"<$dataTable>\" can only stand alone in double quotes at the end"
            + " of a sub-step's text, in place of a data table of its own";

    public CompositeStepProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options,
                                   DataTableCollector dataTableCollector, EnumImportCollector enumImportCollector,
                                   TypeElement baseType, Map<String, List<Class<?>>> preComputedStepTypes) {
        this.processingEnv = processingEnv;
        this.options = options;
        this.dataTableCollector = dataTableCollector;
        this.enumImportCollector = enumImportCollector;
        this.baseType = baseType;
        this.preComputedStepTypes = preComputedStepTypes;
        this.baseClassMethodSignatures = baseType != null
                ? ElementMethodUtils.getAllInheritedMethodSignatures(processingEnv, baseType)
                : Map.of();
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
            List<ResolvedStepKeyword> resolvedStepKeywords,
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
        boolean hasDataTable = parentStep.getDataTable().isPresent();
        boolean hasDocString = parentStep.getDocString().isPresent();

        // Resolve the parent step's keyword, which an And/But parent takes from the step before it
        ResolvedStepKeyword resolvedParentKeyword = StepKeywordUtils.resolve(parentStep, resolvedStepKeywords);
        Class<?> effectiveAnnotation = annotationFor(resolvedParentKeyword);

        // Replace quoted strings with placeholders ($p1, $p2, etc.) for method naming
        String stepPattern = replaceParametersWithPlaceholders(parentStepText, parameterValues);
        String compositeMethodName = MethodNamingUtils.getStepMethodName(stepPattern, parentStep.getKeyword(),
                resolvedParentKeyword, getOptions().isUseStepKeywordInStepMethodName());

        // Type the parent step's values: a composite step method in the base class fixes their types, otherwise
        // they are typed across all uses of the composite step
        ElementMethodUtils.MethodSignature baseCompositeMethod =
                findBaseCompositeMethod(compositeMethodName, parameterValues, hasDataTable || hasDocString);
        List<Class<?>> preComputedTypes = preComputedStepTypes.get(CompositeStepTypeResolver.typesKey(compositeMethodName));
        List<TypeName> parameterTypes = new ArrayList<>();
        List<String> parameterNames = new ArrayList<>();
        List<Class<?>> valueClasses = new ArrayList<>();
        List<String> parentArguments = new ArrayList<>();
        for (int i = 0; i < parameterValues.size(); i++) {
            // In a Scenario Outline, a value that is an Examples placeholder passes the test method's parameter
            int scenarioParameterIndex = scenarioParameterIndex(parameterValues.get(i), scenarioParameterNames);
            TypeName valueType;
            if (baseCompositeMethod != null) {
                TypeMirror baseParameterType = baseCompositeMethod.getParameterType(i);
                valueType = TypeName.get(baseParameterType);
                valueClasses.add(CompositeStepTypeResolver.classOf(baseParameterType));
            } else {
                Class<?> valueClass;
                if (scenarioParameterIndex >= 0 && scenarioParameterTypes != null
                        && scenarioParameterIndex < scenarioParameterTypes.size()) {
                    valueClass = scenarioParameterTypes.get(scenarioParameterIndex);
                } else if (preComputedTypes != null) {
                    valueClass = preComputedTypes.get(i);
                } else {
                    valueClass = ParameterConversionUtils.inferType(parameterValues.get(i));
                }
                valueType = ClassName.get(valueClass);
                valueClasses.add(valueClass);
            }
            parameterTypes.add(valueType);
            parameterNames.add("p" + (i + 1));
            // A literal that can't be converted to the value's type is passed as written and fails to compile
            parentArguments.add(scenarioParameterIndex >= 0
                    ? testMethodParameterNames.get(scenarioParameterIndex)
                    : convertToLiteral(valueType, parameterValues.get(i)));
        }

        // The parent step's data table is passed on after its values, as dataTable
        ParentDataTable parentDataTable = hasDataTable
                ? parentDataTable(parentStep, compositeMethodName, baseCompositeMethod, parameterValues.size())
                : null;
        if (parentDataTable != null) {
            parameterTypes.add(parentDataTable.type());
            parameterNames.add(DATA_TABLE_REFERENCE_NAME);
        }
        // The parent step's DocString is passed on after its values, as docString
        if (hasDocString) {
            parameterTypes.add(ClassName.get(String.class));
            parameterNames.add(DOC_STRING_REFERENCE_NAME);
        }
        ParentStep parent = new ParentStep(valueClasses, parentDataTable, hasDocString);

        // Generate composite method
        MethodSpec compositeMethod = generateCompositeMethod(parentStep, compositeMethodName, stepPattern,
                parameterValues, parameterTypes, parameterNames, effectiveAnnotation);

        // Add composite method to class if it doesn't already exist
        if (baseCompositeMethod == null && allMethodSpecs.stream().noneMatch(m -> m.name.equals(compositeMethodName))) {
            classBuilder.addMethod(compositeMethod);
        }

        // Add composite method to scenario steps list so that sub-steps can inherit from it
        scenarioStepsMethodSpecs.add(compositeMethod);

        // Track the parent step's keyword for And/But/* inheritance
        resolvedStepKeywords.add(resolvedParentKeyword);

        // The parent step's data table or DocString is built like the one of a regular step
        CodeBlock dataTableOrDocStringArgument = null;
        if (parentDataTable != null) {
            dataTableOrDocStringArgument = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType)
                    .withDataTableRowType(parentDataTable.givenRowType())
                    .withDataTableRecordName(parentDataTable.recordName())
                    .buildDataTableArgument(parentStep, compositeMethodName, parameterValues,
                            scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes);
        } else if (hasDocString) {
            dataTableOrDocStringArgument = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType)
                    .buildDocStringArgument(parentStep, parameterValues,
                            scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes);
        }

        // Generate sub-step methods and calls
        List<CodeBlock> subStepCalls = new ArrayList<>();
        for (Step subStep : subSteps) {
            MethodSpec subStepMethod;

            validateReferences(subStep, parent);

            // Use StepProcessor for sub-steps; a quoted reference alone is a parameter of the referred value's type,
            // and references in the sub-step's values and data table cells become Java expressions
            StepProcessor stepProcessor = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType);

            // A sub-step taking "<$dataTable>" is generated like the same step written with the parent step's data
            // table as its own, and is called with the data table its lambda receives
            Step generatedSubStep = subStep;
            String textWithoutDataTable = CompositeStepTypeResolver.textWithoutDataTableReference(subStep);
            if (textWithoutDataTable != null) {
                generatedSubStep = new Step(subStep.getLocation(), subStep.getKeyword(),
                        subStep.getKeywordType().orElse(null), textWithoutDataTable, null,
                        parentStep.getDataTable().get(), subStep.getId());
                stepProcessor.withDataTablePassedAs(parentDataTable.type(), DATA_TABLE_REFERENCE_NAME);
            }

            // Likewise, a sub-step without a DocString of its own taking "<$docString>" is generated like the same step
            // written with the parent step's DocString as its own, and is called with the DocString its lambda receives
            String textWithoutDocString = CompositeStepTypeResolver.textWithoutDocStringReference(subStep);
            if (textWithoutDocString != null && hasDocString) {
                generatedSubStep = new Step(subStep.getLocation(), subStep.getKeyword(),
                        subStep.getKeywordType().orElse(null), textWithoutDocString, parentStep.getDocString().get(),
                        null, subStep.getId());
                stepProcessor.withDocStringPassedAs(DOC_STRING_REFERENCE_NAME);
            }

            stepProcessor
                    .withParameterTypeOverrides(parameterTypeOverrides(generatedSubStep, parent))
                    .withParentStepReferences(new SubStepReferences(generatedSubStep, parent));
            subStepMethod = stepProcessor.processStep(
                    generatedSubStep, null, scenarioStepsMethodSpecs,
                    resolvedStepKeywords,
                    scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes
            );

            subStepCalls.add(stepProcessor.getStepCall());
            scenarioStepsMethodSpecs.add(subStepMethod);

            // Add sub-step method to class if needed
            String subStepMethodName = subStepMethod.name;
            if (allMethodSpecs.stream().noneMatch(m -> m.name.equals(subStepMethodName))
                    && !baseClassMethodNames.contains(subStepMethodName)) {
                classBuilder.addMethod(subStepMethod);
            }
        }

        // Generate lambda call in scenario method
        generateLambdaCall(scenarioMethodBuilder, parentStep, compositeMethodName, parentArguments,
                dataTableOrDocStringArgument, parameterNames, subSteps, subStepCalls);
    }

    /**
     * Returns the index of the Scenario Outline parameter a value is the placeholder of, e.g. "<name>", or -1.
     */
    private static int scenarioParameterIndex(String value, List<String> scenarioParameterNames) {
        if (scenarioParameterNames == null || value.length() < 3 || !value.startsWith("<") || !value.endsWith(">")) {
            return -1;
        }
        return scenarioParameterNames.indexOf(value.substring(1, value.length() - 1));
    }

    /**
     * Finds the composite step method in the base class that the parent step matches like a regular step method: by
     * name, by the number of parameters (the parent step's values, its data table or DocString and the varargs
     * composite) and by the types the parent step's literals can be converted to.
     */
    private ElementMethodUtils.MethodSignature findBaseCompositeMethod(String methodName, List<String> parameterValues,
                                                                      boolean hasDataTableOrDocString) {
        int valueCount = parameterValues.size();
        int parameterCount = valueCount + (hasDataTableOrDocString ? 1 : 0) + 1;
        return baseClassMethodSignatures.getOrDefault(methodName, List.of()).stream()
                .filter(signature -> signature.getParameterCount() == parameterCount)
                .filter(signature -> signature.getParameterType(parameterCount - 1).getKind() == TypeKind.ARRAY)
                .filter(signature -> IntStream.range(0, valueCount).allMatch(i ->
                        ParameterConversionUtils.canConvert(parameterValues.get(i), signature.getParameterType(i))))
                .findFirst()
                .orElse(null);
    }

    /**
     * What the sub-steps of a composite step can refer to: the parent step's values, received as p1, p2 and p3, and
     * the parent step's data table or DocString, received as dataTable or docString.
     *
     * @param valueClasses the types of the parent step's values
     * @param dataTable the parent step's data table, or null when it has none
     * @param hasDocString whether the parent step has a DocString
     */
    private record ParentStep(List<Class<?>> valueClasses, ParentDataTable dataTable, boolean hasDocString) {
    }

    /**
     * The data table of a parent step.
     *
     * @param type the type of the data table parameter
     * @param givenRowType the row type the data table is built with, when the generator doesn't find it itself
     * @param recordName the record name of the data table, in LIST_OF_OBJECT_PARAMS mode
     * @param columns the column names, as written in the header row
     * @param dataRowCount the number of data rows
     * @param columnReaders how each column's cells are read, by column name
     */
    private record ParentDataTable(TypeName type, TypeElement givenRowType, String recordName, List<String> columns,
                                   int dataRowCount, Map<String, ColumnReader> columnReaders) {
    }

    /**
     * How the cells of a column of a parent step's data table are read: the expression of the rows, followed by the
     * row number and the access to the cell, and the cell's type.
     *
     * @param rowsExpression the expression of the data table's rows, e.g. dataTable or dataTable.asMaps()
     * @param cellAccess the access to the cell on a row, e.g. .email() or .get("email"); null when there is none
     * @param type the type of the cell
     * @param missingAccess why the cell can't be read, when there is no access to it
     */
    private record ColumnReader(String rowsExpression, String cellAccess, Class<?> type, String missingAccess) {

        String expressionFor(int rowIndex) {
            return rowsExpression + ".get(" + rowIndex + ")" + cellAccess;
        }
    }

    /**
     * A reference resolved to the Java expression of the value it refers to and the value's type.
     */
    private record ResolvedReference(String expression, Class<?> type) {
    }

    private ParentDataTable parentDataTable(Step parentStep, String compositeMethodName,
                                            ElementMethodUtils.MethodSignature baseCompositeMethod, int valueCount) {
        List<TableRow> rows = parentStep.getDataTable().get().getRows();
        List<String> columns = rows.getFirst().getCells().stream().map(cell -> cell.getValue().trim()).toList();
        int dataRowCount = rows.size() - 1;
        Map<String, ColumnReader> columnReaders = new LinkedHashMap<>();
        String dataTableType = options.getDataTableParameterType();

        if (LIST_OF_MAPS.name().equals(dataTableType)) {
            for (String column : columns) {
                columnReaders.put(column, new ColumnReader(DATA_TABLE_REFERENCE_NAME, mapGet(column), String.class, null));
            }
            TypeName mapType = ParameterizedTypeName.get(Map.class, String.class, String.class);
            return new ParentDataTable(ParameterizedTypeName.get(ClassName.get(List.class), mapType), null, null,
                    columns, dataRowCount, columnReaders);
        }

        if (!LIST_OF_OBJECT_PARAMS.name().equals(dataTableType)) {
            // CUCUMBER_DATA_TABLE: cells are read through the data table's maps
            for (String column : columns) {
                columnReaders.put(column,
                        new ColumnReader(DATA_TABLE_REFERENCE_NAME + ".asMaps()", mapGet(column), String.class, null));
            }
            return new ParentDataTable(ClassName.get(DataTable.class), null, null, columns, dataRowCount, columnReaders);
        }

        // A composite step method in the base class gives the row type; otherwise a row type of the same name in the
        // base class hierarchy, or the generated row type, is used, as for the data table of a regular step. The data
        // table is named after the parent step, or after the sub-step taking it as "<$dataTable>".
        TypeElement givenRowType = baseCompositeMethod != null
                ? listTypeArgument(baseCompositeMethod.getParameterType(valueCount))
                : null;
        String recordName = dataTableCollector.getCompositeStepRecordName(compositeMethodName) != null
                ? dataTableCollector.getCompositeStepRecordName(compositeMethodName)
                : dataTableCollector.deriveRecordNameFromStepText(parentStep.getKeyword() + parentStep.getText());
        RecordMetadata recordMetadata = dataTableCollector.getRecordMetadataMap().get(recordName);
        TypeElement rowType = givenRowType != null || recordMetadata == null || !recordMetadata.hasExistingType()
                ? givenRowType
                : recordMetadata.getExistingType();

        if (rowType != null) {
            for (String column : columns) {
                columnReaders.put(column, existingRowTypeColumnReader(rowType, fieldNameFor(rowType, column, columns)));
            }
            ClassName rowTypeName = ClassName.get("", rowType.getSimpleName().toString());
            return new ParentDataTable(ParameterizedTypeName.get(ClassName.get(List.class), rowTypeName), givenRowType,
                    recordName, columns, dataRowCount, columnReaders);
        }

        for (String column : columns) {
            String cellAccess = "." + ParameterNamingUtils.toMethodParameterName(column) + "()";
            columnReaders.put(column,
                    new ColumnReader(DATA_TABLE_REFERENCE_NAME, cellAccess, generatedColumnClass(recordMetadata, column), null));
        }
        return new ParentDataTable(ParameterizedTypeName.get(ClassName.get(List.class), ClassName.get("", recordName)),
                null, recordName, columns, dataRowCount, columnReaders);
    }

    private static String mapGet(String column) {
        return ".get(\"" + escapeForJavaStringLiteral(column) + "\")";
    }

    private TypeElement listTypeArgument(TypeMirror type) {
        return ElementMethodUtils.isListOfCustomObjectType(type, processingEnv)
                ? ElementMethodUtils.extractListTypeArgument(type)
                : null;
    }

    /**
     * Returns the class of a column of a generated row type, as typed when the data tables were collected.
     */
    private static Class<?> generatedColumnClass(RecordMetadata recordMetadata, String column) {
        int columnIndex = recordMetadata != null ? recordMetadata.getColumnNames().indexOf(column) : -1;
        String columnType = columnIndex >= 0 ? recordMetadata.getColumnTypes().get(columnIndex) : "String";
        return switch (columnType) {
            case "Boolean" -> Boolean.class;
            case "Integer" -> Integer.class;
            case "Long" -> Long.class;
            case "Double" -> Double.class;
            case "Character" -> Character.class;
            default -> String.class;
        };
    }

    /**
     * Returns the name of the field of a row type from the base class that holds a column's cells: the constructor
     * parameter the column maps to, or the column name made into an identifier.
     */
    private static String fieldNameFor(TypeElement rowType, String column, List<String> columns) {
        ExecutableElement constructor = InnerTypeUtils.findAllArgsConstructor(rowType);
        if (constructor != null) {
            List<String> constructorParams = InnerTypeUtils.getConstructorParameterNames(constructor, rowType);
            ConstructorMappingUtils.MappingResult mapping =
                    ConstructorMappingUtils.tryMapColumnsToConstructor(columns, constructorParams);
            for (Map.Entry<Integer, String> paramColumn : mapping.getParamIndexToColumnName().entrySet()) {
                if (column.equals(paramColumn.getValue())) {
                    return constructorParams.get(paramColumn.getKey());
                }
            }
        }
        return ParameterNamingUtils.toMethodParameterName(column);
    }

    /**
     * Returns how a column's cells are read from a row type from the base class: through the first of a fieldName()
     * method, a getFieldName() method (or isFieldName() for a boolean field) and a non-private field that exists.
     */
    private ColumnReader existingRowTypeColumnReader(TypeElement rowType, String fieldName) {
        List<? extends Element> members = processingEnv.getElementUtils().getAllMembers(rowType);
        String capitalized = Character.toUpperCase(fieldName.charAt(0)) + fieldName.substring(1);
        VariableElement field = members.stream()
                .filter(member -> member.getKind() == ElementKind.FIELD && member.getSimpleName().contentEquals(fieldName))
                .map(VariableElement.class::cast)
                .findFirst()
                .orElse(null);
        boolean booleanField = field != null && (field.asType().getKind() == TypeKind.BOOLEAN
                || "java.lang.Boolean".equals(field.asType().toString()));

        List<String> accessorNames = booleanField
                ? List.of(fieldName, "get" + capitalized, "is" + capitalized)
                : List.of(fieldName, "get" + capitalized);
        for (String accessorName : accessorNames) {
            ExecutableElement accessor = members.stream()
                    .filter(member -> member.getKind() == ElementKind.METHOD
                            && member.getSimpleName().contentEquals(accessorName)
                            && !member.getModifiers().contains(Modifier.PRIVATE)
                            && !member.getModifiers().contains(Modifier.STATIC))
                    .map(ExecutableElement.class::cast)
                    .filter(method -> method.getParameters().isEmpty())
                    .findFirst()
                    .orElse(null);
            if (accessor != null) {
                return new ColumnReader(DATA_TABLE_REFERENCE_NAME, "." + accessorName + "()",
                        CompositeStepTypeResolver.classOf(accessor.getReturnType()), null);
            }
        }
        if (field != null && !field.getModifiers().contains(Modifier.PRIVATE)) {
            return new ColumnReader(DATA_TABLE_REFERENCE_NAME, "." + fieldName,
                    CompositeStepTypeResolver.classOf(field.asType()), null);
        }

        String methods = booleanField
                ? fieldName + "(), get" + capitalized + "() or is" + capitalized + "()"
                : fieldName + "() or get" + capitalized + "()";
        return new ColumnReader(DATA_TABLE_REFERENCE_NAME, null, null, rowType.getSimpleName() + " has no " + methods
                + " method and no non-private " + fieldName + " field to read it with");
    }

    /**
     * Returns the types of a sub-step's quoted values that are a reference alone, by position, with null for the other
     * quoted values.
     */
    private List<Class<?>> parameterTypeOverrides(Step subStep, ParentStep parent) {
        List<Class<?>> overrides = new ArrayList<>();
        for (String value : extractParameterValues(subStep.getKeyword() + " " + subStep.getText())) {
            Class<?> override = null;
            Matcher reference = referencePattern.matcher(value);
            if (reference.matches() && reference.group("escape") == null
                    && !DATA_TABLE_REFERENCE_NAME.equals(reference.group("name"))) {
                override = resolveReference(reference, subStep, parent).type();
            }
            overrides.add(override);
        }
        return overrides;
    }

    /**
     * Returns the Cucumber annotation (@Given, @When or @Then) matching the keyword a step resolved to.
     */
    private static Class<?> annotationFor(ResolvedStepKeyword resolvedStepKeyword) {
        return switch (resolvedStepKeyword.gwtKeyword()) {
            case "given" -> Given.class;
            case "when" -> When.class;
            default -> Then.class;
        };
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

    private MethodSpec generateCompositeMethod(Step parentStep, String methodName, String stepPattern,
                                               List<String> parameterValues, List<TypeName> parameterTypes,
                                               List<String> parameterNames, Class<?> effectiveAnnotation) {
        MethodSpec.Builder methodBuilder = MethodSpec.methodBuilder(methodName)
                .addModifiers(Modifier.PROTECTED);

        // Add Cucumber annotation if option is enabled
        if (options.isAddCucumberStepAnnotations()) {
            String stepPatternAfterKeyword = StepKeywordUtils.textAfterKeyword(stepPattern, parentStep.getKeyword());
            AnnotationSpec annotationSpec = buildCucumberAnnotation(effectiveAnnotation, stepPatternAfterKeyword, parameterValues);
            methodBuilder.addAnnotation(annotationSpec);
        }

        // Add parameters from parent step: its values and its data table
        for (int i = 0; i < parameterTypes.size(); i++) {
            methodBuilder.addParameter(parameterTypes.get(i), parameterNames.get(i));
        }

        // Add varargs Consumer parameter
        TypeName consumerType = getConsumerType(parameterTypes);
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
        if (parameterNames.isEmpty()) {
            // Runnable has run() method
            bodyBuilder.addStatement("stream(composite).forEach(r -> r.run())");
        } else {
            // Consumer/BiConsumer/TriConsumer have accept() method
            bodyBuilder.addStatement("stream(composite).forEach(action -> action.accept($L))",
                    String.join(", ", parameterNames));
        }

        bodyBuilder.nextControlFlow("else");
        bodyBuilder.addStatement("$T.fail($S)", Assertions.class, "Step is not yet implemented");
        bodyBuilder.endControlFlow();

        methodBuilder.addCode(bodyBuilder.build());

        return methodBuilder.build();
    }

    private TypeName getConsumerType(List<TypeName> parameterTypes) {
        TypeName[] typeArguments = parameterTypes.toArray(new TypeName[0]);
        return switch (parameterTypes.size()) {
            case 0 -> ClassName.get(Runnable.class);
            case 1 -> ParameterizedTypeName.get(ClassName.get(Consumer.class), typeArguments);
            case 2 -> ParameterizedTypeName.get(ClassName.get(BiConsumer.class), typeArguments);
            case 3 -> ParameterizedTypeName.get(ClassName.get(TriConsumer.class), typeArguments);
            case 4 -> ParameterizedTypeName.get(ClassName.get(QuadConsumer.class), typeArguments);
            case 5 -> ParameterizedTypeName.get(ClassName.get(PentaConsumer.class), typeArguments);
            default -> throw new ProcessingException(
                    "Composite steps with " + parameterTypes.size() + " parameters not yet supported. " +
                            "Only 0-5 parameters are currently supported."
            );
        };
    }

    private void generateLambdaCall(
            MethodSpec.Builder scenarioMethodBuilder,
            Step parentStep,
            String compositeMethodName,
            List<String> parentArguments,
            CodeBlock dataTableOrDocStringArgument,
            List<String> lambdaParameterNames,
            List<Step> subSteps,
            List<CodeBlock> subStepCalls) {

        // Add block comment for the composite step, rendered like a regular step's comment
        scenarioMethodBuilder.addCode("/*");
        StepProcessor.appendStepCommentLines(scenarioMethodBuilder, parentStep, options);
        scenarioMethodBuilder.addCode("\n */\n");

        // Method name and the parent step's values, as literals of their types, followed by its data table or DocString;
        // $L keeps JavaPoet from interpreting the $ signs in them. Up to the lambda's opening brace, the call is a
        // statement, so that the lines of a data table or DocString are indented like in a regular step's call.
        CodeBlock.Builder callBuilder = CodeBlock.builder();
        callBuilder.add("$[");
        callBuilder.add("$L(", compositeMethodName);
        callBuilder.add("$L", String.join(", ", parentArguments));
        if (dataTableOrDocStringArgument != null) {
            callBuilder.add("$L", dataTableOrDocStringArgument);
        }

        // Lambda expression
        if (!lambdaParameterNames.isEmpty()) {
            callBuilder.add(", ");
        }
        callBuilder.add("($L) -> {\n", String.join(", ", lambdaParameterNames));
        callBuilder.add("$]");

        // Sub-step calls, each preceded by its comment
        callBuilder.indent();
        for (int i = 0; i < subSteps.size(); i++) {
            appendSubStepComment(callBuilder, subSteps.get(i));
            callBuilder.addStatement("$L", subStepCalls.get(i));
        }
        callBuilder.unindent();

        callBuilder.add("});\n");
        scenarioMethodBuilder.addCode(callBuilder.build());
    }

    /**
     * Appends the block comment for a sub-step call inside the composite lambda: the sub-step line as written in the
     * spec, followed by its data table rows as in a regular step's comment.
     */
    private void appendSubStepComment(CodeBlock.Builder callBuilder, Step subStep) {
        callBuilder.add("/*\n");
        callBuilder.add(" * $L\n", subStep.getKeyword() + subStep.getText());
        for (String tableLine : StepProcessor.dataTableCommentLines(subStep, options)) {
            callBuilder.add(" *   $L\n", tableLine);
        }
        callBuilder.add(" */\n");
    }

    /**
     * The references of one sub-step to its parent step, whose values and data table the sub-step's lambda receives
     * as p1, p2, p3 and dataTable:
     * - "<$p1>" alone passes the lambda parameter p1, and "<$email>" the email cell of the data table's single row
     * - "CUST-<$p1>" passes the quoted text with the reference replaced, "CUST-<$p1>".replace("<$p1>", p1)
     * - an escaped reference (\<$p1>) is written as the literal text <$p1>
     */
    private final class SubStepReferences implements StepProcessor.ParentStepReferences {

        private final Step subStep;
        private final ParentStep parent;

        private SubStepReferences(Step subStep, ParentStep parent) {
            this.subStep = subStep;
            this.parent = parent;
        }

        @Override
        public StepProcessor.ValueExpression expressionFor(String value) {
            Matcher wholeReference = referencePattern.matcher(value);
            if (wholeReference.matches() && wholeReference.group("escape") == null) {
                return new StepProcessor.ValueExpression(
                        CodeBlock.of("$L", resolveReference(wholeReference, subStep, parent).expression()), false);
            }
            TextReplacement replacement = replaceReferences(value, false);
            if (replacement == null) {
                return null;
            }
            boolean replacesReferences = !replacement.calls().isEmpty();
            return new StepProcessor.ValueExpression(
                    CodeBlock.of("$S$L", replacement.text(), replacement.calls()), replacesReferences);
        }

        @Override
        public StepProcessor.TextReplacements textReplacementsFor(String text) {
            TextReplacement replacement = replaceReferences(text, true);
            return replacement != null
                    ? new StepProcessor.TextReplacements(replacement.text(), replacement.calls())
                    : null;
        }

        /**
         * Returns the text with the calls that replace the references it holds, or null when it holds no references,
         * escaped or not. Each reference is replaced once, in order of first appearance, with .replace(...). A reference
         * the text also holds escaped can't be told apart from its escaped form that way, so for it the escape stays in
         * the text: the reference is replaced with .replaceAll(...) where no backslash comes before it, and the backslash
         * is removed after the other replacements. Other escaped references are written as the text they stand for.
         *
         * @param text the quoted value, data table cell, DocString content or data table text
         * @param inTextBlock whether the text is written as a text block, which holds Java escape sequences, with each
         *                    call on a line of its own; otherwise the text is a String literal followed by the calls
         */
        private TextReplacement replaceReferences(String text, boolean inTextBlock) {
            Map<String, ResolvedReference> references = new LinkedHashMap<>();
            Set<String> escapedReferences = new LinkedHashSet<>();
            Matcher reference = referencePattern.matcher(text);
            while (reference.find()) {
                if (reference.group("escape") != null) {
                    escapedReferences.add(reference.group().substring(1));
                } else if (!references.containsKey(reference.group())) {
                    references.put(reference.group(), resolveReference(reference, subStep, parent));
                }
            }
            if (references.isEmpty() && escapedReferences.isEmpty()) {
                return null;
            }
            Set<String> keptEscapes = new LinkedHashSet<>(escapedReferences);
            keptEscapes.retainAll(references.keySet());

            StringBuilder result = new StringBuilder();
            reference.reset();
            int from = 0;
            while (reference.find()) {
                result.append(text, from, reference.start());
                String referenceText = reference.group("escape") != null ? reference.group().substring(1) : reference.group();
                if (reference.group("escape") != null && keptEscapes.contains(referenceText)) {
                    result.append(inTextBlock ? "\\\\" : "\\");
                }
                result.append(referenceText);
                from = reference.end();
            }
            result.append(text.substring(from));

            // The parent step's DocString goes in last, so that no other replacement changes the text it brings in
            String callStart = inTextBlock ? "\n" : "";
            String docStringReference = "<$" + DOC_STRING_REFERENCE_NAME + ">";
            CodeBlock.Builder calls = CodeBlock.builder();
            for (Map.Entry<String, ResolvedReference> resolved : references.entrySet()) {
                if (!resolved.getKey().equals(docStringReference)) {
                    addReplacementCall(calls, callStart, resolved.getKey(), resolved.getValue(), keptEscapes);
                }
            }
            for (String keptEscape : keptEscapes) {
                if (!keptEscape.equals(docStringReference)) {
                    calls.add(callStart + ".replace($S, $S)", "\\" + keptEscape, keptEscape);
                }
            }
            if (references.containsKey(docStringReference)) {
                addReplacementCall(calls, callStart, docStringReference, references.get(docStringReference), keptEscapes);
                if (keptEscapes.contains(docStringReference)) {
                    calls.add(callStart + ".replace($S, $S)", "\\" + docStringReference, docStringReference);
                }
            }
            return new TextReplacement(result.toString(), calls.build());
        }

        /**
         * Adds the call that replaces a reference with its value: .replace(...), or .replaceAll(...) where no backslash
         * comes before the reference when the text also holds it escaped.
         */
        private static void addReplacementCall(CodeBlock.Builder calls, String callStart, String reference,
                                               ResolvedReference resolved, Set<String> keptEscapes) {
            String value = resolved.type() == String.class ? resolved.expression() : resolved.expression() + ".toString()";
            if (keptEscapes.contains(reference)) {
                calls.add(callStart + ".replaceAll($S, $T.quoteReplacement($L))",
                        "(?<!\\\\)" + escapeForRegex(reference), Matcher.class, value);
            } else {
                calls.add(callStart + ".replace($S, $L)", reference, value);
            }
        }
    }

    /**
     * A text with the calls that replace its references at runtime.
     */
    private record TextReplacement(String text, CodeBlock calls) {
    }

    /**
     * Returns the text as a regular expression that matches it literally, with a backslash before each character
     * that has a meaning in regular expressions.
     */
    private static String escapeForRegex(String text) {
        StringBuilder result = new StringBuilder();
        for (char c : text.toCharArray()) {
            if ("\\^$.|?*+()[]{}".indexOf(c) >= 0) {
                result.append('\\');
            }
            result.append(c);
        }
        return result.toString();
    }

    /**
     * Checks the references of a sub-step to its parent step before the sub-step is generated: references in its
     * data table must be in data rows, its DocString can't hold the whole data table, and all of them must match a
     * value or data table column of the parent step. Outside double quotes, the sub-step's text holds no references.
     */
    private void validateReferences(Step subStep, ParentStep parent) {
        String text = subStep.getText();

        // The quoted values of the text, as the ranges they take up
        List<int[]> quotedRanges = new ArrayList<>();
        Matcher quotedValue = parameterPattern.matcher(text);
        while (quotedValue.find()) {
            quotedRanges.add(new int[]{quotedValue.start(), quotedValue.end()});
        }

        Matcher reference = referencePattern.matcher(text);
        while (reference.find()) {
            if (reference.group("escape") != null) {
                continue;
            }
            int[] quotedRange = quotedRanges.stream()
                    .filter(range -> range[0] < reference.start() && reference.end() < range[1])
                    .findFirst()
                    .orElse(null);
            if (quotedRange == null) {
                // Outside double quotes, a reference is plain step text
                continue;
            }
            if (DATA_TABLE_REFERENCE_NAME.equals(reference.group("name")) && reference.group("rowNumber") == null) {
                validateDataTableReferencePlacement(subStep, parent, reference, quotedRange);
            } else {
                resolveReference(reference, subStep, parent);
            }
        }

        if (subStep.getDataTable().isPresent()) {
            validateDataTableReferences(subStep, parent);
        }
        if (subStep.getDocString().isPresent()) {
            validateDocStringReferences(subStep, parent);
        }
    }

    /**
     * Checks that "<$dataTable>" stands alone in double quotes at the end of a sub-step's text, in place of a data
     * table of its own, under a parent step with a data table.
     */
    private void validateDataTableReferencePlacement(Step subStep, ParentStep parent, Matcher reference,
                                                     int[] quotedRange) {
        String text = subStep.getText();
        String subStepLine = "Sub-step on line - " + subStep.getLocation().getLine();
        if (quotedRange[0] != reference.start() - 1 || quotedRange[1] != reference.end() + 1) {
            throw new ProcessingException(subStepLine + " has " + reference.group()
                    + " together with other text in double quotes; " + DATA_TABLE_PLACEMENT);
        }
        if (!text.substring(quotedRange[1]).isBlank()) {
            throw new ProcessingException(subStepLine + " has \"" + reference.group() + "\" in the middle of its text; "
                    + DATA_TABLE_PLACEMENT);
        }
        if (subStep.getDataTable().isPresent()) {
            throw new ProcessingException(subStepLine + " has a data table of its own and \"" + reference.group()
                    + "\"; " + DATA_TABLE_PLACEMENT);
        }
        if (parent.dataTable() == null) {
            // Under a parent step without a data table, <$dataTable> matches nothing
            resolveReference(reference, subStep, parent);
        }
    }

    private void validateDataTableReferences(Step subStep, ParentStep parent) {
        List<TableRow> rows = subStep.getDataTable().get().getRows();
        for (int rowIndex = 0; rowIndex < rows.size(); rowIndex++) {
            for (TableCell cell : rows.get(rowIndex).getCells()) {
                Matcher reference = referencePattern.matcher(cell.getValue());
                while (reference.find()) {
                    if (reference.group("escape") != null) {
                        continue;
                    }
                    if (DATA_TABLE_REFERENCE_NAME.equals(reference.group("name"))) {
                        throw new ProcessingException("Sub-step on line - " + subStep.getLocation().getLine()
                                + " has " + reference.group() + " in a data table cell; " + DATA_TABLE_PLACEMENT);
                    } else if (DOC_STRING_REFERENCE_NAME.equals(reference.group("name"))
                            && !LIST_OF_OBJECT_PARAMS.name().equals(options.getDataTableParameterType())) {
                        // Data tables passed as text are parsed again, which the line breaks or | of a DocString break
                        throw new ProcessingException("Sub-step on line - " + subStep.getLocation().getLine()
                                + " has " + reference.group() + " in a data table cell, which isn't supported with the "
                                + options.getDataTableParameterType() + " data table type");
                    } else if (rowIndex == 0) {
                        throw new ProcessingException("Sub-step on line - " + subStep.getLocation().getLine()
                                + " has the reference " + reference.group()
                                + " in a header cell of its data table; references are allowed in data rows only");
                    } else {
                        resolveReference(reference, subStep, parent);
                    }
                }
            }
        }
    }

    private void validateDocStringReferences(Step subStep, ParentStep parent) {
        Matcher reference = referencePattern.matcher(subStep.getDocString().get().getContent());
        while (reference.find()) {
            if (reference.group("escape") != null) {
                continue;
            }
            if (DATA_TABLE_REFERENCE_NAME.equals(reference.group("name")) && reference.group("rowNumber") == null) {
                throw new ProcessingException("Sub-step on line - " + subStep.getLocation().getLine()
                        + " has " + reference.group() + " in its DocString; " + DATA_TABLE_PLACEMENT);
            }
            resolveReference(reference, subStep, parent);
        }
    }

    /**
     * Resolves a reference to the parent step: <$pN> to its N-th value, <$column> to the column's cell in the data
     * table's single data row, <$column[n]> to the column's cell in data row n, and <$docString> to its DocString;
     * fails when the reference matches nothing in the parent step, or matches it in a way that can't be resolved.
     */
    private ResolvedReference resolveReference(Matcher reference, Step subStep, ParentStep parent) {
        String name = reference.group("name");
        String rowNumber = reference.group("rowNumber");
        String subStepLine = "Sub-step on line - " + subStep.getLocation().getLine();
        ParentDataTable dataTable = parent.dataTable();

        Matcher parentValueName = parentValueNamePattern.matcher(name);
        int valueNumber = rowNumber == null && parentValueName.matches() ? Integer.parseInt(parentValueName.group("number")) : 0;
        boolean isValue = valueNumber >= 1 && valueNumber <= parent.valueClasses().size();
        boolean isColumn = dataTable != null && dataTable.columns().contains(name);

        if (isValue && isColumn) {
            throw new ProcessingException(subStepLine + " refers to " + reference.group() + ", which is ambiguous: it is"
                    + " both the parent step's " + ORDINALS.get(valueNumber - 1) + " value and a column of its data table");
        }
        if (isValue) {
            return new ResolvedReference("p" + valueNumber, parent.valueClasses().get(valueNumber - 1));
        }
        if (isColumn) {
            int dataRowCount = dataTable.dataRowCount();
            int row = 1;
            if (rowNumber == null) {
                if (dataRowCount != 1) {
                    throw new ProcessingException(subStepLine + " refers to " + reference.group() + ", which is"
                            + " ambiguous as the parent step's data table has " + dataRowCount + " data rows; use <$"
                            + name + "[n]> with n from 1 to " + dataRowCount);
                }
            } else {
                String number = rowNumber.substring(1, rowNumber.length() - 1);
                if (!number.matches("[1-9]\\d{0,8}") || Integer.parseInt(number) > dataRowCount) {
                    throw new ProcessingException(subStepLine + " refers to " + reference.group() + "; write the row"
                            + " number as a whole number from 1 to " + dataRowCount + ", without spaces");
                }
                row = Integer.parseInt(number);
            }
            ColumnReader columnReader = dataTable.columnReaders().get(name);
            if (columnReader.cellAccess() == null) {
                throw new ProcessingException(subStepLine + " refers to " + reference.group() + ", but "
                        + columnReader.missingAccess());
            }
            return new ResolvedReference(columnReader.expressionFor(row - 1), columnReader.type());
        }
        if (DOC_STRING_REFERENCE_NAME.equals(name) && rowNumber == null && parent.hasDocString()) {
            return new ResolvedReference(DOC_STRING_REFERENCE_NAME, String.class);
        }
        throw new ProcessingException(subStepLine + " refers to " + reference.group() + ", which matches no value or"
                + " data table column of its parent step; available references: " + availableReferences(parent));
    }

    private static final List<String> ORDINALS = List.of("first", "second", "third", "fourth", "fifth");

    private static String availableReferences(ParentStep parent) {
        List<String> references = new ArrayList<>();
        for (int i = 1; i <= parent.valueClasses().size(); i++) {
            references.add("<$p" + i + ">");
        }
        if (parent.dataTable() != null) {
            for (String column : parent.dataTable().columns()) {
                references.add("<$" + column + ">");
            }
            references.add("<$" + DATA_TABLE_REFERENCE_NAME + ">");
        }
        if (parent.hasDocString()) {
            references.add("<$" + DOC_STRING_REFERENCE_NAME + ">");
        }
        return references.isEmpty() ? "none" : String.join(", ", references);
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
        } else if (typeString.equals("float") || typeString.equals("java.lang.Float")) {
            try {
                Float.parseFloat(value);
                return value + "F";
            } catch (NumberFormatException e) {
                // Fall through to default string literal
            }
        } else if (typeString.equals("byte") || typeString.equals("java.lang.Byte")) {
            try {
                Byte.parseByte(value);
                return "(byte) " + value;
            } catch (NumberFormatException e) {
                // Fall through to default string literal
            }
        } else if (typeString.equals("short") || typeString.equals("java.lang.Short")) {
            try {
                Short.parseShort(value);
                return "(short) " + value;
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
    private AnnotationSpec buildCucumberAnnotation(Class<?> annotationClass, String stepPatternAfterKeyword,
                                                   List<String> parameterValues) {
        // Build the annotation value with regex pattern
        // Replace $p1, $p2 with regex capture groups

        // Join the words of the step text by single spaces
        String stepText = String.join(" ", stepPatternAfterKeyword.split("\\s+"));

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
