#!/usr/bin/env bash
# =============================================================================
# randomwriter (org.apache.hadoop.examples.RandomWriter)
# =============================================================================
# Beschreibung:
#   Schreibt zufällige Binärdaten (SequenceFiles) parallel über mehrere Maps
#   nach HDFS. Ersatz für TestDFSIO -write, misst sequenziellen HDFS-
#   Schreibdurchsatz.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar randomwriter [-D ...] <out>
#
# Parameter (-D):
#   mapreduce.job.maps=<n>                  Anzahl paralleler Map-Tasks
#   mapreduce.randomwriter.bytespermap=<n>  Bytes je Map-Task
#   mapreduce.randomwriter.minkey=<n>       Minimale Schlüssellänge (Default: 10)
#   mapreduce.randomwriter.maxkey=<n>       Maximale Schlüssellänge (Default: 1000)
#   mapreduce.randomwriter.minvalue=<n>     Minimale Wertlänge (Default: 0)
#   mapreduce.randomwriter.maxvalue=<n>     Maximale Wertlänge (Default: 20000)
#
# Gesamtvolumen = mapreduce.job.maps × mapreduce.randomwriter.bytespermap
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 4 Maps × 128 MB = 512 MB → /lasttest/randomwriter/out
# Eigene Werte: ./randomwriter.sh -D mapreduce.job.maps=8 -D mapreduce.randomwriter.bytespermap=268435456 /lasttest/randomwriter/out
[ "$#" -eq 0 ] && set -- \
  -D mapreduce.job.maps=4 \
  -D mapreduce.randomwriter.bytespermap=134217728 \
  /lasttest/randomwriter/out

run "randomwriter → $*" \
  hadoop jar "$EXAMPLES_JAR" randomwriter "$@"
