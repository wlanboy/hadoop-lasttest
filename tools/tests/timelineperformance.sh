#!/usr/bin/env bash
# =============================================================================
# timelineperformance (org.apache.hadoop.mapreduce.TimelineServicePerformance)
# =============================================================================
# Beschreibung:
#   Testet Durchsatz und Performance des YARN Timeline Service beim
#   Schreiben von Entities. Relevant nur, wenn der Timeline Service (v1 oder
#   v2) im Cluster aktiviert ist.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar timelineperformance \
#     [-m <maps>] [-v <1|2>] [-mtype <1|2>] [-s <KB je put>] [-t <iterations>] \
#     [-d <hdfs-pfad zu job-history-logs>] [-r <1|2>]
#
# Parameter:
#   -m <n>       Anzahl Mapper
#   -v <1|2>     Timeline-Service-Version
#   -mtype <1|2> Mapper-Typ: 1 = simple entity writer, 2 = jobhistory-Replay
#   -s <KB>      KB je Put (nur mtype=1)
#   -t <n>       Iterationen je Mapper (nur mtype=1)
#   -d <pfad>    HDFS-Wurzelpfad der Job-History-Dateien (nur mtype=2)
#   -r <1|2>     Replay-Modus (nur mtype=2): 1 = alle Entities in einem Put, 2 = einzeln
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 4 Mapper, Timeline Service v1, einfacher Entity-Writer
[ "$#" -eq 0 ] && set -- -m 4 -v 1 -mtype 1 -s 1 -t 100

run "timelineperformance → $*" \
  hadoop jar "$TESTS_JAR" timelineperformance "$@"
