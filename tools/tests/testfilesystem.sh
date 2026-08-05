#!/usr/bin/env bash
# =============================================================================
# testfilesystem (org.apache.hadoop.fs.TestFileSystem)
# =============================================================================
# Beschreibung:
#   Testet paralleles Lesen/Schreiben/Suchen (seek) auf dem Dateisystem über
#   MapReduce-Tasks. Funktionstest mit Last-Charakter, prüft grundlegende
#   FileSystem-API-Operationen unter Parallelität.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar testfilesystem \
#     -files N -megaBytes M [-noread] [-nowrite] [-noseek] [-fastcheck]
#
# Parameter:
#   -files N       Anzahl paralleler Testdateien
#   -megaBytes M   Größe je Datei in MB
#   -noread        Lesetest überspringen
#   -nowrite       Schreibtest überspringen
#   -noseek        Seek-Test überspringen
#   -fastcheck     Schnellere, weniger gründliche Prüfung
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

[ "$#" -eq 0 ] && set -- -files 10 -megaBytes 10

run "testfilesystem → $*" \
  hadoop jar "$TESTS_JAR" testfilesystem "$@"
