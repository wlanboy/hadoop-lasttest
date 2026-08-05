#!/usr/bin/env bash
# =============================================================================
# DistributedFSCheck (org.apache.hadoop.fs.DistributedFSCheck)
# =============================================================================
# Beschreibung:
#   Prüft verteilt die Konsistenz des Dateisystems, indem alle Dateien unter
#   einem Wurzelpfad per MapReduce gelesen werden. Sinnvoll als Abschluss-
#   check nach dem Befüllen von HDFS mit Testdaten (z. B. via teragen/-write).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar DistributedFSCheck \
#     [-root name] [-clean] [-resFile resultFileName] [-bufferSize Bytes] [-stats]
#
# Parameter:
#   -root name       Wurzelverzeichnis, das geprüft wird
#   -clean           Räumt vorher erzeugte Testdaten auf
#   -resFile <pfad>  Lokale Ergebnisdatei
#   -bufferSize      Puffergröße für I/O
#   -stats           Gibt zusätzliche Statistiken aus
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: prüft /lasttest
[ "$#" -eq 0 ] && set -- -root /lasttest -stats

run "DistributedFSCheck → $*" \
  hadoop jar "$TESTS_JAR" DistributedFSCheck "$@"
