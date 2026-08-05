#!/usr/bin/env bash
# =============================================================================
# testmapredsort (org.apache.hadoop.mapred.SortValidator)
# =============================================================================
# Beschreibung:
#   Validiert, dass die vom sort-Beispiel (examples/sort.sh) erzeugte
#   Ausgabe tatsächlich korrekt und vollständig sortiert ist – Korrektheits-
#   check, kein Durchsatztest.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar testmapredsort \
#     [-m <maps>] [-r <reduces>] [-deep] -sortInput <sort-input-dir> -sortOutput <sort-output-dir>
#
# Parameter:
#   -m/-r <n>        Anzahl Map-/Reduce-Tasks für den Validierungsjob
#   -deep            Gründlichere (langsamere) Prüfung
#   -sortInput       Ursprüngliche, unsortierte Eingabe von randomwriter
#   -sortOutput      Sortierte Ausgabe von sort/terasort
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: validiert examples/sort.sh-Ergebnis gegen randomwriter.sh-Eingabe
[ "$#" -eq 0 ] && set -- \
  -sortInput /lasttest/randomwriter/out -sortOutput /lasttest/sort/out

run "testmapredsort → $*" \
  hadoop jar "$TESTS_JAR" testmapredsort "$@"
