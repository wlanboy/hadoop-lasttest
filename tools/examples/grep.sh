#!/usr/bin/env bash
# =============================================================================
# grep (org.apache.hadoop.examples.Grep)
# =============================================================================
# Beschreibung:
#   Zählt Regex-Treffer in Eingabedateien (zweistufiger Job: Map zählt
#   Treffer je Zeile, Reduce summiert und sortiert nach Häufigkeit).
#   Benötigt Texteingabe, z. B. aus randomtextwriter.sh.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar grep <in> <out> <regex> [<group>]
#
# Parameter:
#   <in>      Eingabeverzeichnis
#   <out>     Ausgabeverzeichnis
#   <regex>   Regulärer Ausdruck, nach dem gesucht wird
#   <group>   Optional: welche Capture-Gruppe des Regex gezählt wird (Default: 0 = ganzer Treffer)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: sucht "the" in /lasttest/randomtextwriter/out → /lasttest/grep/out
[ "$#" -eq 0 ] && set -- \
  /lasttest/randomtextwriter/out /lasttest/grep/out 'the'

run "grep → $*" \
  hadoop jar "$EXAMPLES_JAR" grep "$@"
