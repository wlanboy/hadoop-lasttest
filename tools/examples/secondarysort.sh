#!/usr/bin/env bash
# =============================================================================
# secondarysort (org.apache.hadoop.examples.SecondarySort)
# =============================================================================
# Beschreibung:
#   Demonstriert eine sekundäre Sortierung der Werte innerhalb jeder
#   Reducer-Gruppe. Erwartet Textzeilen mit zwei durch Leerzeichen
#   getrennten Ganzzahlen ("<key> <value>").
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar secondarysort <in> <out>
#
# Parameter:
#   <in>   Eingabeverzeichnis (Textzeilen "<int key> <int value>")
#   <out>  Ausgabeverzeichnis
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: legt eine kleine Beispieldatei an → /lasttest/secondarysort/out
if [ "$#" -eq 0 ]; then
  IN=/lasttest/secondarysort/in
  OUT=/lasttest/secondarysort/out
  TMP="$(mktemp)"
  printf '%s\n' "1 90" "2 100" "1 5" "3 3" "2 40" "1 20" > "$TMP"
  hadoop fs -mkdir -p "$IN"
  hadoop fs -put -f "$TMP" "$IN/sample.txt"
  rm -f "$TMP"
  set -- "$IN" "$OUT"
fi

run "secondarysort → $*" \
  hadoop jar "$EXAMPLES_JAR" secondarysort "$@"
