package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonValue;

public enum Status {
    PASSED("passed"),
    FAILED("failed"),
    ABORTED("aborted"),
    SKIPPED("skipped");

    private final String wireValue;

    Status(String wireValue) {
        this.wireValue = wireValue;
    }

    @JsonValue
    public String wireValue() {
        return wireValue;
    }
}
