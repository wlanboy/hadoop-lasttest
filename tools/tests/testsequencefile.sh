#!/usr/bin/env bash
# =============================================================================
# testsequencefile (org.apache.hadoop.io.TestSequenceFile)
# =============================================================================
# Beschreibung:
#   Testet Lesen/Schreiben/Sortieren/Zusammenführen von SequenceFiles mit
#   binären Schlüssel-Wert-Paaren, inkl. verschiedener Kompressionsverfahren.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar testsequencefile \
#     [-count N] [-seed #] [-check] [-compressType <NONE|RECORD|BLOCK>] \
#     -codec <compressionCodec> \
#     [[-rwonly] | {[-megabytes M] [-factor F] [-nocreate] [-fast] [-merge]}] <file>
#
# Parameter:
#   -count N          Anzahl Records
#   -seed              Zufallsseed
#   -check             Nach dem Schreiben lesend verifizieren
#   -compressType      NONE, RECORD oder BLOCK
#   -codec <klasse>    Kompressions-Codec-Klasse (Pflicht)
#   -megabytes/-factor Größe des Sortier-/Merge-Tests
#   -rwonly            Nur Lese-/Schreibtest, kein Sortieren/Mergen
#   <file>             Lokale Zieldatei
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 100.000 Records, unkomprimiert, lokale Datei im Scratch-Verzeichnis
[ "$#" -eq 0 ] && set -- \
  -count 100000 -codec org.apache.hadoop.io.compress.DefaultCodec \
  -check /tmp/lasttest-testsequencefile.seq

run "testsequencefile → $*" \
  hadoop jar "$TESTS_JAR" testsequencefile "$@"
