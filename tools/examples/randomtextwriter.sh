#!/usr/bin/env bash
# =============================================================================
# randomtextwriter (org.apache.hadoop.examples.RandomTextWriter)
# =============================================================================
# Beschreibung:
#   Schreibt zufälligen Text als SequenceFile nach HDFS. Nützlich um
#   Namespace-Last zu erzeugen (viele Blöcke/Inodes) und als Texteingabe für
#   wordcount/grep.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar randomtextwriter [-D ...] <out>
#
# Parameter (-D):
#   mapreduce.randomtextwriter.bytespermap=<n>  Bytes je Map-Task (Default: 1 GB)
#   mapreduce.randomtextwriter.maps=<n>         Anzahl Map-Tasks
#   mapreduce.randomtextwriter.minwordskey=<n>  Min. Wörter je Key (Default: 5)
#   mapreduce.randomtextwriter.maxwordskey=<n>  Max. Wörter je Key (Default: 10)
#   mapreduce.randomtextwriter.minwordsvalue=<n> Min. Wörter je Value (Default: 5)
#   mapreduce.randomtextwriter.maxwordsvalue=<n> Max. Wörter je Value (Default: 100)
#   mapreduce.output.fileoutputformat.compress=<true|false>  Ausgabe komprimieren
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 4 Maps à 64 MB → /lasttest/randomtextwriter/out
[ "$#" -eq 0 ] && set -- \
  -D mapreduce.randomtextwriter.bytespermap=67108864 \
  -D mapreduce.randomtextwriter.maps=4 \
  /lasttest/randomtextwriter/out

run "randomtextwriter → $*" \
  hadoop jar "$EXAMPLES_JAR" randomtextwriter "$@"
