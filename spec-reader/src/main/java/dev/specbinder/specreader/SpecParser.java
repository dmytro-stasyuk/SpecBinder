package dev.specbinder.specreader;

import dev.specbinder.specreader.KeywordTranslator.Translation;
import io.cucumber.gherkin.GherkinParser;
import io.cucumber.messages.types.Envelope;
import io.cucumber.messages.types.Feature;
import io.cucumber.messages.types.GherkinDocument;
import io.cucumber.messages.types.ParseError;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;

/**
 * Parses a spec with the keywords of the languages it is read with. A spec in English only, or with a
 * {@code # language:} header, is parsed as written; a spec mixing the keywords of other languages is rewritten to
 * English keywords for the parser, and what the parser read is given back in the spec's own words.
 */
public final class SpecParser {

    private static final GherkinParser GHERKIN_PARSER = GherkinParser.builder().includePickles(false).build();

    /**
     * What parsing a spec gave.
     *
     * @param feature         the Feature the spec holds, if it could be read
     * @param firstParseError the first line the parser couldn't read, if any; the lines after it often fail only
     *                        because of it
     */
    public record ParsedSpec(Optional<Feature> feature, Optional<ParseError> firstParseError) {
    }

    private SpecParser() {
    }

    /**
     * Parses a spec.
     *
     * @param uri      the path the parser names the spec by
     * @param content  the content of the spec
     * @param keywords the keywords the spec is read with
     * @return the Feature the spec holds, or the first line the parser couldn't read
     */
    public static ParsedSpec parse(String uri, String content, SpecKeywords keywords) {

        if (keywords.isReadAsWritten()) {
            return parseAsWritten(uri, content);
        }

        Translation translation = keywords.translator().translate(content);
        ParsedSpec parsed = parseAsWritten(uri, translation.content());
        FeatureRestorer restorer = new FeatureRestorer(translation);
        return new ParsedSpec(
                parsed.feature().map(restorer::restoreFeature),
                parsed.firstParseError().map(restorer::restoreParseError));
    }

    private static ParsedSpec parseAsWritten(String uri, String content) {

        List<Envelope> envelopes = GHERKIN_PARSER.parse(uri, content.getBytes(StandardCharsets.UTF_8)).toList();

        Optional<ParseError> firstParseError = envelopes.stream()
                .map(Envelope::getParseError)
                .flatMap(Optional::stream)
                .findFirst();
        Optional<Feature> feature = envelopes.stream()
                .map(Envelope::getGherkinDocument)
                .flatMap(Optional::stream)
                .findFirst()
                .flatMap(GherkinDocument::getFeature);
        return new ParsedSpec(feature, firstParseError);
    }
}
