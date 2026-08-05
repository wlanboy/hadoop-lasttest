#!/usr/bin/env bash
# =============================================================================
# mrbench (org.apache.hadoop.mapred.MRBench)
# =============================================================================
# Beschreibung:
#   Führt wiederholt viele kleine MapReduce-Jobs aus, um den Job-Startup-
#   Overhead und die Scheduling-Latenz zu messen (Gegenteil von terasort:
#   viele kurze statt weniger großer Jobs).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar mrbench \
#     [-baseDir <base DFS path, default /benchmarks/MRBench>] \
#     [-jar <lokaler Pfad zur Job-Jar>] [-numRuns <default 1>] \
#     [-maps <default 2>] [-reduces <default 1>] [-inputLines <default 1>] \
#     [-inputType <ascending|descending|random>] [-verbose]
#
# Parameter:
#   -baseDir       HDFS-Basisverzeichnis für Zwischendaten
#   -numRuns       Anzahl Wiederholungen des Jobs
#   -maps/-reduces Anzahl Tasks je Einzeljob
#   -inputLines    Anzahl Eingabezeilen je Lauf
#   -inputType     Sortierreihenfolge der generierten Eingabe
#   -verbose       Ausführlichere Ausgabe
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 10 Läufe kleiner Jobs → /lasttest/mrbench
[ "$#" -eq 0 ] && set -- \
  -baseDir /lasttest/mrbench -numRuns 10 -maps 2 -reduces 1 -inputLines 1

run "mrbench → $*" \
  hadoop jar "$TESTS_JAR" mrbench "$@"
