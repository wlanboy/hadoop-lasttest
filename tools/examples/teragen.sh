#!/usr/bin/env bash
# =============================================================================
# teragen (org.apache.hadoop.examples.terasort.TeraGen)
# =============================================================================
# Beschreibung:
#   Erzeugt Terasort-Eingabedaten (100 Byte/Record). Schreibtest, erste
#   Stufe des teragen → terasort → teravalidate Benchmarks.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar teragen [-D ...] <num rows> <out>
#
# Parameter (-D):
#   mapreduce.job.maps=<n>                     Anzahl paralleler teragen-Maps
#   mapreduce.terasort.num-rows=<n>             Alternative zum Positionsargument
# Positionsargumente:
#   <num rows>   Anzahl Records × 100 Byte = Gesamtvolumen
#   <out>        Zielverzeichnis in HDFS
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 1.000.000 Records (≈100 MB), 2 Maps → /lasttest/teragen/out
[ "$#" -eq 0 ] && set -- \
  -D mapreduce.job.maps=2 \
  1000000 /lasttest/teragen/out

run "teragen → $*" \
  hadoop jar "$EXAMPLES_JAR" teragen "$@"
