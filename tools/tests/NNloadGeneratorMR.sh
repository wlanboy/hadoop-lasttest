#!/usr/bin/env bash
# =============================================================================
# NNloadGeneratorMR (org.apache.hadoop.fs.loadGenerator.LoadGeneratorMR)
# =============================================================================
# Beschreibung:
#   Wie NNloadGenerator.sh, führt die Lastgenerierung gegen den NameNode aber
#   verteilt als MapReduce-Job über mehrere Cluster-Knoten aus statt lokal
#   von einem einzelnen Client-Host.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar NNloadGeneratorMR \
#     -mr <numMapJobs> <outputDir> [MÜSSEN die ersten 3 Argumente sein] \
#     -readProbability <p> -writeProbability <p> -root <root> \
#     -maxDelayBetweenOps <ms> -numOfThreads <n> -elapsedTime <sek> \
#     -startTime <ms> -scriptFile <datei> -flagFile <datei>
#
# Parameter:
#   -mr <numMapJobs> <outputDir>  MUSS als erste drei Argumente stehen;
#                                  Anzahl Map-Tasks und Ausgabeverzeichnis in HDFS
#   restliche Parameter: siehe NNloadGenerator.sh
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 4 Map-Jobs → /lasttest/nnloadmr/out
[ "$#" -eq 0 ] && set -- \
  -mr 4 /lasttest/nnloadmr/out \
  -readProbability 0.5 -writeProbability 0.5 -root /lasttest/nnload \
  -maxDelayBetweenOps 100 -numOfThreads 4 -elapsedTime 120

run "NNloadGeneratorMR → $*" \
  hadoop jar "$TESTS_JAR" NNloadGeneratorMR "$@"
