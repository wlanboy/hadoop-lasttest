#!/usr/bin/env bash
# =============================================================================
# JHLogAnalyzer (org.apache.hadoop.fs.JHLogAnalyzer)
# =============================================================================
# Beschreibung:
#   Wertet Job-History-Logdateien aus und erstellt Statistiken über
#   abgeschlossene Jobs (Laufzeiten, Nutzer, Task-Zahlen). Kein Lasttest im
#   eigentlichen Sinne, sondern Auswertungswerkzeug für vorhandene Logs.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar JHLogAnalyzer \
#     [-historyDir inputDir] | [-resFile resultFile] | \
#     [-usersIncluded|-usersExcluded userList] | [-gzip] | \
#     [-jobDelimiter pattern] | [-help|-clean|-test testFile]
#
# Parameter:
#   -historyDir <dir>   HDFS-Verzeichnis mit Job-History-Logs (Pflicht für Auswertung)
#   -resFile <pfad>     Lokale Ergebnisdatei
#   -usersIncluded/-usersExcluded <liste>  Nutzerfilter
#   -gzip               Logs sind gzip-komprimiert
#   -jobDelimiter <regex>  Trennmuster zwischen Jobs im Log
#   -clean              Räumt Zwischenergebnisse auf
#   -test <datei>       Testet den Parser gegen eine einzelne Datei
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 -historyDir <hdfs-pfad-zu-job-history-logs> [weitere Optionen]" >&2
  echo "Siehe Kopfkommentar dieses Skripts für Details." >&2
  exit 1
fi

run "JHLogAnalyzer → $*" \
  hadoop jar "$TESTS_JAR" JHLogAnalyzer "$@"
