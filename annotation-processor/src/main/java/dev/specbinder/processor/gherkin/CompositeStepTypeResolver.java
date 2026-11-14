package dev.specbinder.processor.gherkin;

import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.gherkin.utils.TypeInferenceUtils;
import dev.specbinder.processor.utils.ElementMethodUtils;
import dev.specbinder.processor.utils.MethodNamingUtils;
import dev.specbinder.processor.utils.ParameterConversionUtils;
import dev.specbinder.processor.utils.StepKeywordUtils;
import dev.specbinder.processor.utils.StepKeywordUtils.ResolvedStepKeyword;
import io.cucumber.messages.types.*;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.TypeMirror;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

/**
 * Works out the types of the values of composite steps before any code is generated, across all uses of each
 * composite step:
 * - a type fixed by a sub-step's step method in the base class, for a value the sub-step receives as "<$pN>", becomes
 *   the value's type; when sub-steps fix different types for one value, the type fixed first in the spec wins
 * - otherwise the type is inferred from the parent step's literals of all uses, widened like for regular steps
 * The columns of a composite step's data table are typed the same way: by the types sub-steps fix for the cells they
 * receive as "<$column>", or else from the cells of all uses. With the LIST_OF_OBJECT_PARAMS data table type, sub-steps
 * that fix different types for one column are a generator error.
 */
public class CompositeStepTypeResolver {

    private static final Pattern quotedValuePattern = Pattern.compile("\"(?<value>([^\"\\\\]|\\\\.)*?)\"");
    private static final Pattern wholeParentValueReferencePattern = Pattern.compile("<\\$p(?<number>[1-9]\\d*)>");
    private static final Pattern wholeReferencePattern =
            Pattern.compile("<\\$(?<name>[^<>\\[\\]\"]+?)(?<rowNumber>\\[[^\\]]*])?>");
    // The column types a generated data table row type can have
    private static final Set<String> COLUMN_TYPES = Set.of("Boolean", "Integer", "Long", "Double", "Character", "String");

    // "<$dataTable>" alone in double quotes at the end of a sub-step's text
    private static final Pattern dataTableReferenceAtEndPattern = Pattern.compile("^(?<text>.*?)\\s*\"<\\$dataTable>\"\\s*$");
    private static final Pattern docStringReferenceAtEndPattern = Pattern.compile("^(?<text>.*?)\\s*\"<\\$docString>\"\\s*$");

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final Map<String, List<ElementMethodUtils.MethodSignature>> baseClassMethodSignatures;
    // The composite step method name of each sub-step's parent step
    private final Map<Step, String> parentMethodNameBySubStep = new IdentityHashMap<>();
    // The value types of each composite step, by composite step method name
    private final Map<String, List<Class<?>>> valueTypesByMethod = new HashMap<>();
    // The composite step method name of each composite step's parent step
    private final Map<Step, String> parentMethodNameByParentStep = new IdentityHashMap<>();
    // The data table columns of each composite step, the cells of all uses by column, and the types sub-steps fix for
    // the columns, by composite step method name
    private final Map<String, List<String>> columnsByMethod = new HashMap<>();
    private final Map<String, Map<String, List<String>>> columnCellsByMethod = new HashMap<>();
    private final Map<String, Map<String, FixedType>> fixedColumnTypesByMethod = new HashMap<>();
    // The row type of each composite step's data table that sub-steps take as "<$dataTable>", by composite step method name
    private final Map<String, DataTableRowType> dataTableRowTypesByMethod = new HashMap<>();

    /**
     * The row type of a composite step's data table that sub-steps take as "<$dataTable>": named after the first of
     * these sub-steps in the spec, or the custom row type the step method in the base class of one of them takes.
     *
     * @param recordStepText the text of the first sub-step taking the data table, which names a generated row type
     * @param baseRowType the custom row type from the base class, or null
     * @param subStepMethodName the name of the sub-step method in the base class taking the custom row type, or null
     * @param line the line of the sub-step taking the custom row type, or 0
     */
    public record DataTableRowType(String recordStepText, TypeElement baseRowType, String subStepMethodName, long line) {
    }

    /**
     * A type a sub-step's step method in the base class fixes for a value it receives.
     */
    private record FixedType(Class<?> type, String methodName, long line) {
    }

    /**
     * Constructs a resolver for the composite steps of the spec files of a generated class.
     *
     * @param processingEnv the processing environment
     * @param options the generator options
     * @param baseType the base class of the generated class
     */
    public CompositeStepTypeResolver(ProcessingEnvironment processingEnv, GeneratorOptions options, TypeElement baseType) {
        this.processingEnv = processingEnv;
        this.options = options;
        this.baseClassMethodSignatures = baseType != null
                ? ElementMethodUtils.getAllInheritedMethodSignatures(processingEnv, baseType)
                : Map.of();
    }

    /**
     * Returns the key under which the value types of a composite step are kept among the pre-computed step types.
     *
     * @param compositeMethodName the name of the composite step method
     * @return the key for the composite step's value types
     */
    static String typesKey(String compositeMethodName) {
        return "composite step method " + compositeMethodName;
    }

    /**
     * Returns the steps of each scenario and background of the given spec files, in spec order.
     *
     * @param features the spec files' features
     * @return the steps of each scenario and background
     */
    public static List<List<Step>> stepListsOf(List<Feature> features) {
        List<List<Step>> stepLists = new ArrayList<>();
        for (FeatureChild child : features.stream().flatMap(feature -> feature.getChildren().stream()).toList()) {
            if (child.getScenario().isPresent()) {
                stepLists.add(child.getScenario().get().getSteps());
            }
            if (child.getRule().isPresent()) {
                for (RuleChild ruleChild : child.getRule().get().getChildren()) {
                    if (ruleChild.getScenario().isPresent()) {
                        stepLists.add(ruleChild.getScenario().get().getSteps());
                    }
                    if (ruleChild.getBackground().isPresent()) {
                        stepLists.add(ruleChild.getBackground().get().getSteps());
                    }
                }
            }
            if (child.getBackground().isPresent()) {
                stepLists.add(child.getBackground().get().getSteps());
            }
        }
        return stepLists;
    }

    /**
     * Returns the value types of each composite step in the given step lists, keyed by {@link #typesKey(String)}.
     *
     * @param stepLists the steps of each scenario and background, in spec order
     * @return the value types of each composite step
     */
    public Map<String, List<Class<?>>> resolve(List<List<Step>> stepLists) {
        Map<String, List<List<String>>> literalsByMethod = new LinkedHashMap<>();
        Map<String, Class<?>[]> fixedTypesByMethod = new HashMap<>();

        for (List<Step> steps : stepLists) {
            collectCompositeSteps(steps, literalsByMethod, fixedTypesByMethod);
        }

        Map<String, List<Class<?>>> result = new HashMap<>();
        for (Map.Entry<String, List<List<String>>> entry : literalsByMethod.entrySet()) {
            Class<?>[] fixedTypes = fixedTypesByMethod.get(entry.getKey());
            List<Class<?>> types = new ArrayList<>();
            for (int i = 0; i < fixedTypes.length; i++) {
                types.add(fixedTypes[i] != null ? fixedTypes[i] : widenedType(entry.getValue(), i));
            }
            valueTypesByMethod.put(entry.getKey(), types);
            result.put(typesKey(entry.getKey()), types);
        }
        return result;
    }

    /**
     * Returns the known column type of a data table cell of a composite step:
     * - for a parent step's cell, the type sub-steps fix for its column
     * - for a sub-step's cell that holds only a reference to its parent step, the type of the value or column it
     *   refers to, e.g. "Integer" for <$p2> when the parent step's second value is an Integer
     * Returns null for other cells, for the cells of other steps, and for types a data table column can't have.
     *
     * @param step the step the data table belongs to
     * @param column the cell's column
     * @param cellValue the cell's value
     * @return the cell's column type, or null
     */
    public String knownCellType(Step step, String column, String cellValue) {
        String parentMethodName = parentMethodNameByParentStep.get(step);
        if (parentMethodName != null) {
            FixedType fixedType = fixedColumnTypesByMethod.getOrDefault(parentMethodName, Map.of()).get(column);
            return fixedType != null ? columnTypeName(fixedType.type()) : null;
        }

        parentMethodName = parentMethodNameBySubStep.get(step);
        Matcher reference = wholeReferencePattern.matcher(cellValue.trim());
        if (parentMethodName == null || !reference.matches()) {
            return null;
        }
        Integer valueNumber = parentValueNumber(cellValue.trim());
        List<Class<?>> valueTypes = valueTypesByMethod.getOrDefault(parentMethodName, List.of());
        if (valueNumber != null && valueNumber <= valueTypes.size()) {
            return columnTypeName(valueTypes.get(valueNumber - 1));
        }
        String referredColumn = reference.group("name");
        FixedType fixedType = fixedColumnTypesByMethod.getOrDefault(parentMethodName, Map.of()).get(referredColumn);
        if (fixedType != null) {
            return columnTypeName(fixedType.type());
        }
        List<String> cells = columnCellsByMethod.getOrDefault(parentMethodName, Map.of()).get(referredColumn);
        return cells != null ? TypeInferenceUtils.inferTypeForColumn(cells) : null;
    }

    /**
     * Returns the composite step method name of a composite step's parent step, or null for other steps.
     *
     * @param step the step
     * @return the composite step method name, or null
     */
    public String compositeMethodNameOf(Step step) {
        return parentMethodNameByParentStep.get(step);
    }

    /**
     * Returns the row type of a composite step's data table that sub-steps take as "<$dataTable>", or null when no
     * sub-step takes it.
     *
     * @param compositeMethodName the composite step method name
     * @return the row type of the composite step's data table, or null
     */
    public DataTableRowType dataTableRowTypeOf(String compositeMethodName) {
        return dataTableRowTypesByMethod.get(compositeMethodName);
    }

    /**
     * Returns the text of a sub-step that ends with "<$dataTable>", without the reference, or null for other sub-steps.
     *
     * @param subStep the sub-step
     * @return the sub-step's text without "<$dataTable>", or null
     */
    static String textWithoutDataTableReference(Step subStep) {
        Matcher reference = dataTableReferenceAtEndPattern.matcher(subStep.getText());
        return reference.matches() ? reference.group("text") : null;
    }

    /**
     * Returns the text of a sub-step that ends with "<$docString>" and has no DocString of its own, without the
     * reference, or null for other sub-steps.
     *
     * @param subStep the sub-step
     * @return the sub-step's text without "<$docString>", or null
     */
    static String textWithoutDocStringReference(Step subStep) {
        Matcher reference = docStringReferenceAtEndPattern.matcher(subStep.getText());
        return reference.matches() && subStep.getDocString().isEmpty() ? reference.group("text") : null;
    }

    private static String columnTypeName(Class<?> type) {
        return type != null && COLUMN_TYPES.contains(type.getSimpleName()) ? type.getSimpleName() : null;
    }

    /**
     * Returns the number N of a text that is only a reference to a parent step value, written as <$pN>, or null.
     *
     * @param text the quoted value or data table cell
     * @return the number of the parent step value, or null
     */
    static Integer parentValueNumber(String text) {
        Matcher reference = wholeParentValueReferencePattern.matcher(text);
        return reference.matches() ? Integer.valueOf(reference.group("number")) : null;
    }

    private void collectCompositeSteps(List<Step> steps, Map<String, List<List<String>>> literalsByMethod,
                                       Map<String, Class<?>[]> fixedTypesByMethod) {
        List<ResolvedStepKeyword> resolvedStepKeywords = new ArrayList<>();
        for (Object item : ScenarioProcessor.detectCompositeStepGroups(steps)) {
            if (item instanceof CompositeStepGroup group) {
                ResolvedStepKeyword parentKeyword = resolveKeyword(group.getParentStep(), resolvedStepKeywords);
                if (parentKeyword == null) {
                    return;
                }
                List<String> literals = new ArrayList<>();
                String parentMethodName = stepMethodName(group.getParentStep(), parentKeyword, literals);
                parentMethodNameByParentStep.put(group.getParentStep(), parentMethodName);
                literalsByMethod.computeIfAbsent(parentMethodName, name -> new ArrayList<>()).add(literals);
                Class<?>[] fixedTypes = fixedTypesByMethod.computeIfAbsent(parentMethodName,
                        name -> new Class<?>[literals.size()]);
                collectColumnCells(group.getParentStep(), parentMethodName);

                for (Step subStep : group.getSubSteps()) {
                    parentMethodNameBySubStep.put(subStep, parentMethodName);
                    ResolvedStepKeyword subStepKeyword = resolveKeyword(subStep, resolvedStepKeywords);
                    if (subStepKeyword == null) {
                        return;
                    }
                    collectFixedTypes(subStep, subStepKeyword, fixedTypes, parentMethodName);
                }
            } else if (item instanceof Step step && resolveKeyword(step, resolvedStepKeywords) == null) {
                return;
            }
        }
    }

    /**
     * Resolves a step's keyword, or returns null when it can't be resolved; such a step is reported when its scenario
     * is generated.
     */
    private static ResolvedStepKeyword resolveKeyword(Step step, List<ResolvedStepKeyword> resolvedStepKeywords) {
        try {
            ResolvedStepKeyword resolvedStepKeyword = StepKeywordUtils.resolve(step, resolvedStepKeywords);
            resolvedStepKeywords.add(resolvedStepKeyword);
            return resolvedStepKeyword;
        } catch (ProcessingException e) {
            return null;
        }
    }

    /**
     * Records the columns of a parent step's data table, and its cells by column.
     */
    private void collectColumnCells(Step parentStep, String parentMethodName) {
        if (parentStep.getDataTable().isEmpty()) {
            return;
        }
        List<TableRow> rows = parentStep.getDataTable().get().getRows();
        List<String> columns = rows.getFirst().getCells().stream().map(cell -> cell.getValue().trim()).toList();
        columnsByMethod.putIfAbsent(parentMethodName, columns);
        Map<String, List<String>> columnCells = columnCellsByMethod.computeIfAbsent(parentMethodName, name -> new HashMap<>());
        for (TableRow row : rows.subList(1, rows.size())) {
            for (int i = 0; i < columns.size() && i < row.getCells().size(); i++) {
                columnCells.computeIfAbsent(columns.get(i), column -> new ArrayList<>())
                        .add(row.getCells().get(i).getValue().trim());
            }
        }
    }

    /**
     * Records the types that the base class step method of a sub-step fixes for the parent step values and data table
     * cells it receives.
     */
    private void collectFixedTypes(Step subStep, ResolvedStepKeyword subStepKeyword, Class<?>[] fixedTypes,
                                   String parentMethodName) {
        // A sub-step taking "<$dataTable>" has the step method of the same step written with a data table of its own
        String textWithoutDataTable = textWithoutDataTableReference(subStep);
        String text = textWithoutDataTable != null ? textWithoutDataTable : subStep.getText();
        boolean takesDataTable = textWithoutDataTable != null || subStep.getDataTable().isPresent()
                || subStep.getDocString().isPresent();

        List<String> values = new ArrayList<>();
        String methodName = stepMethodName(subStep.getKeyword(), text, subStepKeyword, values);
        int parameterCount = values.size() + (takesDataTable ? 1 : 0);

        ElementMethodUtils.MethodSignature baseMethod = baseClassMethodSignatures.getOrDefault(methodName, List.of())
                .stream()
                .filter(signature -> signature.getParameterCount() == parameterCount)
                .findFirst()
                .orElse(null);
        if (textWithoutDataTable != null) {
            collectDataTableRowType(parentMethodName, subStep.getKeyword() + textWithoutDataTable, baseMethod,
                    methodName, subStep.getLocation().getLine());
        }
        if (baseMethod == null) {
            return;
        }

        List<String> columns = columnsByMethod.getOrDefault(parentMethodName, List.of());
        for (int i = 0; i < values.size(); i++) {
            Matcher reference = wholeReferencePattern.matcher(values.get(i));
            if (!reference.matches()) {
                continue;
            }
            String name = reference.group("name");
            Integer valueNumber = parentValueNumber(values.get(i));
            if (valueNumber != null && valueNumber <= fixedTypes.length) {
                // A name that is both a value and a column is reported as ambiguous when the sub-step is generated
                if (!columns.contains(name) && fixedTypes[valueNumber - 1] == null) {
                    fixedTypes[valueNumber - 1] = classOf(baseMethod.getParameterType(i));
                }
            } else if (columns.contains(name)) {
                fixColumnType(parentMethodName, name,
                        new FixedType(classOf(baseMethod.getParameterType(i)), methodName, subStep.getLocation().getLine()));
            }
        }
    }

    /**
     * Records the row type of the parent step's data table for a sub-step taking it as "<$dataTable>": the first such
     * sub-step names the row type, and a custom row type its step method in the base class takes wins over a generated
     * one.
     */
    private void collectDataTableRowType(String parentMethodName, String recordStepText,
                                         ElementMethodUtils.MethodSignature baseMethod, String methodName, long line) {
        TypeElement baseRowType = null;
        if (baseMethod != null) {
            TypeMirror dataTableType = baseMethod.getParameterType(baseMethod.getParameterCount() - 1);
            if (ElementMethodUtils.isListOfCustomObjectType(dataTableType, processingEnv)) {
                baseRowType = ElementMethodUtils.extractListTypeArgument(dataTableType);
            }
        }
        DataTableRowType rowTypeBefore = dataTableRowTypesByMethod.get(parentMethodName);
        if (rowTypeBefore == null) {
            dataTableRowTypesByMethod.put(parentMethodName, baseRowType != null
                    ? new DataTableRowType(recordStepText, baseRowType, methodName, line)
                    : new DataTableRowType(recordStepText, null, null, 0));
        } else if (rowTypeBefore.baseRowType() == null && baseRowType != null) {
            dataTableRowTypesByMethod.put(parentMethodName,
                    new DataTableRowType(rowTypeBefore.recordStepText(), baseRowType, methodName, line));
        }
    }

    /**
     * Records the type a sub-step fixes for a data table column of its parent step; with the LIST_OF_OBJECT_PARAMS data
     * table type, a different type than one fixed before is a generator error.
     */
    private void fixColumnType(String parentMethodName, String column, FixedType fixedType) {
        Map<String, FixedType> fixedColumnTypes =
                fixedColumnTypesByMethod.computeIfAbsent(parentMethodName, name -> new HashMap<>());
        FixedType fixedBefore = fixedColumnTypes.putIfAbsent(column, fixedType);
        if (fixedBefore != null && fixedBefore.type() != fixedType.type()
                && LIST_OF_OBJECT_PARAMS.name().equals(options.getDataTableParameterType())) {
            throw new ProcessingException("<$" + column + "> of the composite step " + parentMethodName
                    + " needs two different types: " + typeName(fixedBefore) + " and " + typeName(fixedType));
        }
    }

    private static String typeName(FixedType fixedType) {
        String type = fixedType.type() != null ? fixedType.type().getSimpleName() : "an unsupported type";
        return type + " (" + fixedType.methodName() + ", line - " + fixedType.line() + ")";
    }

    /**
     * Returns the name of a step's method, collecting the step's quoted values.
     */
    private String stepMethodName(Step step, ResolvedStepKeyword resolvedStepKeyword, List<String> values) {
        return stepMethodName(step.getKeyword(), step.getText(), resolvedStepKeyword, values);
    }

    private String stepMethodName(String keyword, String text, ResolvedStepKeyword resolvedStepKeyword,
                                  List<String> values) {
        String stepFirstLine = (keyword + " " + text).trim().split("\\n")[0].trim();
        StringBuilder pattern = new StringBuilder();
        Matcher quotedValue = quotedValuePattern.matcher(stepFirstLine);
        int lastEnd = 0;
        while (quotedValue.find()) {
            pattern.append(stepFirstLine, lastEnd, quotedValue.start());
            pattern.append("$p").append(values.size() + 1);
            values.add(quotedValue.group("value").replaceAll("\\\\([\"\\\\])", "$1"));
            lastEnd = quotedValue.end();
        }
        pattern.append(stepFirstLine.substring(lastEnd));
        return MethodNamingUtils.getStepMethodName(pattern.toString(), keyword, resolvedStepKeyword,
                options.isUseStepKeywordInStepMethodName());
    }

    private static Class<?> widenedType(List<List<String>> literalsOfAllUses, int index) {
        List<String> literals = new ArrayList<>();
        for (List<String> literalsOfOneUse : literalsOfAllUses) {
            String literal = literalsOfOneUse.get(index);
            // Skip scenario outline placeholders
            if (!(literal.startsWith("<") && literal.endsWith(">"))) {
                literals.add(literal);
            }
        }
        return ParameterConversionUtils.inferTypeForAllValues(literals);
    }

    /**
     * Returns the class of a step method parameter type that a composite step value can take, or null for other types.
     *
     * @param type the parameter type of a step method
     * @return the class for the type, boxed for primitive types, or null
     */
    static Class<?> classOf(TypeMirror type) {
        return switch (type.getKind()) {
            case INT -> Integer.class;
            case LONG -> Long.class;
            case DOUBLE -> Double.class;
            case FLOAT -> Float.class;
            case BOOLEAN -> Boolean.class;
            case CHAR -> Character.class;
            case BYTE -> Byte.class;
            case SHORT -> Short.class;
            default -> switch (type.toString()) {
                case "java.lang.String" -> String.class;
                case "java.lang.Integer" -> Integer.class;
                case "java.lang.Long" -> Long.class;
                case "java.lang.Double" -> Double.class;
                case "java.lang.Float" -> Float.class;
                case "java.lang.Boolean" -> Boolean.class;
                case "java.lang.Character" -> Character.class;
                case "java.lang.Byte" -> Byte.class;
                case "java.lang.Short" -> Short.class;
                case "java.math.BigDecimal" -> BigDecimal.class;
                case "java.math.BigInteger" -> BigInteger.class;
                default -> null;
            };
        };
    }
}
