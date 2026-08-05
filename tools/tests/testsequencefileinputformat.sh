#!/usr/bin/env bash
# =============================================================================
# testsequencefileinputformat (org.apache.hadoop.mapred.TestSequenceFileInputFormat)
# =============================================================================
# Beschreibung:
#   Prüft, dass SequenceFileInputFormat Eingabedaten korrekt und vollständig
#   in Splits partitioniert (Selbsttest, erzeugt seine Testdaten intern).
#   Reiner Korrektheitscheck, kein Lasttest.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar testsequencefileinputformat
#
# Parameter: keine – Argumente werden vollständig ignoriert, der interne
# Selbsttest (testFormat()) läuft unabhängig davon.
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

run "testsequencefileinputformat" \
  hadoop jar "$TESTS_JAR" testsequencefileinputformat
