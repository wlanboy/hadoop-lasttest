#!/usr/bin/env bash
# =============================================================================
# nnbenchWithoutMR (org.apache.hadoop.hdfs.NNBenchWithoutMR)
# =============================================================================
# Beschreibung:
#   Wie nnbench.sh, belastet den NameNode aber direkt über einen einzelnen
#   Client-Prozess ohne MapReduce (kein Job-Scheduling-Overhead, reiner
#   RPC-Test von diesem Host aus).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar nnbenchWithoutMR \
#     -operation <createWrite|openRead|rename|delete> -baseDir <pfad> \
#     -startTime <s seit Epoch> -numFiles <n> [-replicationFactorPerFile <default 1>] \
#     -blocksPerFile <#> [-bytesPerBlock <default 1>] [-bytesPerChecksum <...>]
#
# Parameter (alle bis auf die mit Default sind Pflicht):
#   -operation       Betriebsmodus: createWrite, openRead, rename, delete
#   -baseDir         HDFS-Basisverzeichnis
#   -startTime       Startzeitpunkt in Sekunden seit Epoch
#   -numFiles        Anzahl Dateien
#   -blocksPerFile   Blöcke je Datei
#   -bytesPerBlock   Bytes je Block (muss Vielfaches von -bytesPerChecksum sein)
#   -replicationFactorPerFile  Replikationsfaktor
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: erzeugt 1000 kleine Dateien, Start in 30s → /lasttest/nnbenchwithoutmr
[ "$#" -eq 0 ] && set -- \
  -operation createWrite -baseDir /lasttest/nnbenchwithoutmr \
  -startTime "$(( $(date +%s) + 30 ))" -numFiles 1000 \
  -replicationFactorPerFile 1 -blocksPerFile 1

run "nnbenchWithoutMR → $*" \
  hadoop jar "$TESTS_JAR" nnbenchWithoutMR "$@"
