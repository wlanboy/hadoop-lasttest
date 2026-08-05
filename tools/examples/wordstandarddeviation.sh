#!/usr/bin/env bash
# =============================================================================
# wordstandarddeviation (org.apache.hadoop.examples.WordStandardDeviation)
# =============================================================================
# Beschreibung:
#   Berechnet die Standardabweichung der Wortlängen über die Texteingaben.
#   Benötigt Texteingabe, z. B. aus randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar wordstandarddeviation <in> <out>
#
# Parameter:
#   <in>   Eingabeverzeichnis (Textdateien)
#   <out>  Ausgabeverzeichnis
#
# Hinweis: Der intern gedruckte Usage-Text lautet "wordstddev <in> <out>"
# (Diskrepanz zum ExampleDriver-Namen), gemeint ist aber derselbe Job.
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: /lasttest/randomtextwriter/out → /lasttest/wordstandarddeviation/out
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/wordstandarddeviation/out

run "wordstandarddeviation → $*" \
  hadoop jar "$EXAMPLES_JAR" wordstandarddeviation "$@"
