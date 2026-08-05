#!/usr/bin/env bash
# =============================================================================
# pentomino (org.apache.hadoop.examples.dancing.DistributedPentomino)
# =============================================================================
# Beschreibung:
#   Löst das Pentomino-Legespiel verteilt mittels MapReduce (Dancing-Links-
#   Algorithmus). Reine CPU-Last, kein nennenswertes HDFS-I/O. Laufzeit
#   wächst kombinatorisch mit Breite/Höhe – vorsichtig erhöhen.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar pentomino <output> [-depth #] [-height #] [-width #]
#
# Parameter:
#   <output>  Ausgabeverzeichnis
#   -depth    Suchtiefe, ab der Teilprobleme an Maps verteilt werden
#   -height   Höhe des Spielfelds
#   -width    Breite des Spielfelds
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: kleines 9×6-Feld, Tiefe 2 → /lasttest/pentomino/out
[ "$#" -eq 0 ] && set -- \
  /lasttest/pentomino/out -depth 2 -height 6 -width 9

run "pentomino → $*" \
  hadoop jar "$EXAMPLES_JAR" pentomino "$@"
