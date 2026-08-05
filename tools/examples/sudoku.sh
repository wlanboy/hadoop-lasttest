#!/usr/bin/env bash
# =============================================================================
# sudoku (org.apache.hadoop.examples.dancing.Sudoku)
# =============================================================================
# Beschreibung:
#   Löst Sudoku-Rätsel aus Dateien mittels des Dancing-Links-Algorithmus.
#   Läuft rein lokal in einer JVM (kein MapReduce-Job, kein HDFS-I/O) – reine
#   CPU-Last, nur als Demo für den Algorithmus gedacht.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar sudoku <puzzle-file> [<puzzle-file> ...]
#
# Parameter:
#   <puzzle-file>  Lokale Datei mit 9 Zeilen à 9 Zeichen (Ziffern 1-9, '.' = leer)
#
# Ohne Argumente wird nur "Include a puzzle on the command line." ausgegeben.
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: legt ein Beispielrätsel lokal an und löst es
if [ "$#" -eq 0 ]; then
  TMP="$(mktemp)"
  cat > "$TMP" <<'EOF'
53..7....
6..195...
.98....6.
8...6...3
4..8.3..1
7...2...6
.6....28.
...419..5
....8..79
EOF
  set -- "$TMP"
fi

run "sudoku → $*" \
  hadoop jar "$EXAMPLES_JAR" sudoku "$@"
