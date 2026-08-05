#!/usr/bin/env bash
# =============================================================================
# testtextinputformat (org.apache.hadoop.mapred.TestTextInputFormat)
# =============================================================================
# Beschreibung:
#   Prüft das korrekte zeilenweise Einlesen von Texteingaben durch
#   TextInputFormat, auch bei komprimierten Dateien. Kein Flag-basierter
#   Usage-Text – jedes Argument wird als (ggf. komprimierte) Eingabedatei
#   behandelt und die per LineReader gelesenen Zeilen werden ausgegeben.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar testtextinputformat <datei> [<datei>...]
#
# Parameter:
#   <datei>  Eine oder mehrere lokale/HDFS-Textdateien (auch .gz möglich)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <datei> [<datei>...]" >&2
  echo "Siehe Kopfkommentar dieses Skripts für Details." >&2
  exit 1
fi

run "testtextinputformat → $*" \
  hadoop jar "$TESTS_JAR" testtextinputformat "$@"
