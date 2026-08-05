#!/usr/bin/env bash
# =============================================================================
# DFSCIOTest (org.apache.hadoop.fs.DFSCIOTest)
# =============================================================================
# Beschreibung:
#   Verteilter I/O-Benchmark über libhdfs (JNI-Anbindung) zum Messen von
#   Lese-/Schreibdurchsatz. Älterer Vorläufer von TestDFSIO – dort meist die
#   erste Wahl, siehe tests/TestDFSIO.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar DFSCIOTest \
#     -read | -write | -clean [-nrFiles N] [-fileSize MB] [-resFile resultFileName] [-bufferSize Bytes]
#
# Parameter:
#   -read|-write|-clean   Betriebsmodus (Pflicht, genau einer)
#   -nrFiles N            Anzahl paralleler Dateien/Maps
#   -fileSize MB          Größe je Datei in MB
#   -resFile <pfad>       Lokale Ergebnisdatei
#   -bufferSize Bytes     Puffergröße für I/O
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: schreibt 4 Dateien à 64 MB
[ "$#" -eq 0 ] && set -- -write -nrFiles 4 -fileSize 64

run "DFSCIOTest → $*" \
  hadoop jar "$TESTS_JAR" DFSCIOTest "$@"
