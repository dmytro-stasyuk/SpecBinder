package dev.specbinder.reporter;

public class Summary {

    private int passed;
    private int failed;
    private int aborted;
    private int skipped;

    public Summary() {
    }

    public void increment(Status status) {
        switch (status) {
            case PASSED -> passed++;
            case FAILED -> failed++;
            case ABORTED -> aborted++;
            case SKIPPED -> skipped++;
        }
    }

    public int getPassed() {
        return passed;
    }

    public void setPassed(int passed) {
        this.passed = passed;
    }

    public int getFailed() {
        return failed;
    }

    public void setFailed(int failed) {
        this.failed = failed;
    }

    public int getAborted() {
        return aborted;
    }

    public void setAborted(int aborted) {
        this.aborted = aborted;
    }

    public int getSkipped() {
        return skipped;
    }

    public void setSkipped(int skipped) {
        this.skipped = skipped;
    }
}
