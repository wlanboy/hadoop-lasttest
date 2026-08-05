#!/usr/bin/env bash
# =============================================================================
# join (org.apache.hadoop.examples.Join)
# =============================================================================
# Beschreibung:
#   Führt einen Join über mehrere sortierte, gleich partitionierte
#   Datensätze aus (map-seitiger Join). Die Eingaben müssen bereits durch
#   denselben Partitioner mit derselben Anzahl Partitionen sortiert vorliegen
#   (z. B. Ausgabe von sort.sh mit identischer Reducer-Zahl je Quelle).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar join [-r <reduces>] \
#     [-inFormat <input format class>] [-outFormat <output format class>] \
#     [-outKey <output key class>] [-outValue <output value class>] \
#     [-joinOp <inner|outer|override>] <input>... <output>
#
# Parameter:
#   -r <n>        Anzahl Reduce-Tasks
#   -inFormat/-outFormat  Alternative Input-/OutputFormat-Klasse
#   -outKey/-outValue     Alternative Key-/Value-Klasse
#   -joinOp       Join-Typ: inner, outer oder override
#   <input>...    Zwei oder mehr gleich partitionierte, sortierte Eingaben
#   <output>      Zielverzeichnis
#
# Hinweis: kein sinnvoller generischer Default möglich, da passend
# partitionierte Eingaben vorausgesetzt werden – eigene Pfade übergeben:
#   ./join.sh -joinOp inner /lasttest/sort/a /lasttest/sort/b /lasttest/join/out
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [-r <reduces>] [-joinOp inner|outer|override] <input>... <output>" >&2
  echo "Siehe Kopfkommentar dieses Skripts für Details." >&2
  exit 1
fi

run "join → $*" \
  hadoop jar "$EXAMPLES_JAR" join "$@"
