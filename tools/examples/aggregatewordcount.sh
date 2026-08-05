#!/usr/bin/env bash
# =============================================================================
# aggregatewordcount (org.apache.hadoop.examples.AggregateWordCount)
# =============================================================================
# Beschreibung:
#   Zählt Wörter in Texteingaben über das generische Aggregate-Framework
#   (ValueAggregatorJob) statt eines eigenen Mappers/Reducers. Benötigt
#   Texteingabe, z. B. aus randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar aggregatewordcount \
#     <inputDirs> <outDir> [numOfReducer [textinputformat|seq [specfile [jobName]]]]
#
# Parameter (alle bis auf die ersten beiden optional):
#   <inputDirs>    Eingabeverzeichnis(se), kommagetrennt
#   <outDir>       Ausgabeverzeichnis
#   numOfReducer   Anzahl Reduce-Tasks (Default: 1)
#   textinputformat|seq   Eingabeformat (Text oder SequenceFile, Default: textinputformat)
#   specfile       Aggregator-Spezifikationsdatei (optional)
#   jobName        Job-Name (optional)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: /lasttest/randomtextwriter/out → /lasttest/aggregatewordcount/out, 1 Reducer
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/aggregatewordcount/out 1 textinputformat

run "aggregatewordcount → $*" \
  hadoop jar "$EXAMPLES_JAR" aggregatewordcount "$@"
