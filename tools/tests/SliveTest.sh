#!/usr/bin/env bash
# =============================================================================
# SliveTest (org.apache.hadoop.fs.slive.SliveTest)
# =============================================================================
# Beschreibung:
#   HDFS-Stresstest, der zufällige Dateioperationen (Erstellen, Lesen,
#   Anhängen, Umbenennen, Löschen) per MapReduce ausführt und die Ergebnisse
#   live verifiziert. Keine feste Usage-Zeile im Quellcode – die Optionen
#   werden über Apache-Commons-CLI generiert (`-help` zeigt sie vollständig an).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar SliveTest [Optionen]
#
# Wichtigste Parameter (siehe -help für alle):
#   -maps <n>            Anzahl Map-Tasks
#   -reduces <n>          Anzahl Reduce-Tasks
#   -ops <opname:prob>*   Operationen mit relativer Gewichtung (z. B. create:10,read:5,delete:2)
#   -duration <min>       Laufzeit pro Map in Minuten
#   -files <n>            Max. Anzahl gleichzeitig verwalteter Dateien
#   -dirSize <n>           Max. Dateien je Verzeichnis
#   -baseDir <pfad>        HDFS-Basisverzeichnis
#   -resultFile <pfad>     Lokale Ergebnisdatei
#   -blockSize/-readSize/-writeSize/-appendSize  Größenparameter in Bytes
#   -replication <n>       Replikationsfaktor
#   -seed <n>              Zufallsseed
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: kleiner Testlauf, 4 Maps, 1 Reduce, 1 Minute Dauer → /lasttest/slive
[ "$#" -eq 0 ] && set -- \
  -maps 4 -reduces 1 -duration 1 -baseDir /lasttest/slive

run "SliveTest → $*" \
  hadoop jar "$TESTS_JAR" SliveTest "$@"
