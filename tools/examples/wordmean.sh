#!/usr/bin/env bash
# =============================================================================
# wordmean (org.apache.hadoop.examples.WordMean)
# =============================================================================
# Beschreibung:
#   Berechnet die mittlere Wortlänge über alle Wörter der Eingabe. Nutzt
#   intern denselben Map/Reduce-Ablauf wie wordcount, aggregiert zusätzlich
#   Summen für den Mittelwert. Benötigt Texteingabe, z. B. aus
#   randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar wordmean <in> <out>
#
# Parameter:
#   <in>   Eingabeverzeichnis (Textdateien)
#   <out>  Ausgabeverzeichnis (enthält das Ergebnis als einzelnen Zahlenwert)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: /lasttest/randomtextwriter/out → /lasttest/wordmean/out
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/wordmean/out

run "wordmean → $*" \
  hadoop jar "$EXAMPLES_JAR" wordmean "$@"
