#!/usr/bin/env bash
# =============================================================================
# nnbench (org.apache.hadoop.hdfs.NNBench)
# =============================================================================
# Beschreibung:
#   Belastet den NameNode mit Metadaten-Operationen (Erstellen, Öffnen,
#   Umbenennen, Löschen von Dateien) über einen MapReduce-Job – Standardtool
#   für NameNode-RPC-/Heap-Last bei realistischer Inode-Anzahl (siehe
#   "Sinnvolle Lasttests für 1 TB" in hadooptest.md).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar nnbench \
#     -operation <create_write|open_read|rename|delete> [-maps <default 1>] \
#     [-reduces <default 1>] [-startTime <s seit Epoch, default Start+2min>] \
#     [-blockSize <default 1>] [-bytesToWrite <default 0>] \
#     [-bytesPerChecksum <default 1>] [-numberOfFiles <default 1>] \
#     [-replicationFactorPerFile <default 1>] [-baseDir <default /benchmarks/NNBench>] \
#     [-readFileAfterOpen <true|false, default false>] [-help]
#
# Parameter:
#   -operation      Betriebsmodus (Pflicht): create_write, open_read, rename, delete
#   -maps/-reduces  Anzahl paralleler Tasks
#   -numberOfFiles  Gesamtzahl der Dateien
#   -bytesToWrite   Bytes je Datei (bei create_write)
#   -blockSize      Blockgröße
#   -replicationFactorPerFile  Replikationsfaktor
#   -baseDir        HDFS-Basisverzeichnis
#   -readFileAfterOpen  Bei open_read Datei zusätzlich lesen (nicht nur öffnen)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: erzeugt 1000 leere Dateien mit 4 Maps → /lasttest/nnbench
[ "$#" -eq 0 ] && set -- \
  -operation create_write -maps 4 -reduces 1 -numberOfFiles 1000 \
  -bytesToWrite 0 -replicationFactorPerFile 1 -baseDir /lasttest/nnbench

run "nnbench → $*" \
  hadoop jar "$TESTS_JAR" nnbench "$@"
