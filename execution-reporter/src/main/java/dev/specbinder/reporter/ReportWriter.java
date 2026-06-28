package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import java.io.IOException;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

public final class ReportWriter {

    private final ObjectMapper objectMapper;

    public ReportWriter() {
        this.objectMapper = new ObjectMapper()
                .registerModule(new JavaTimeModule())
                .enable(SerializationFeature.INDENT_OUTPUT)
                .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
                .setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY);
    }

    /**
     * Writes the feature report to {@code targetFile}, creating parent directories as needed.
     * Overwrites any existing file at the target.
     *
     * <p>The write is atomic: the report is serialized fully to memory first, then written to a
     * sibling temp file and moved into place. If serialization fails (e.g. a non-serializable
     * value slips into the model), it throws <em>before</em> the target is touched, so a crash
     * mid-serialization can never leave a truncated, unparseable report on disk — a previously
     * written valid report survives intact, and a concurrent reader never observes a partial file.
     */
    public void write(FeatureReport report, Path targetFile) throws IOException {
        Path parent = targetFile.getParent();
        if (parent != null) {
            Files.createDirectories(parent);
        }
        byte[] bytes = objectMapper.writeValueAsBytes(report);
        Path dir = parent != null ? parent : targetFile.toAbsolutePath().getParent();
        Path tmp = Files.createTempFile(dir, ".report", ".json.tmp");
        try {
            Files.write(tmp, bytes);
            try {
                Files.move(tmp, targetFile,
                        StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            } catch (AtomicMoveNotSupportedException e) {
                Files.move(tmp, targetFile, StandardCopyOption.REPLACE_EXISTING);
            }
        } finally {
            Files.deleteIfExists(tmp);
        }
    }

    public ObjectMapper objectMapper() {
        return objectMapper;
    }
}
