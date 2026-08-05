#!/usr/bin/env bash
# =============================================================================
# sleep (org.apache.hadoop.mapreduce.SleepJob)
# =============================================================================
# Beschreibung:
#   Job, dessen Mapper/Reducer für konfigurierbare Zeit "schlafen", ohne
#   nennenswerte CPU/I/O-Last zu erzeugen. Testet Scheduling-Verhalten und
#   Slot-/Container-Durchsatz des Clusters unter vielen gleichzeitigen Tasks.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar sleep \
#     [-m numMapper] [-r numReducer] [-mt mapSleepTime (msec)] \
#     [-rt reduceSleepTime (msec)] [-recordt recordSleepTime (msec)] [-name]
#
# Parameter:
#   -m <n>        Anzahl Map-Tasks
#   -r <n>        Anzahl Reduce-Tasks
#   -mt <ms>      Schlafzeit je Map-Task
#   -rt <ms>      Schlafzeit je Reduce-Task
#   -recordt <ms> Schlafzeit je verarbeitetem Datensatz
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

[ "$#" -eq 0 ] && set -- -m 10 -r 5 -mt 1000 -rt 1000

run "sleep → $*" \
  hadoop jar "$TESTS_JAR" sleep "$@"
