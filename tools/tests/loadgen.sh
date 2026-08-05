#!/usr/bin/env bash
# =============================================================================
# loadgen (org.apache.hadoop.mapred.GenericMRLoadGenerator)
# =============================================================================
# Beschreibung:
#   Generischer, konfigurierbarer Lastgenerator zur Erzeugung synthetischer
#   Cluster-Last mit einstellbarem Verhältnis von Map- zu Reduce-Ausgaben.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar loadgen \
#     [-m <maps>] [-r <reduces>] [-keepmap <percent>] [-keepred <percent>] \
#     [-indir <path>] [-outdir <path>] \
#     [-inFormat[Indirect] <InputFormat>] [-outFormat <OutputFormat>] \
#     [-outKey <WritableComparable>] [-outValue <Writable>]
#
# Parameter:
#   -m/-r <n>          Anzahl Map-/Reduce-Tasks
#   -keepmap <pct>     Anteil der Map-Ausgaben, der weitergereicht wird
#   -keepred <pct>     Anteil der Reduce-Ausgaben, der geschrieben wird
#   -indir/-outdir     Ein-/Ausgabeverzeichnis
#   -inFormat/-outFormat/-outKey/-outValue  Alternative Format-/Typklassen
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 4 Maps, 2 Reduces auf /lasttest/randomwriter/out → /lasttest/loadgen/out
[ "$#" -eq 0 ] && set -- \
  -m 4 -r 2 -keepmap 50 -keepred 50 \
  -indir /lasttest/randomwriter/out -outdir /lasttest/loadgen/out

run "loadgen → $*" \
  hadoop jar "$TESTS_JAR" loadgen "$@"
