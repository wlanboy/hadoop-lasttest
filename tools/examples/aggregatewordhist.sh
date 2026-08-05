#!/usr/bin/env bash
# =============================================================================
# aggregatewordhist (org.apache.hadoop.examples.AggregateWordHistogram)
# =============================================================================
# Beschreibung:
#   Berechnet ein Histogramm der Worthäufigkeiten über das generische
#   Aggregate-Framework (ValueAggregatorJob). Benötigt Texteingabe, z. B.
#   aus randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar aggregatewordhist \
#     <inputDirs> <outDir> [numOfReducer [textinputformat|seq [specfile [jobName]]]]
#
# Parameter: siehe aggregatewordcount.sh (identischer ValueAggregatorJob-Aufruf).
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: /lasttest/randomtextwriter/out → /lasttest/aggregatewordhist/out, 1 Reducer
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/aggregatewordhist/out 1 textinputformat

run "aggregatewordhist → $*" \
  hadoop jar "$EXAMPLES_JAR" aggregatewordhist "$@"
