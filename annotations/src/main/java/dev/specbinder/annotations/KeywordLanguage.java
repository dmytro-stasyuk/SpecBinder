package dev.specbinder.annotations;

/**
 * A language whose Gherkin keywords a spec may use, e.g. {@code Funktionalität}, {@code Angenommen} and
 * {@code Wenn} for {@link #GERMAN}.
 * <p>
 * The languages a spec without a {@code # language:} header may use are set with
 * {@link Gherkin2JUnitOptions#keywordLanguages()}. There is one constant for each language Gherkin supports, named
 * after the language in English; a language written in more than one script names its script
 * ({@link #SERBIAN_CYRILLIC}, {@link #SERBIAN_LATIN}), and the playful English variants start with {@code ENGLISH_}
 * ({@link #ENGLISH_PIRATE}).
 */
public enum KeywordLanguage {

    /** Afrikaans, Gherkin code {@code af}. */
    AFRIKAANS("af"),

    /** Armenian (հայերեն), Gherkin code {@code am}. */
    ARMENIAN("am"),

    /** Amharic (አማርኛ), Gherkin code {@code amh}. */
    AMHARIC("amh"),

    /** Aragonese (Aragonés), Gherkin code {@code an}. */
    ARAGONESE("an"),

    /** Arabic (العربية), Gherkin code {@code ar}. */
    ARABIC("ar"),

    /** Asturian (asturianu), Gherkin code {@code ast}. */
    ASTURIAN("ast"),

    /** Azerbaijani (Azərbaycanca), Gherkin code {@code az}. */
    AZERBAIJANI("az"),

    /** Belarusian (Беларуская), Gherkin code {@code be}. */
    BELARUSIAN("be"),

    /** Bulgarian (български), Gherkin code {@code bg}. */
    BULGARIAN("bg"),

    /** Malay (Bahasa Melayu), Gherkin code {@code bm}. */
    MALAY("bm"),

    /** Bosnian (Bosanski), Gherkin code {@code bs}. */
    BOSNIAN("bs"),

    /** Catalan (català), Gherkin code {@code ca}. */
    CATALAN("ca"),

    /** Czech (Česky), Gherkin code {@code cs}. */
    CZECH("cs"),

    /** Welsh (Cymraeg), Gherkin code {@code cy-GB}. */
    WELSH("cy-GB"),

    /** Danish (dansk), Gherkin code {@code da}. */
    DANISH("da"),

    /** German (Deutsch), Gherkin code {@code de}. */
    GERMAN("de"),

    /** Greek (Ελληνικά), Gherkin code {@code el}. */
    GREEK("el"),

    /** Emoji (😀), Gherkin code {@code em}. */
    EMOJI("em"),

    /** English, Gherkin code {@code en}. */
    ENGLISH("en"),

    /** Scouse, Gherkin code {@code en-Scouse}. */
    ENGLISH_SCOUSE("en-Scouse"),

    /** Australian, Gherkin code {@code en-au}. */
    ENGLISH_AUSTRALIAN("en-au"),

    /** LOLCAT, Gherkin code {@code en-lol}. */
    ENGLISH_LOLCAT("en-lol"),

    /** Old English (Englisc), Gherkin code {@code en-old}. */
    ENGLISH_OLD("en-old"),

    /** Pirate, Gherkin code {@code en-pirate}. */
    ENGLISH_PIRATE("en-pirate"),

    /** Texas, Gherkin code {@code en-tx}. */
    ENGLISH_TEXAS("en-tx"),

    /** Esperanto, Gherkin code {@code eo}. */
    ESPERANTO("eo"),

    /** Spanish (español), Gherkin code {@code es}. */
    SPANISH("es"),

    /** Estonian (eesti keel), Gherkin code {@code et}. */
    ESTONIAN("et"),

    /** Persian (فارسی), Gherkin code {@code fa}. */
    PERSIAN("fa"),

    /** Finnish (suomi), Gherkin code {@code fi}. */
    FINNISH("fi"),

    /** French (français), Gherkin code {@code fr}. */
    FRENCH("fr"),

    /** Irish (Gaeilge), Gherkin code {@code ga}. */
    IRISH("ga"),

    /** Gujarati (ગુજરાતી), Gherkin code {@code gj}. */
    GUJARATI("gj"),

    /** Galician (galego), Gherkin code {@code gl}. */
    GALICIAN("gl"),

    /** Hebrew (עברית), Gherkin code {@code he}. */
    HEBREW("he"),

    /** Hindi (हिंदी), Gherkin code {@code hi}. */
    HINDI("hi"),

    /** Croatian (hrvatski), Gherkin code {@code hr}. */
    CROATIAN("hr"),

    /** Creole (kreyòl), Gherkin code {@code ht}. */
    CREOLE("ht"),

    /** Hungarian (magyar), Gherkin code {@code hu}. */
    HUNGARIAN("hu"),

    /** Indonesian (Bahasa Indonesia), Gherkin code {@code id}. */
    INDONESIAN("id"),

    /** Icelandic (Íslenska), Gherkin code {@code is}. */
    ICELANDIC("is"),

    /** Italian (italiano), Gherkin code {@code it}. */
    ITALIAN("it"),

    /** Japanese (日本語), Gherkin code {@code ja}. */
    JAPANESE("ja"),

    /** Javanese (Basa Jawa), Gherkin code {@code jv}. */
    JAVANESE("jv"),

    /** Georgian (ქართული), Gherkin code {@code ka}. */
    GEORGIAN("ka"),

    /** Kannada (ಕನ್ನಡ), Gherkin code {@code kn}. */
    KANNADA("kn"),

    /** Korean (한국어), Gherkin code {@code ko}. */
    KOREAN("ko"),

    /** Lithuanian (lietuvių kalba), Gherkin code {@code lt}. */
    LITHUANIAN("lt"),

    /** Luxemburgish (Lëtzebuergesch), Gherkin code {@code lu}. */
    LUXEMBURGISH("lu"),

    /** Latvian (latviešu), Gherkin code {@code lv}. */
    LATVIAN("lv"),

    /** Macedonian (Македонски), Gherkin code {@code mk-Cyrl}. */
    MACEDONIAN_CYRILLIC("mk-Cyrl"),

    /** Macedonian (Latin) (Makedonski (Latinica)), Gherkin code {@code mk-Latn}. */
    MACEDONIAN_LATIN("mk-Latn"),

    /** Malayalam (മലയാളം), Gherkin code {@code ml}. */
    MALAYALAM("ml"),

    /** Mongolian (монгол), Gherkin code {@code mn}. */
    MONGOLIAN("mn"),

    /** Marathi (मराठी), Gherkin code {@code mr}. */
    MARATHI("mr"),

    /** Nepali (नेपाली), Gherkin code {@code ne}. */
    NEPALI("ne"),

    /** Dutch (Nederlands), Gherkin code {@code nl}. */
    DUTCH("nl"),

    /** Norwegian (norsk), Gherkin code {@code no}. */
    NORWEGIAN("no"),

    /** Panjabi (ਪੰਜਾਬੀ), Gherkin code {@code pa}. */
    PANJABI("pa"),

    /** Polish (polski), Gherkin code {@code pl}. */
    POLISH("pl"),

    /** Portuguese (português), Gherkin code {@code pt}. */
    PORTUGUESE("pt"),

    /** Romanian (română), Gherkin code {@code ro}. */
    ROMANIAN("ro"),

    /** Russian (русский), Gherkin code {@code ru}. */
    RUSSIAN("ru"),

    /** Slovak (Slovensky), Gherkin code {@code sk}. */
    SLOVAK("sk"),

    /** Slovenian (Slovenski), Gherkin code {@code sl}. */
    SLOVENIAN("sl"),

    /** Serbian (Српски), Gherkin code {@code sr-Cyrl}. */
    SERBIAN_CYRILLIC("sr-Cyrl"),

    /** Serbian (Latin) (Srpski (Latinica)), Gherkin code {@code sr-Latn}. */
    SERBIAN_LATIN("sr-Latn"),

    /** Swedish (Svenska), Gherkin code {@code sv}. */
    SWEDISH("sv"),

    /** Tamil (தமிழ்), Gherkin code {@code ta}. */
    TAMIL("ta"),

    /** Telugu (తెలుగు), Gherkin code {@code te}. */
    TELUGU("te"),

    /** Thai (ไทย), Gherkin code {@code th}. */
    THAI("th"),

    /** Klingon (tlhIngan), Gherkin code {@code tlh}. */
    KLINGON("tlh"),

    /** Turkish (Türkçe), Gherkin code {@code tr}. */
    TURKISH("tr"),

    /** Tatar (Татарча), Gherkin code {@code tt}. */
    TATAR("tt"),

    /** Ukrainian (Українська), Gherkin code {@code uk}. */
    UKRAINIAN("uk"),

    /** Urdu (اردو), Gherkin code {@code ur}. */
    URDU("ur"),

    /** Uzbek (Узбекча), Gherkin code {@code uz}. */
    UZBEK("uz"),

    /** Vietnamese (Tiếng Việt), Gherkin code {@code vi}. */
    VIETNAMESE("vi"),

    /** Chinese simplified (简体中文), Gherkin code {@code zh-CN}. */
    CHINESE_SIMPLIFIED("zh-CN"),

    /** Chinese traditional (繁體中文), Gherkin code {@code zh-TW}. */
    CHINESE_TRADITIONAL("zh-TW");

    private final String code;

    KeywordLanguage(String code) {
        this.code = code;
    }

    /**
     * Returns the code Gherkin knows the language by, the same code a {@code # language:} header takes, e.g.
     * {@code de} for {@link #GERMAN}.
     *
     * @return the Gherkin code of the language
     */
    public String code() {
        return code;
    }
}
