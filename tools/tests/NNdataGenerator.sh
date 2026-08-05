#!/usr/bin/env bash
# =============================================================================
# NNdataGenerator (org.apache.hadoop.fs.loadGenerator.DataGenerator)
# =============================================================================
# Beschreibung:
#   Erzeugt in HDFS die tatsächlichen Testdateien anhand der zuvor mit
#   NNstructureGenerator.sh erstellten Verzeichnisstruktur. Zweite Stufe der
#   NN-Last-Kette: NNstructureGenerator → NNdataGenerator → NNloadGenerator(MR).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar NNdataGenerator \
#     -inDir <inDir> -root <root>
#
# Parameter:
#   -inDir <dir>  Lokales Verzeichnis mit der Struktur-Beschreibung (Ausgabe von NNstructureGenerator)
#   -root <pfad>  HDFS-Wurzelverzeichnis, unter dem die Struktur/Dateien angelegt werden
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: nutzt die Struktur aus NNstructureGenerator.sh → /lasttest/nnload
[ "$#" -eq 0 ] && set -- \
  -inDir /tmp/lasttest-nnload/structure -root /lasttest/nnload

run "NNdataGenerator → $*" \
  hadoop jar "$TESTS_JAR" NNdataGenerator "$@"
