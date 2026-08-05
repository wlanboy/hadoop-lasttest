#!/usr/bin/env bash
# =============================================================================
# testbigmapoutput (org.apache.hadoop.mapred.BigMapOutput)
# =============================================================================
# Beschreibung:
#   Verarbeitet eine sehr große, nicht splitbare Datei mit Identity-Map/
#   Reduce. Testet Umgang mit einzelnen sehr großen Records/Splits statt
#   vieler kleiner (Gegenstück zu nnbench).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar testbigmapoutput \
#     -input <input-dir> -output <output-dir> [-create <filesize in MB>]
#
# Parameter:
#   -input <dir>    Eingabeverzeichnis
#   -output <dir>   Ausgabeverzeichnis
#   -create <MB>    Erzeugt vorab eine Testdatei der angegebenen Größe im Eingabeverzeichnis
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: erzeugt eine 512-MB-Testdatei → /lasttest/testbigmapoutput
[ "$#" -eq 0 ] && set -- \
  -input /lasttest/testbigmapoutput/in -output /lasttest/testbigmapoutput/out -create 512

run "testbigmapoutput → $*" \
  hadoop jar "$TESTS_JAR" testbigmapoutput "$@"
