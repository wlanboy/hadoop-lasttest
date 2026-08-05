#!/usr/bin/env bash
# =============================================================================
# threadedmapbench (org.apache.hadoop.mapred.ThreadedMapBenchmark)
# =============================================================================
# Beschreibung:
#   Vergleicht die Performance von Map-Tasks mit mehreren Spills gegenüber
#   Maps mit nur einem Spill – misst den Einfluss der Spill-/Merge-
#   Konfiguration auf den Durchsatz.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar threadedmapbench \
#     [-dataSizePerMap <default 128 mb>] [-numSpillsPerMap <default 2>] \
#     [-numMapsPerHost <default 1>]
#
# Parameter:
#   -dataSizePerMap   Datenmenge je Map-Task
#   -numSpillsPerMap  Anzahl Spills je Map-Task
#   -numMapsPerHost   Anzahl paralleler Maps je Host
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

[ "$#" -eq 0 ] && set -- -dataSizePerMap 128 -numSpillsPerMap 2 -numMapsPerHost 1

run "threadedmapbench → $*" \
  hadoop jar "$TESTS_JAR" threadedmapbench "$@"
