#!/usr/bin/env bash
# =============================================================================
# wordcount (org.apache.hadoop.examples.WordCount)
# =============================================================================
# Beschreibung:
#   Zählt Wörter in Textdateien. Kombinierter Lese-/Shuffle-/Schreibtest auf
#   Textdaten. Benötigt Texteingabe, z. B. aus randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar wordcount [-D ...]
#     [-skip <patternfile>] <in> [<in>...] <out>
#
# Parameter (-D):
#   wordcount.case.sensitive=<true|false>  Groß-/Kleinschreibung beachten (Default: true)
#   wordcount.skip.patterns=<true|false>   Muster aus -skip-Datei ignorieren
# Weitere Argumente:
#   -skip <patternfile>   Datei mit Regex-Mustern, die ignoriert werden
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: zählt Wörter in /lasttest/randomtextwriter/out → /lasttest/wordcount/out
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/wordcount/out

run "wordcount → $*" \
  hadoop jar "$EXAMPLES_JAR" wordcount "$@"
