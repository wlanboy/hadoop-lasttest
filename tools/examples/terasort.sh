#!/usr/bin/env bash
# =============================================================================
# terasort (org.apache.hadoop.examples.terasort.TeraSort)
# =============================================================================
# Beschreibung:
#   Sortiert von teragen erzeugte Daten. Repräsentativer Gesamtcluster-
#   Benchmark (Lese-, Netzwerk- und Schreibdurchsatz durch Map-, Shuffle- und
#   Reduce-Phase). Benötigt Eingabedaten aus teragen.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar terasort [-D ...] <in> <out>
#
# Parameter (-D):
#   mapreduce.job.reduces=<n>                    Anzahl Reduce-Tasks
#   mapreduce.terasort.output.replication=<n>    Replikationsfaktor der Ausgabe
#   mapreduce.terasort.simplepartitioner=<bool>  Einfacher statt Sample-Partitioner
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: sortiert /lasttest/teragen/out mit 2 Reduces → /lasttest/terasort/out
[ "$#" -eq 0 ] && set -- \
  -D mapreduce.job.reduces=2 \
  /lasttest/teragen/out /lasttest/terasort/out

run "terasort → $*" \
  hadoop jar "$EXAMPLES_JAR" terasort "$@"
