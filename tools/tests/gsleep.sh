#!/usr/bin/env bash
# =============================================================================
# gsleep (org.apache.hadoop.mapreduce.GrowingSleepJob)
# =============================================================================
# Beschreibung:
#   Wie sleep.sh (Mapper/Reducer schlafen konfigurierbar lange), belegt aber
#   zusätzlich pro verarbeitetem Datensatz wachsend Heap-Speicher – simuliert
#   Speicherdruck auf den Task-Containern.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar gsleep \
#     [-m numMapper] [-r numReducer] [-mt mapSleepTime (msec)] \
#     [-rt reduceSleepTime (msec)] [-recordt recordSleepTime (msec)] [-name]
#
# Parameter:
#   -m <n>        Anzahl Map-Tasks
#   -r <n>        Anzahl Reduce-Tasks
#   -mt <ms>      Schlafzeit je Map-Task
#   -rt <ms>      Schlafzeit je Reduce-Task
#   -recordt <ms> Schlafzeit je verarbeitetem Datensatz
#
# Hinweis: Der intern gedruckte Usage-Text lautet "SleepJob ...", gemeint ist
# aber der über "gsleep" registrierte GrowingSleepJob.
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

[ "$#" -eq 0 ] && set -- -m 4 -r 2 -mt 1000 -rt 1000 -recordt 100

run "gsleep → $*" \
  hadoop jar "$TESTS_JAR" gsleep "$@"
