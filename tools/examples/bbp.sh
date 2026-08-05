#!/usr/bin/env bash
# =============================================================================
# bbp (org.apache.hadoop.examples.BaileyBorweinPlouffe)
# =============================================================================
# Beschreibung:
#   Berechnet Hexadezimalstellen von Pi ab einer Startposition mittels der
#   Bailey-Borwein-Plouffe-Formel über einen MapReduce-Job (jede Map-Task
#   berechnet einen unabhängigen Teilbereich, kein Shuffle nötig).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar bbp <startDigit> <nDigits> <nMaps> <workingDir>
#
# Parameter:
#   <startDigit>  Erste zu berechnende Hex-Ziffer (0-basiert)
#   <nDigits>     Anzahl zu berechnender Hex-Ziffern
#   <nMaps>       Anzahl paralleler Map-Tasks
#   <workingDir>  Arbeitsverzeichnis in HDFS für Zwischenergebnisse
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 100 Hex-Ziffern ab Position 1, 4 Maps → /lasttest/bbp/work
[ "$#" -eq 0 ] && set -- \
  1 100 4 /lasttest/bbp/work

run "bbp → $*" \
  hadoop jar "$EXAMPLES_JAR" bbp "$@"
