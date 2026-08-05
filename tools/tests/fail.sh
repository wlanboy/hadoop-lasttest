#!/usr/bin/env bash
# =============================================================================
# fail (org.apache.hadoop.mapreduce.FailJob)
# =============================================================================
# Beschreibung:
#   Job, dessen Mapper oder Reducer absichtlich fehlschlagen. Dient zum
#   Testen der Fehlerbehandlung/Retry-Logik des Frameworks (Task-Retries,
#   Job-Abbruchverhalten), nicht der Durchsatzmessung.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar fail \
#     (-failMappers|-failReducers)
#
# Parameter (genau einer ist Pflicht):
#   -failMappers   Lässt alle Map-Tasks fehlschlagen
#   -failReducers  Lässt alle Reduce-Tasks fehlschlagen
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

[ "$#" -eq 0 ] && set -- -failMappers

run "fail → $*" \
  hadoop jar "$TESTS_JAR" fail "$@"
