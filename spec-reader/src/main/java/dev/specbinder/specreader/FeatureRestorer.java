package dev.specbinder.specreader;

import dev.specbinder.specreader.KeywordTranslator.Translation;
import io.cucumber.messages.types.*;

import java.util.Optional;

/**
 * Puts the spec's own words back into what the parser read from a spec rewritten by {@link KeywordTranslator}: the
 * keyword of every title line and step as the spec spells it, the description lines as the spec writes them, and the
 * line as written in a parse error.
 */
final class FeatureRestorer {

    private final Translation translation;

    FeatureRestorer(Translation translation) {
        this.translation = translation;
    }

    Feature restoreFeature(Feature feature) {
        return new Feature(
                feature.getLocation(),
                feature.getTags(),
                translation.headerLanguage() != null ? translation.headerLanguage() : feature.getLanguage(),
                keyword(feature.getLocation(), feature.getKeyword()),
                feature.getName(),
                description(feature.getLocation(), feature.getDescription()),
                feature.getChildren().stream().map(this::restoreFeatureChild).toList()
        );
    }

    ParseError restoreParseError(ParseError parseError) {
        Optional<Location> location = parseError.getSource().getLocation();
        if (location.isEmpty()) {
            return parseError;
        }
        int lineIndex = lineIndexOf(location.get());
        if (!translation.isChanged(lineIndex)) {
            return parseError;
        }
        String message = parseError.getMessage().replace(
                "'" + translation.translatedLines()[lineIndex].strip() + "'",
                "'" + translation.originalLines()[lineIndex].strip() + "'");
        return new ParseError(parseError.getSource(), message);
    }

    private FeatureChild restoreFeatureChild(FeatureChild child) {
        return new FeatureChild(
                child.getRule().map(this::restoreRule).orElse(null),
                child.getBackground().map(this::restoreBackground).orElse(null),
                child.getScenario().map(this::restoreScenario).orElse(null)
        );
    }

    private Rule restoreRule(Rule rule) {
        return new Rule(
                rule.getLocation(),
                rule.getTags(),
                keyword(rule.getLocation(), rule.getKeyword()),
                rule.getName(),
                description(rule.getLocation(), rule.getDescription()),
                rule.getChildren().stream().map(this::restoreRuleChild).toList(),
                rule.getId()
        );
    }

    private RuleChild restoreRuleChild(RuleChild child) {
        return new RuleChild(
                child.getBackground().map(this::restoreBackground).orElse(null),
                child.getScenario().map(this::restoreScenario).orElse(null)
        );
    }

    private Background restoreBackground(Background background) {
        return new Background(
                background.getLocation(),
                keyword(background.getLocation(), background.getKeyword()),
                background.getName(),
                description(background.getLocation(), background.getDescription()),
                background.getSteps().stream().map(this::restoreStep).toList(),
                background.getId()
        );
    }

    private Scenario restoreScenario(Scenario scenario) {
        return new Scenario(
                scenario.getLocation(),
                scenario.getTags(),
                keyword(scenario.getLocation(), scenario.getKeyword()),
                scenario.getName(),
                description(scenario.getLocation(), scenario.getDescription()),
                scenario.getSteps().stream().map(this::restoreStep).toList(),
                scenario.getExamples().stream().map(this::restoreExamples).toList(),
                scenario.getId()
        );
    }

    private Examples restoreExamples(Examples examples) {
        return new Examples(
                examples.getLocation(),
                examples.getTags(),
                keyword(examples.getLocation(), examples.getKeyword()),
                examples.getName(),
                description(examples.getLocation(), examples.getDescription()),
                examples.getTableHeader().orElse(null),
                examples.getTableBody(),
                examples.getId()
        );
    }

    private Step restoreStep(Step step) {
        return new Step(
                step.getLocation(),
                keyword(step.getLocation(), step.getKeyword()),
                step.getKeywordType().orElse(null),
                step.getText(),
                step.getDocString().orElse(null),
                step.getDataTable().orElse(null),
                step.getId()
        );
    }

    /**
     * The keyword of the line at the location, as the spec spells it.
     */
    private String keyword(Location location, String parsedKeyword) {
        String originalKeyword = translation.originalKeywords().get(lineIndexOf(location));
        return originalKeyword != null ? originalKeyword : parsedKeyword;
    }

    /**
     * The description of the element whose title line is at the location, with every rewritten line as the spec
     * writes it. The description starts after the blank lines below the title line, one description line per spec
     * line.
     */
    private String description(Location location, String parsedDescription) {
        if (parsedDescription == null || parsedDescription.isEmpty()) {
            return parsedDescription;
        }
        String[] originalLines = translation.originalLines();
        String[] translatedLines = translation.translatedLines();

        int start = lineIndexOf(location) + 1;
        while (start < translatedLines.length && translatedLines[start].isBlank()) {
            start++;
        }

        String[] descriptionLines = parsedDescription.split("\n", -1);
        for (int i = 0; i < descriptionLines.length; i++) {
            int lineIndex = start + i;
            if (translation.isChanged(lineIndex)
                    && descriptionLines[i].strip().equals(translatedLines[lineIndex].strip())) {
                descriptionLines[i] = descriptionLines[i].replace(
                        translatedLines[lineIndex].strip(), originalLines[lineIndex].strip());
            }
        }
        return String.join("\n", descriptionLines);
    }

    private static int lineIndexOf(Location location) {
        return (int) (location.getLine() - 1);
    }
}
