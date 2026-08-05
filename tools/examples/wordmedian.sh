#!/usr/bin/env bash
# =============================================================================
# wordmedian (org.apache.hadoop.examples.WordMedian)
# =============================================================================
# Beschreibung:
#   Berechnet den Median der Wortlängen über die Texteingaben. Benötigt
#   Texteingabe, z. B. aus randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar wordmedian <in> <out>
#
# Parameter:
#   <in>   Eingabeverzeichnis (Textdateien)
#   <out>  Ausgabeverzeichnis
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: /lasttest/randomtextwriter/out → /lasttest/wordmedian/out
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/wordmedian/out

run "wordmedian → $*" \
  hadoop jar "$EXAMPLES_JAR" wordmedian "$@"
