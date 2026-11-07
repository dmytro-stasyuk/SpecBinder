package dev.specbinder.reporter.internal;

import dev.specbinder.specreader.SpecKeywords;
import dev.specbinder.specreader.SpecParser;
import dev.specbinder.specreader.SpecParser.ParsedSpec;
import dev.specbinder.specreader.SpecTextStripper;
import io.cucumber.messages.types.*;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Loads the {@code .feature} (or {@code .specb}) file behind a SpecBinder-generated test
 * class as a classpath resource, reads it the way it was generated — with the keywords of
 * the same languages, and with the same text stripped — and produces a {@link ParsedFeature}
 * mirroring the spec's structure —
 * feature-level scenarios first, then a {@link ParsedRule} per Rule, each carrying its own
 * scenarios.
 *
 * <p>Each {@link ParsedScenario} carries:
 * <ul>
 *   <li>{@code canonicalSteps} — applicable Backgrounds (feature-level + rule-level) followed
 *       by the scenario's own steps, canonicalised exactly the same way the annotation
 *       processor does at compile time. Fed to {@link ScenarioHasher} so the reporter can
 *       compare against {@code @ScenarioHash} on the test method.</li>
 *   <li>{@code backgroundStepLines} / {@code scenarioStepLines} — the keyword-prefixed spec
 *       lines of the applicable Background and scenario steps, in execution order. One
 *       entry per {@code StepReport}.</li>
 *   <li>{@code backgroundBlockArgs} / {@code scenarioBlockArgs} — per-step metadata describing
 *       whether the step's spec has a DocString or DataTable trailing argument, and (for
 *       DataTables) the source-order header row. Used by the reporter to wrap each captured
 *       runtime argument with a {@code {type, value, ...}} envelope.</li>
 * </ul>
 *
 * <p>Returning a structural model (rather than a line-keyed map) lets the reporter pair
 * each runtime {@code ScenarioNode} with its spec counterpart purely by position, then
 * use {@code @ScenarioHash} for integrity verification — no {@code @SourceLine} required.
 *
 * <p>If the resource can't be found or the file fails to parse, returns
 * {@link ParsedFeature#EMPTY} and logs at {@code WARNING} — report writing continues
 * without {@code text} or argument-type stamping.
 */
public final class SourceFeatureReader {

    private static final Logger LOGGER = Logger.getLogger(SourceFeatureReader.class.getName());

    /** Structural mirror of the spec: feature-level scenarios and Rules with their scenarios, in source order. */
    public record ParsedFeature(List<ParsedScenario> scenarios, List<ParsedRule> rules) {
        public static final ParsedFeature EMPTY = new ParsedFeature(List.of(), List.of());
    }

    /** A Rule's scenarios in source order; Rule-level Backgrounds are pre-merged into each scenario. */
    public record ParsedRule(List<ParsedScenario> scenarios) {
    }

    /**
     * A single scenario's canonical-hash input, spec lines, and per-step block-arg metadata.
     *
     * <p>{@code examplesRows} holds a Scenario Outline's Examples table as it reads today: each
     * row as column-name to value, in the order the table declares them. It is empty for a plain
     * Scenario. Tooling reconciling a report uses it to lay merged rows out in the order the
     * spec now shows, rather than the order some earlier run happened to record.
     */
    public record ParsedScenario(
            List<CanonicalStep> canonicalSteps,
            List<String> backgroundStepLines,
            List<String> scenarioStepLines,
            List<StepBlockArgument> backgroundBlockArgs,
            List<StepBlockArgument> scenarioBlockArgs,
            List<Map<String, String>> examplesRows) {
    }

    /**
     * Describes the trailing block argument (if any) on a single step. SpecBinder allows
     * at most one DocString or DataTable per step (mutually exclusive); for any inline
     * simple parameters that come before, no per-arg metadata is needed — the reporter
     * defaults them to {@code simple}.
     *
     * <p>The {@code docStringValue} and {@code dataTableBodyRows} fields carry the spec-side
     * content verbatim. They are unused on the runtime-capture path (where the actual
     * argument object is taken from the step invocation) and exist to let the reporter
     * synthesise an {@code arguments} entry for steps that were skipped after an earlier
     * failure — those never reach the step interceptor, so the spec is the only source.
     *
     * @param kind                 which block kind the step has, if any
     * @param docStringMediaType   for {@code DOC_STRING}: the identifier after the opening
     *                             {@code """} fence (e.g. {@code "html"} from {@code """html});
     *                             {@code null} when the fence was bare or the kind is not
     *                             {@code DOC_STRING}
     * @param docStringValue       for {@code DOC_STRING}: the verbatim DocString body from
     *                             the spec, with the trailing newline preserved as Cucumber
     *                             emits it; {@code null} when the kind is not {@code DOC_STRING}
     * @param dataTableHeaders     for {@code DATA_TABLE}: the source-order list of column
     *                             header strings (verbatim from the spec); empty when the
     *                             kind is not {@code DATA_TABLE} or the table is headerless
     * @param dataTableBodyRows    for {@code DATA_TABLE}: each body row as a source-order list
     *                             of cell strings (verbatim, no trimming); empty when the
     *                             kind is not {@code DATA_TABLE} or the table has no body
     */
    public record StepBlockArgument(
            BlockKind kind,
            String docStringMediaType,
            String docStringValue,
            List<String> dataTableHeaders,
            List<List<String>> dataTableBodyRows) {

        public enum BlockKind { NONE, DOC_STRING, DATA_TABLE }

        public static final StepBlockArgument NONE =
                new StepBlockArgument(BlockKind.NONE, null, null, List.of(), List.of());
    }

    private SourceFeatureReader() {
    }

    /**
     * Loads and parses the feature at {@code sourceFilePath} with the default options: English
     * keywords only, nothing stripped. See {@link #parse(String, SpecReadingOptions, ClassLoader)}.
     */
    public static ParsedFeature parse(String sourceFilePath, ClassLoader classLoader) {
        return parse(sourceFilePath, SpecReadingOptions.DEFAULTS, classLoader);
    }

    /**
     * Loads and parses the feature at {@code sourceFilePath} (resolved via the given
     * {@code classLoader}'s resource lookup) and returns a {@link ParsedFeature} mirroring
     * its structure. The spec is read the way the annotation processor read it: with the
     * keywords of its {@code # language:} header, or else with those of the languages of the
     * given options, mixed freely, with their keyword synonyms on top, and with the text their strip
     * patterns match removed.
     * Returns {@link ParsedFeature#EMPTY} if the resource is missing or parsing fails.
     */
    public static ParsedFeature parse(String sourceFilePath, SpecReadingOptions options,
                                      ClassLoader classLoader) {
        if (sourceFilePath == null || classLoader == null) {
            return ParsedFeature.EMPTY;
        }
        InputStream stream = classLoader.getResourceAsStream(sourceFilePath);
        if (stream == null) {
            LOGGER.warning("SpecBinder reporter: feature file not on classpath, "
                    + "step text will be omitted: " + sourceFilePath);
            return ParsedFeature.EMPTY;
        }
        try (InputStream in = stream) {
            String content = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            SpecKeywords keywords = SpecKeywords.of(content, options.keywordLanguages(), options.keywordSynonyms());
            SpecTextStripper textStripper =
                    SpecTextStripper.of(options.stripPatterns(), options.stripBetweenPatterns());
            if (textStripper.isEnabled()) {
                content = textStripper.strip(content, keywords.stepKeywords());
            }
            ParsedSpec parsedSpec = SpecParser.parse(sourceFilePath, content, keywords);
            if (parsedSpec.firstParseError().isPresent()) {
                LOGGER.warning("SpecBinder reporter: failed to parse feature for step-text stamping: "
                        + sourceFilePath + " - " + parsedSpec.firstParseError().get().getMessage());
                return ParsedFeature.EMPTY;
            }
            return parsedSpec.feature().map(SourceFeatureReader::buildModel).orElse(ParsedFeature.EMPTY);
        } catch (IOException | RuntimeException e) {
            LOGGER.log(Level.WARNING,
                    "SpecBinder reporter: failed to parse feature for step-text stamping: "
                            + sourceFilePath, e);
            return ParsedFeature.EMPTY;
        }
    }

    private static ParsedFeature buildModel(Feature feature) {
        // Feature-level backgrounds apply to every scenario in the file (including those
        // inside Rules), and Rule-level backgrounds apply on top of them in outer→inner
        // order — matches BackgroundStepCollector on the annotation-processor side.
        List<Step> featureBackgroundSteps = new ArrayList<>();
        for (FeatureChild child : feature.getChildren()) {
            child.getBackground().ifPresent(bg -> featureBackgroundSteps.addAll(bg.getSteps()));
        }

        List<ParsedScenario> featureScenarios = new ArrayList<>();
        List<ParsedRule> rules = new ArrayList<>();
        for (FeatureChild child : feature.getChildren()) {
            child.getScenario().ifPresent(sc ->
                    featureScenarios.add(buildScenario(sc, featureBackgroundSteps, List.of())));
            child.getRule().ifPresent(rule ->
                    rules.add(buildRule(rule, featureBackgroundSteps)));
        }

        return new ParsedFeature(
                Collections.unmodifiableList(featureScenarios),
                Collections.unmodifiableList(rules));
    }

    private static ParsedRule buildRule(Rule rule, List<Step> featureBackgroundSteps) {
        List<Step> ruleBackgroundSteps = new ArrayList<>();
        for (RuleChild child : rule.getChildren()) {
            child.getBackground().ifPresent(bg -> ruleBackgroundSteps.addAll(bg.getSteps()));
        }
        List<ParsedScenario> scenarios = new ArrayList<>();
        for (RuleChild child : rule.getChildren()) {
            child.getScenario().ifPresent(sc ->
                    scenarios.add(buildScenario(sc, featureBackgroundSteps, ruleBackgroundSteps)));
        }
        return new ParsedRule(Collections.unmodifiableList(scenarios));
    }

    private static ParsedScenario buildScenario(Scenario scenario,
                                                 List<Step> featureBackgroundSteps,
                                                 List<Step> ruleBackgroundSteps) {
        List<Step> backgroundSteps = new ArrayList<>(
                featureBackgroundSteps.size() + ruleBackgroundSteps.size());
        backgroundSteps.addAll(featureBackgroundSteps);
        backgroundSteps.addAll(ruleBackgroundSteps);

        List<Step> scenarioSteps = scenario.getSteps();

        List<CanonicalStep> canonicalSteps = new ArrayList<>(backgroundSteps.size() + scenarioSteps.size());
        for (Step s : backgroundSteps) canonicalSteps.add(CanonicalStepBuilder.canonicalize(s));
        for (Step s : scenarioSteps) canonicalSteps.add(CanonicalStepBuilder.canonicalize(s));

        return new ParsedScenario(
                Collections.unmodifiableList(canonicalSteps),
                Collections.unmodifiableList(toLineList(backgroundSteps)),
                Collections.unmodifiableList(toLineList(scenarioSteps)),
                Collections.unmodifiableList(toBlockArgList(backgroundSteps)),
                Collections.unmodifiableList(toBlockArgList(scenarioSteps)),
                Collections.unmodifiableList(toExamplesRows(scenario)));
    }

    /**
     * A Scenario Outline's Examples rows, flattened across every Examples block in declaration
     * order and keyed by column name. A plain Scenario contributes nothing. A row with fewer
     * cells than headers keeps only the columns it actually has, so a malformed table degrades
     * to a partial row rather than failing the whole parse.
     */
    private static List<Map<String, String>> toExamplesRows(Scenario scenario) {
        List<Map<String, String>> rows = new ArrayList<>();
        for (Examples examples : scenario.getExamples()) {
            if (examples.getTableHeader().isEmpty()) {
                continue;
            }
            List<String> headers = examples.getTableHeader().get().getCells().stream()
                    .map(TableCell::getValue).toList();
            for (TableRow row : examples.getTableBody()) {
                List<TableCell> cells = row.getCells();
                Map<String, String> values = new LinkedHashMap<>();
                for (int i = 0; i < headers.size() && i < cells.size(); i++) {
                    values.put(headers.get(i), cells.get(i).getValue());
                }
                rows.add(Collections.unmodifiableMap(values));
            }
        }
        return rows;
    }

    /**
     * Cucumber's {@code Step.getKeyword()} preserves the trailing space from the source
     * (e.g. {@code "Given "}), so direct concatenation with the step text yields the
     * verbatim spec line (e.g. {@code "Given I add \"Apple\" to the cart"}). Trailing
     * DocString or DataTable bodies do not appear here — those are surfaced as structural
     * argument metadata via {@link #toBlockArgList(List)}, not as additional text lines.
     */
    private static List<String> toLineList(List<Step> steps) {
        List<String> lines = new ArrayList<>(steps.size());
        for (Step s : steps) {
            lines.add(s.getKeyword() + s.getText());
        }
        return lines;
    }

    private static List<StepBlockArgument> toBlockArgList(List<Step> steps) {
        List<StepBlockArgument> result = new ArrayList<>(steps.size());
        for (Step s : steps) {
            Optional<DocString> docString = s.getDocString();
            Optional<DataTable> dataTable = s.getDataTable();
            if (docString.isPresent()) {
                String mediaType = docString.get().getMediaType()
                        .map(String::strip)
                        .filter(mt -> !mt.isEmpty())
                        .orElse(null);
                String content = docString.get().getContent();
                result.add(new StepBlockArgument(
                        StepBlockArgument.BlockKind.DOC_STRING,
                        mediaType,
                        content == null ? "" : content,
                        List.of(),
                        List.of()));
            } else if (dataTable.isPresent()) {
                List<TableRow> rows = dataTable.get().getRows();
                List<String> headers = rows.isEmpty()
                        ? List.of()
                        : rows.get(0).getCells().stream().map(TableCell::getValue).toList();
                List<List<String>> bodyRows = new ArrayList<>(Math.max(0, rows.size() - 1));
                for (int r = 1; r < rows.size(); r++) {
                    bodyRows.add(List.copyOf(
                            rows.get(r).getCells().stream().map(TableCell::getValue).toList()));
                }
                result.add(new StepBlockArgument(
                        StepBlockArgument.BlockKind.DATA_TABLE,
                        null,
                        null,
                        List.copyOf(headers),
                        List.copyOf(bodyRows)));
            } else {
                result.add(StepBlockArgument.NONE);
            }
        }
        return result;
    }
}
