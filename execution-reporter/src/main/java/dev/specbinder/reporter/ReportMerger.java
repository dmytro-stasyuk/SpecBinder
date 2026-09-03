package dev.specbinder.reporter;

import com.fasterxml.jackson.databind.ObjectMapper;
import dev.specbinder.annotations.output.ScenarioHash;
import dev.specbinder.reporter.internal.SourceFeatureReader;
import org.junit.jupiter.api.DisplayName;

import java.io.IOException;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Folds the results of the run that just finished into the report already on disk.
 *
 * <p>Re-running one scenario from the IDE produces a report describing only that scenario.
 * Written as-is it would replace the whole file, discarding every other scenario's outcome.
 * Instead the run's results are merged over what is already recorded: a scenario that ran takes
 * its fresh result, and one that did not keeps the outcome of its last execution.
 *
 * <p>Matching a recorded result to a scenario needs two independent things, because neither
 * survives editing on its own. A <em>position</em> — the generated method name, and the nested
 * class when the scenario sits in a Rule — is unique but shifts whenever a scenario is inserted,
 * deleted or reordered. The <em>content hash</em> is unchanged by those but is not unique, and
 * changes whenever the scenario's own steps do. So a recorded result is placed by looking at
 * both: one still at its position with the same content is kept there; one whose content now
 * lives at a different position is re-keyed to it; one whose position survives but whose content
 * has changed keeps the hash it recorded, so a consumer can still tell it is out of date; and one
 * matching neither is dropped, since it describes a scenario that no longer exists.
 *
 * <p>Merging happens only when the file on disk fits the run — readable, describing this same
 * feature, and carrying the current schema version. A file failing any of those is replaced
 * rather than merged, so a stale or foreign report can never contribute results.
 *
 * <p>A full run needs no special handling: every position that exists takes a fresh result, so
 * nothing is left to carry and the output is what the run alone would have written.
 */
final class ReportMerger {

    private static final Logger LOGGER = Logger.getLogger(ReportMerger.class.getName());

    /** Generated method names carry their ordinals: {@code rule_2_scenario_3}, {@code scenario_1}. */
    private static final Pattern ORDINALS = Pattern.compile("(?:rule_(\\d+)_)?scenario_(\\d+)");

    private ReportMerger() {
    }

    /**
     * A scenario slot the generated class still declares. {@code exampleRows} is the Examples
     * table the spec declares for it today, empty for a plain scenario or when the spec could
     * not be read.
     */
    private record Position(String key, String ruleClass, String ruleDisplayName, String hash,
                            List<Map<String, String>> exampleRows) {
        boolean isFeatureLevel() {
            return ruleClass == null;
        }

        Position withExampleRows(List<Map<String, String>> rows) {
            return new Position(key, ruleClass, ruleDisplayName, hash, rows);
        }
    }

    /**
     * Returns the report to write: the run's results merged over the existing file when that file
     * fits, otherwise the run's results alone. Either way the summary and the two header time
     * fields are derived from the scenarios actually present.
     */
    static FeatureReport mergeOver(FeatureReport fresh, Path target, ObjectMapper mapper,
                                   Class<?> testClass) {
        FeatureReport previous = readIfUsable(fresh, target, mapper);
        if (previous != null) {
            List<Position> declared = declaredPositions(testClass);
            attachExampleRows(declared, fresh.getSourceFilePath(), classLoaderOf(testClass));
            carryOver(previous, fresh, declared);
        }
        return recomputeDerivedFields(fresh);
    }

    private static ClassLoader classLoaderOf(Class<?> testClass) {
        return testClass == null ? ReportMerger.class.getClassLoader() : testClass.getClassLoader();
    }

    /**
     * Gives each outline position the Examples table the spec declares today.
     *
     * <p>A partial run reports only the rows it ran, so the merged rows have to be laid out
     * against something; the spec is that something. Reading it here rather than off the
     * generated class also means the order survives whatever provider annotation the generator
     * happens to emit. Positions pair with parsed scenarios by generation order — feature-level
     * scenarios first, then each Rule's — the same order {@link #declaredPositions} produces.
     */
    private static void attachExampleRows(List<Position> declared, String sourceFilePath,
                                          ClassLoader classLoader) {
        if (declared.isEmpty() || sourceFilePath == null) {
            return;
        }
        SourceFeatureReader.ParsedFeature parsed = SourceFeatureReader.parse(sourceFilePath, classLoader);
        List<SourceFeatureReader.ParsedScenario> flat = new ArrayList<>(parsed.scenarios());
        for (SourceFeatureReader.ParsedRule rule : parsed.rules()) {
            flat.addAll(rule.scenarios());
        }
        if (flat.size() != declared.size()) {
            return;             // the spec has moved on from the generated class; trust neither
        }
        for (int i = 0; i < declared.size(); i++) {
            declared.set(i, declared.get(i).withExampleRows(flat.get(i).examplesRows()));
        }
    }

    /** The report on disk, or null when there is none or it does not fit this run. */
    private static FeatureReport readIfUsable(FeatureReport fresh, Path target, ObjectMapper mapper) {
        if (!Files.exists(target)) {
            return null;
        }
        FeatureReport previous;
        try {
            previous = mapper.readValue(Files.readString(target), FeatureReport.class);
        } catch (IOException | RuntimeException e) {
            LOGGER.log(Level.FINE, () -> "SpecBinder reporter: existing report at " + target
                    + " could not be read and will be replaced");
            return null;
        }
        if (previous.getSchemaVersion() != FeatureReport.SCHEMA_VERSION) {
            return null;                    // written by another version; shapes may differ
        }
        if (!Objects.equals(previous.getSourceFilePath(), fresh.getSourceFilePath())
                || !Objects.equals(previous.getTestClass(), fresh.getTestClass())) {
            return null;                    // belongs to a different spec
        }
        return previous;
    }

    /** Every scenario slot the generated class declares, in generation order. */
    private static List<Position> declaredPositions(Class<?> testClass) {
        List<Position> positions = new ArrayList<>();
        if (testClass == null) {
            return positions;
        }
        for (Class<?> cls = testClass; cls != null && cls != Object.class; cls = cls.getSuperclass()) {
            for (Method method : cls.getDeclaredMethods()) {
                if (isScenarioMethod(method.getName())) {
                    positions.add(new Position(method.getName(), null, null, hashOn(method), List.of()));
                }
            }
            for (Class<?> nested : cls.getDeclaredClasses()) {
                DisplayName name = nested.getAnnotation(DisplayName.class);
                for (Method method : nested.getDeclaredMethods()) {
                    if (isScenarioMethod(method.getName())) {
                        positions.add(new Position(
                                nested.getSimpleName() + "#" + method.getName(),
                                nested.getSimpleName(),
                                name != null ? name.value() : nested.getSimpleName(),
                                hashOn(method),
                                List.of()));
                    }
                }
            }
        }
        positions.sort((a, b) -> Integer.compare(order(a.key()), order(b.key())));
        return positions;
    }

    private static boolean isScenarioMethod(String name) {
        return ORDINALS.matcher(name).matches();
    }

    private static String hashOn(Method method) {
        ScenarioHash annotation = method.getAnnotation(ScenarioHash.class);
        return annotation == null ? null : annotation.value();
    }

    /** Sort key placing feature-level scenarios first, then each Rule's, by declared ordinal. */
    private static int order(String key) {
        Matcher m = ORDINALS.matcher(key.contains("#") ? key.substring(key.indexOf('#') + 1) : key);
        if (!m.matches()) {
            return Integer.MAX_VALUE;
        }
        int rule = m.group(1) == null ? 0 : Integer.parseInt(m.group(1));
        return rule * 1000 + Integer.parseInt(m.group(2));
    }

    /** The position part of a node id: {@code Rule_1#method}, or just {@code method}. */
    private static String positionOf(String id) {
        int hash = id.indexOf('#');
        if (hash < 0) {
            return id;
        }
        String method = id.substring(hash + 1);
        int dollar = id.lastIndexOf('$', hash);
        return dollar < 0 ? method : id.substring(dollar + 1, hash) + "#" + method;
    }

    /**
     * Places every result — fresh and carried — at the position it now belongs to, and rebuilds
     * the report's structure around them.
     */
    private static void carryOver(FeatureReport previous, FeatureReport fresh, List<Position> declared) {
        Map<String, ScenarioNode> placed = new LinkedHashMap<>();
        for (ScenarioNode node : flatten(fresh)) {
            placed.put(positionOf(node.getId()), node);         // a fresh result always wins
        }
        Map<String, Position> byKey = new LinkedHashMap<>();
        for (Position position : declared) {
            byKey.put(position.key(), position);
        }

        // An outline that ran only some of its rows reports only those. Fold the rest in from
        // the record first, so what gets placed describes the whole Examples table rather than
        // just this run's slice of it.
        foldRowsIntoPartialOutlines(previous, placed, byKey);

        // Every recorded result is a candidate, including one whose position a fresh result has
        // just taken: its content may now live at a different position, and discarding it here
        // would lose the outcome of a scenario that merely moved.
        List<ScenarioNode> carryable = flatten(previous);

        // Exact matches first — still at their position, still the same content. Only once those
        // hold their slots can a moved result be matched on content alone, or a scenario sharing
        // content with another could take a slot that belongs to an unchanged one.
        Set<String> claimed = new HashSet<>();
        List<ScenarioNode> unmatched = new ArrayList<>();
        for (ScenarioNode node : carryable) {
            Position at = byKey.get(positionOf(node.getId()));
            if (at != null && !placed.containsKey(at.key())
                    && at.hash() != null && at.hash().equals(node.getScenarioHash())) {
                place(placed, claimed, at, node);
            } else {
                unmatched.add(node);
            }
        }

        // Then results whose content has moved to another position. This runs as its own pass so
        // that a genuinely moved result is not beaten to a free slot by one that merely happens
        // to be processed first.
        List<ScenarioNode> stillUnplaced = new ArrayList<>();
        for (ScenarioNode node : unmatched) {
            Position moved = firstFreeWithHash(declared, placed, claimed, node.getScenarioHash());
            if (moved != null) {
                place(placed, claimed, moved, node);
            } else {
                stillUnplaced.add(node);
            }
        }

        // Finally results whose position survives but whose content has changed: the scenario was
        // edited since it ran. It keeps the hash it recorded, so a consumer can still tell the
        // outcome describes an older version of the scenario.
        for (ScenarioNode node : stillUnplaced) {
            Position at = byKey.get(positionOf(node.getId()));
            if (at != null && !placed.containsKey(at.key())) {
                place(placed, claimed, at, node);
            }
            // otherwise the scenario is gone from the spec, so its result goes with it
        }
        rebuild(fresh, declared, placed);
    }

    /**
     * For each freshly-run outline, brings forward the recorded outcome of every row the run did
     * not cover.
     *
     * <p>Only a recorded outline describing the same scenario contributes — same position and
     * same content — because a row's outcome means nothing once the steps around it have changed.
     */
    private static void foldRowsIntoPartialOutlines(FeatureReport previous,
                                                    Map<String, ScenarioNode> placed,
                                                    Map<String, Position> byKey) {
        Map<String, ScenarioNode> recorded = new LinkedHashMap<>();
        for (ScenarioNode node : flatten(previous)) {
            recorded.put(positionOf(node.getId()), node);
        }
        for (Map.Entry<String, ScenarioNode> entry : placed.entrySet()) {
            ScenarioNode fresh = entry.getValue();
            ScenarioNode previousNode = recorded.get(entry.getKey());
            Position position = byKey.get(entry.getKey());
            if (!isOutline(fresh) || previousNode == null || !isOutline(previousNode)
                    || position == null
                    || !Objects.equals(fresh.getScenarioHash(), previousNode.getScenarioHash())) {
                continue;
            }
            fresh.setExamples(mergeRows(fresh, previousNode, position));
            rollUp(fresh);
        }
    }

    private static boolean isOutline(ScenarioNode node) {
        return node.getType() == ScenarioNode.Kind.SCENARIO_OUTLINE;
    }

    /**
     * The outline's rows after merging: this run's result for a row that ran, the recorded one
     * for a row that did not, and nothing at all for a row the Examples table no longer holds.
     *
     * <p>Rows are matched on their values rather than their place in the table, so a row keeps
     * its outcome when the table is reordered. The merged list follows the table's current order,
     * which is what a reader of the spec sees.
     */
    private static List<ExampleReport> mergeRows(ScenarioNode fresh, ScenarioNode previous,
                                                 Position position) {
        Map<String, ExampleReport> freshRows = byRowIdentity(fresh);
        Map<String, ExampleReport> recordedRows = byRowIdentity(previous);
        List<ExampleReport> merged = new ArrayList<>();
        for (Map<String, String> declaredRow : position.exampleRows()) {
            String identity = identityOf(declaredRow);
            ExampleReport row = freshRows.get(identity);
            if (row == null) {
                row = recordedRows.get(identity);
            }
            if (row != null) {
                merged.add(row);
            }
        }
        if (merged.isEmpty()) {
            // No usable Examples table to lay the rows out against — keep what ran rather than
            // dropping results on the floor.
            return fresh.getExamples();
        }
        return merged;
    }

    private static Map<String, ExampleReport> byRowIdentity(ScenarioNode outline) {
        Map<String, ExampleReport> rows = new LinkedHashMap<>();
        for (ExampleReport row : nullToEmpty(outline.getExamples())) {
            rows.putIfAbsent(identityOf(row.getExamplesRow()), row);
        }
        return rows;
    }

    /**
     * A row's identity, taken from its values. The row hash is not used: it is absent whenever
     * hash emission is off, and it carries no more information than the values it is derived from.
     */
    private static String identityOf(Map<String, String> values) {
        if (values == null || values.isEmpty()) {
            return "";
        }
        List<String> cells = new ArrayList<>(values.size());
        values.forEach((key, value) -> cells.add(key + "=" + value));
        cells.sort(String::compareTo);
        return String.join("\n", cells);
    }

    /** Re-derives an outline's own status and duration from the rows it now holds. */
    private static void rollUp(ScenarioNode outline) {
        long total = 0L;
        Status worst = null;
        for (ExampleReport row : nullToEmpty(outline.getExamples())) {
            total += row.getDurationMs();
            worst = worstOf(worst, row.getStatus());
        }
        outline.setTotalDurationMs(total);
        outline.setStatus(worst);
    }

    private static Status worstOf(Status current, Status candidate) {
        if (candidate == null) {
            return current;
        }
        return current == null || severity(candidate) > severity(current) ? candidate : current;
    }

    private static int severity(Status status) {
        return switch (status) {
            case FAILED -> 3;
            case ABORTED -> 2;
            case SKIPPED -> 1;
            case PASSED -> 0;
        };
    }

    private static Position firstFreeWithHash(List<Position> declared, Map<String, ScenarioNode> placed,
                                              Set<String> claimed, String hash) {
        if (hash == null) {
            return null;                                        // nothing to match content on
        }
        for (Position position : declared) {
            if (hash.equals(position.hash()) && !claimed.contains(position.key())
                    && !placed.containsKey(position.key())) {
                return position;
            }
        }
        return null;
    }

    /** Re-keys the node's id onto the position it now occupies and records the placement. */
    private static void place(Map<String, ScenarioNode> placed, Set<String> claimed,
                              Position position, ScenarioNode node) {
        String id = node.getId();
        int hash = id.indexOf('#');
        String owner = hash < 0 ? id : id.substring(0, hash);
        int dollar = owner.lastIndexOf('$');
        String outer = dollar < 0 ? owner : owner.substring(0, dollar);
        node.setId(position.isFeatureLevel()
                ? outer + "#" + position.key()
                : outer + "$" + position.key());
        placed.put(position.key(), node);
        claimed.add(position.key());
    }

    /** Lays the placed results back out as feature-level scenarios and Rule groups. */
    private static void rebuild(FeatureReport fresh, List<Position> declared,
                                Map<String, ScenarioNode> placed) {
        Map<String, RuleReport> freshRules = new LinkedHashMap<>();
        for (RuleReport rule : nullToEmpty(fresh.getRules())) {
            freshRules.put(positionOfRule(rule.getId()), rule);
        }
        List<ScenarioNode> scenarios = new ArrayList<>();
        Map<String, RuleReport> rules = new LinkedHashMap<>();
        for (Position position : declared) {
            ScenarioNode node = placed.get(position.key());
            if (node == null) {
                continue;
            }
            if (position.isFeatureLevel()) {
                scenarios.add(node);
                continue;
            }
            RuleReport rule = rules.computeIfAbsent(position.ruleClass(), key -> {
                RuleReport existing = freshRules.get(key);
                RuleReport out = existing != null ? existing : new RuleReport();
                out.setId(ruleId(fresh.getTestClass(), key));
                out.setDisplayName(position.ruleDisplayName());
                out.setScenarios(new ArrayList<>());
                return out;
            });
            rule.getScenarios().add(node);
        }
        fresh.setScenarios(scenarios);
        fresh.setRules(new ArrayList<>(rules.values()));
    }

    private static String positionOfRule(String id) {
        int dollar = id.lastIndexOf('$');
        return dollar < 0 ? id : id.substring(dollar + 1);
    }

    private static String ruleId(String testClass, String ruleClass) {
        return testClass + "$" + ruleClass;
    }

    private static List<ScenarioNode> flatten(FeatureReport report) {
        List<ScenarioNode> all = new ArrayList<>(nullToEmpty(report.getScenarios()));
        for (RuleReport rule : nullToEmpty(report.getRules())) {
            all.addAll(nullToEmpty(rule.getScenarios()));
        }
        return all;
    }

    private static FeatureReport recomputeDerivedFields(FeatureReport report) {
        List<ScenarioNode> all = allNodes(report);
        Summary summary = new Summary();
        Instant newest = null;
        long total = 0;
        for (ScenarioNode node : all) {
            // An outline counts once per example row, not once for the outline: that is what the
            // reporter records during a full run, and a merged report must read the same way.
            if (isOutline(node)) {
                for (ExampleReport row : nullToEmpty(node.getExamples())) {
                    if (row.getStatus() != null) {
                        summary.increment(row.getStatus());
                    }
                }
            } else if (node.getStatus() != null) {
                summary.increment(node.getStatus());
            }
            Instant started = startedAt(node);
            if (started != null && (newest == null || started.isAfter(newest))) {
                newest = started;
            }
            total += durationOf(node);
        }
        report.setSummary(summary);
        // The most recent moment, so the header says when the report was last brought up to date.
        // Any run's own scenarios are newer than anything carried over, so this is effectively the
        // moment the last scenario of this run started.
        if (newest != null) {
            report.setExecutedAt(newest);
        }
        report.setTotalDurationMs(total);
        return report;
    }

    private static List<ScenarioNode> allNodes(FeatureReport report) {
        List<ScenarioNode> all = new ArrayList<>(nullToEmpty(report.getScenarios()));
        for (RuleReport rule : nullToEmpty(report.getRules())) {
            all.addAll(nullToEmpty(rule.getScenarios()));
        }
        return all;
    }

    /** A plain scenario carries its own moment; an outline's is the latest of its rows. */
    private static Instant startedAt(ScenarioNode node) {
        if (node.getStartedAt() != null) {
            return node.getStartedAt();
        }
        Instant latest = null;
        for (ExampleReport row : nullToEmpty(node.getExamples())) {
            if (row.getStartedAt() != null && (latest == null || row.getStartedAt().isAfter(latest))) {
                latest = row.getStartedAt();
            }
        }
        return latest;
    }

    private static long durationOf(ScenarioNode node) {
        if (node.getDurationMs() != null) {
            return node.getDurationMs();
        }
        return node.getTotalDurationMs() != null ? node.getTotalDurationMs() : 0L;
    }


    private static <T> List<T> nullToEmpty(List<T> list) {
        return list == null ? List.of() : list;
    }
}
