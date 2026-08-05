#!/usr/bin/env bash
# =============================================================================
# pi (org.apache.hadoop.examples.QuasiMonteCarlo)
# =============================================================================
# Beschreibung:
#   Schätzt Pi via Quasi-Monte-Carlo-Methode. Reiner CPU-/Shuffle-Benchmark
#   ohne nennenswerte HDFS-I/O (nur winzige Zwischenergebnisse).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar pi <nMaps> <nSamples>
#
# Parameter (Positionsargumente):
#   nMaps      Anzahl paralleler Map-Tasks
#   nSamples   Anzahl Samples je Map-Task (Genauigkeit steigt mit nSamples)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: Default 4 Maps × 1.000.000 Samples.
# Eigene Werte: ./pi.sh <nMaps> <nSamples>
[ "$#" -eq 0 ] && set -- 4 1000000

run "pi: $1 Maps, $2 Samples je Map" \
  hadoop jar "$EXAMPLES_JAR" pi "$@"
