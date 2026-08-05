#!/usr/bin/env bash
# =============================================================================
# largesorter (org.apache.hadoop.mapreduce.LargeSorter)
# =============================================================================
# Beschreibung:
#   Erzeugt zufällige Daten, um große Sortiervorgänge im MapReduce-Framework
#   zu testen (Spill-/Merge-Verhalten bei großen Datenmengen je Map-Task).
#   Kein Positionsargument-Usage-Text – Steuerung ausschließlich über
#   -D-Properties.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar largesorter [-D ...] <out>
#
# Parameter (-D):
#   mapreduce.large-sorter.mbs-per-map=<n>  MB je Map-Task
#   mapreduce.large-sorter.map-tasks=<n>    Anzahl Map-Tasks
#   mapreduce.large-sorter.reduce-tasks=<n> Anzahl Reduce-Tasks
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 4 Maps à 128 MB, 2 Reduces → /lasttest/largesorter/out
[ "$#" -eq 0 ] && set -- \
  -D mapreduce.large-sorter.mbs-per-map=128 \
  -D mapreduce.large-sorter.map-tasks=4 \
  -D mapreduce.large-sorter.reduce-tasks=2 \
  /lasttest/largesorter/out

run "largesorter → $*" \
  hadoop jar "$TESTS_JAR" largesorter "$@"
