#!/usr/bin/env bash
# =============================================================================
# multifilewc (org.apache.hadoop.examples.MultiFileWordCount)
# =============================================================================
# Beschreibung:
#   Zählt Wörter über mehrere Dateien hinweg, wobei jede Datei (statt jedem
#   Block) einen eigenen InputSplit bildet (CombineFileInputFormat-Demo).
#   Benötigt Texteingabe, z. B. aus randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar multifilewc <input_dir> <output>
#
# Parameter:
#   <input_dir>  Eingabeverzeichnis mit mehreren Dateien
#   <output>     Ausgabeverzeichnis
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: /lasttest/randomtextwriter/out → /lasttest/multifilewc/out
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/multifilewc/out

run "multifilewc → $*" \
  hadoop jar "$EXAMPLES_JAR" multifilewc "$@"
