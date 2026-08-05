#!/usr/bin/env bash
# =============================================================================
# filebench (org.apache.hadoop.io.FileBench)
# =============================================================================
# Beschreibung:
#   Benchmarkt Lese-/Schreibdurchsatz von SequenceFile- und TextInputFormat
#   mit verschiedenen Kompressionscodecs/-typen.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar filebench \
#     -[no]r -[no]w -[no]seq -[no]txt -[no]zip -[no]pln -[no]blk -[no]rec -dir <working dir>
#
# Parameter:
#   -[no]r / -[no]w        Lese- bzw. Schreib-Task aktivieren/deaktivieren
#   -[no]seq / -[no]txt    SequenceFile- bzw. TextInputFormat testen
#   -[no]zip / -[no]pln    Komprimiert (zip) bzw. unkomprimiert (plain) testen
#   -[no]blk / -[no]rec    Block- bzw. Record-Kompression (nur bei SequenceFile)
#   -dir <pfad>            Arbeitsverzeichnis in HDFS (Pflicht)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: Lesen+Schreiben, SequenceFile, unkomprimiert → /lasttest/filebench
[ "$#" -eq 0 ] && set -- -r -w -seq -pln -dir /lasttest/filebench

run "filebench → $*" \
  hadoop jar "$TESTS_JAR" filebench "$@"
