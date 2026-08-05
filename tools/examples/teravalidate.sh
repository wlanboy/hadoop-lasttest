#!/usr/bin/env bash
# =============================================================================
# teravalidate (org.apache.hadoop.examples.terasort.TeraValidate)
# =============================================================================
# Beschreibung:
#   Prüft die Sortierkorrektheit einer terasort-Ausgabe. Letzte Stufe des
#   teragen → terasort → teravalidate Benchmarks. Schreibt bei Fehlern einen
#   Report ins Ausgabeverzeichnis.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar teravalidate <in> <report-out>
#
# Parameter:
#   <in>          Ausgabeverzeichnis von terasort
#   <report-out>  Zielverzeichnis für den Prüfbericht
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: prüft /lasttest/terasort/out → /lasttest/teravalidate/report
[ "$#" -eq 0 ] && set -- \
  /lasttest/terasort/out /lasttest/teravalidate/report

run "teravalidate → $*" \
  hadoop jar "$EXAMPLES_JAR" teravalidate "$@"
