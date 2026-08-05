#!/usr/bin/env bash
# =============================================================================
# mapredtest (org.apache.hadoop.mapred.TestMapRed)
# =============================================================================
# Beschreibung:
#   Einfacher End-to-End-Funktionstest des MapReduce-Frameworks anhand eines
#   Sortier-/Zähljobs über zufällig erzeugte Zahlen. Eher Korrektheits- als
#   Lasttest, aber brauchbar als schneller Smoke-Test nach Cluster-Änderungen.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar mapredtest <range> <counts>
#
# Parameter:
#   <range>   Wertebereich der erzeugten Zufallszahlen
#   <counts>  Anzahl erzeugter Zahlen je Map
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

[ "$#" -eq 0 ] && set -- 10 100000

run "mapredtest → $*" \
  hadoop jar "$TESTS_JAR" mapredtest "$@"
