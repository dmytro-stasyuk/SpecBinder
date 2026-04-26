package dev.specbinder.processor.support;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Reads the SpecBinder version from the bundled {@code specbinder-version.properties} resource.
 */
public final class SpecBinderVersion {

    private static final String UNKNOWN = "unknown";
    private static final String RESOURCE = "/specbinder-version.properties";

    private static final String VERSION = loadVersion();

    private SpecBinderVersion() {
    }

    /**
     * Returns the current SpecBinder version, or {@code "unknown"} if it cannot be determined.
     *
     * @return the version string
     */
    public static String get() {
        return VERSION;
    }

    private static String loadVersion() {
        try (InputStream in = SpecBinderVersion.class.getResourceAsStream(RESOURCE)) {
            if (in == null) {
                return UNKNOWN;
            }
            Properties props = new Properties();
            props.load(in);
            String version = props.getProperty("version");
            return (version == null || version.isBlank() || version.contains("${")) ? UNKNOWN : version;
        } catch (IOException e) {
            return UNKNOWN;
        }
    }
}
