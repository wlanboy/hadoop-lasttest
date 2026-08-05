#!/usr/bin/env bash
# =============================================================================
# sort (org.apache.hadoop.examples.Sort)
# =============================================================================
# Beschreibung:
#   Sortiert SequenceFiles (z. B. von randomwriter erzeugt). Mit
#   mapreduce.job.reduces=0 läuft nur die Map-Phase → reiner HDFS-Lesetest
#   ohne Shuffle. Entspricht TestDFSIO -read. Benötigt Eingabedaten, z. B.
#   aus randomwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar sort [-r <reduces>]
#     [-inFormat <InputFormat-Klasse>] [-outFormat <OutputFormat-Klasse>]
#     [-outKey <Key-Klasse>] [-outValue <Value-Klasse>]
#     [-totalOrder <pcnt> <num samples> <max splits>] <in> <out>
#
# Parameter:
#   -r <n>            Anzahl Reduce-Tasks (0 = nur Map-Phase, reiner Lesetest)
#   -inFormat/-outFormat  Alternative Input-/OutputFormat-Klasse
#   -outKey/-outValue     Alternative Key-/Value-Klasse
#   -totalOrder       Globale Sortierung über TotalOrderPartitioner
#   -D mapreduce.job.reduces=<n>  Alternative zu -r über generische Option
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: sortiert die Ausgabe von randomwriter.sh, nur Map-Phase
# (reiner Lesetest) → /lasttest/sort/out
[ "$#" -eq 0 ] && set -- \
  -D mapreduce.job.reduces=0 \
  /lasttest/randomwriter/out /lasttest/sort/out

run "sort → $*" \
  hadoop jar "$EXAMPLES_JAR" sort "$@"
