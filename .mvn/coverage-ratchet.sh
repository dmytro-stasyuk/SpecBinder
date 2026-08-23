#!/usr/bin/env bash
#
# Coverage ratchet — raise a module's JaCoCo thresholds to the coverage it actually achieved.
#
# Reads the bundle totals from the module's JaCoCo CSV report and, when an achieved ratio
# (floored to two decimals) beats the value currently configured in that module's pom, rewrites
# the property in place. It only ever raises: a partial run, or one that lost coverage, leaves
# the pom untouched.
#
# Usage: coverage-ratchet.sh <path/to/jacoco.csv> <path/to/pom.xml>
#
# Run it only after a clean build. The JaCoCo agent appends to jacoco.exec by default, so a
# module rebuilt without `clean` reports the union of several runs — ratcheting on that writes a
# threshold no single run can meet, and the damage lands in the pom.

set -euo pipefail

csv="${1:?usage: coverage-ratchet.sh <jacoco.csv> <pom.xml>}"
pom="${2:?usage: coverage-ratchet.sh <jacoco.csv> <pom.xml>}"

if [ ! -f "$csv" ]; then
  echo "coverage-ratchet: no coverage data at $csv — skipping"
  exit 0
fi
if [ ! -f "$pom" ]; then
  echo "coverage-ratchet: no pom at $pom — skipping"
  exit 0
fi

# jacoco.csv columns: 6=BRANCH_MISSED 7=BRANCH_COVERED 8=LINE_MISSED 9=LINE_COVERED.
# Summing every class row reproduces the BUNDLE totals that the jacoco-check rule is evaluated
# against. Floor to two decimals so ordinary run-to-run fluctuation doesn't immediately red the
# next build.
ratios=$(awk -F, '
  NR > 1 { bm += $6; bc += $7; lm += $8; lc += $9 }
  END {
    if (lm + lc == 0 || bm + bc == 0) exit 1
    printf "%.2f %.2f\n", int(lc / (lm + lc) * 100) / 100, int(bc / (bm + bc) * 100) / 100
  }' "$csv") || {
  echo "coverage-ratchet: $csv carries no line/branch data — skipping"
  exit 0
}
read -r achievedLine achievedBranch <<< "$ratios"

# The value the pom currently asks for, or empty when it doesn't declare the property at all.
current_of() {
  perl -ne "print \$1 if m{<\Q$1\E>([0-9.]+)</\Q$1\E>}" "$pom"
}

currentLine=$(current_of jacoco.line.coverage)
currentBranch=$(current_of jacoco.branch.coverage)

# Ratchet only a run that clears the gate on BOTH metrics. Checking this here rather than relying
# on jacoco-check having already run keeps the outcome independent of plugin ordering within the
# verify phase — which differs between modules once the profile is inherited from the parent — and
# stops a build that is about to go red from raising the metric that happened to improve.
gate_met() {
  local achieved="$1" current="$2"
  [ -z "$current" ] && return 0   # nothing configured means nothing to fall short of
  awk -v a="$achieved" -v b="$current" 'BEGIN { exit !(a >= b) }'
}

if ! gate_met "$achievedLine" "$currentLine" || ! gate_met "$achievedBranch" "$currentBranch"; then
  echo "coverage-ratchet: achieved lines $achievedLine / branches $achievedBranch is below the" \
       "configured ${currentLine:-none} / ${currentBranch:-none} — not ratcheting"
  exit 0
fi

# Raise <property> to the achieved ratio when it beats what the pom currently asks for.
bump() {
  local property="$1" achieved="$2" current="$3"
  if [ -z "$current" ]; then
    echo "coverage-ratchet: $pom declares no <$property> — leaving it alone"
    return
  fi
  if awk -v a="$achieved" -v b="$current" 'BEGIN { exit !(a > b) }'; then
    perl -i -pe "s{<\Q$property\E>[0-9.]+</\Q$property\E>}{<$property>$achieved</$property>}" "$pom"
    echo "coverage-ratchet: $property raised $current -> $achieved"
  else
    echo "coverage-ratchet: $property stays at $current (achieved $achieved)"
  fi
}

bump jacoco.line.coverage   "$achievedLine"   "$currentLine"
bump jacoco.branch.coverage "$achievedBranch" "$currentBranch"
