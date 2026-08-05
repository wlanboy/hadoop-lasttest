#!/usr/bin/env bash
# =============================================================================
# distbbp (org.apache.hadoop.examples.pi.DistBbp)
# =============================================================================
# Beschreibung:
#   Berechnet verteilt Binärstellen von Pi ab Bit b mit der Bailey-Borwein-
#   Plouffe-Reihe über mehrere MapReduce-Jobs/Threads (aufwendigere,
#   "echte" verteilte Variante von bbp).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar distbbp \
#     <b> <nThreads> <nJobs> <type> <nPart> <remoteDir> <localDir>
#
# Parameter:
#   <b>          Anzahl zu überspringender Bits (berechnet ab Bit b+1)
#   <nThreads>   Anzahl paralleler Worker-Threads
#   <nJobs>      Anzahl Jobs je Summe
#   <type>       'm' Map-seitiger Job, 'r' Reduce-seitiger Job, 'x' Mischtyp
#   <nPart>      Anzahl Teile je Job
#   <remoteDir>  Arbeitsverzeichnis in HDFS für die Jobs
#   <localDir>   Lokales Verzeichnis (auf dem Client-Host) für Zwischen-/Ergebnisdateien
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 1 Bit ab Start, 2 Threads, 2 Jobs, Map-seitig, 2 Teile
[ "$#" -eq 0 ] && set -- \
  1 2 2 m 2 /lasttest/distbbp/work /tmp/lasttest-distbbp

# localDir muss auf dem Client-Host existieren
mkdir -p "${@: -1}" 2>/dev/null || true

run "distbbp → $*" \
  hadoop jar "$EXAMPLES_JAR" distbbp "$@"
