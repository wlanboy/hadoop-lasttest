#!/usr/bin/env bash
# =============================================================================
# TestDFSIO (org.apache.hadoop.fs.TestDFSIO)
# =============================================================================
# Beschreibung:
#   Klassischer, direkt vergleichbarer verteilter I/O-Benchmark (Lese-/
#   Schreibdurchsatz) über einen MapReduce-Job. In Hadoop 3.4.2 weiterhin
#   vorhanden (entgegen älterer Annahmen, siehe hadooptest.md). Ergebnisse
#   landen zusätzlich in TestDFSIO_results.log im aktuellen Verzeichnis.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar TestDFSIO \
#     -read [-random|-backward|-skip [-skipSize Size]] | -write | -append | -truncate | -clean \
#     [-compression codecClassName] [-nrFiles N] [-size Size[B|KB|MB|GB|TB]] \
#     [-resFile resultFileName] [-bufferSize Bytes] \
#     [-storagePolicy storagePolicyName] [-erasureCodePolicy erasureCodePolicyName]
#
# Parameter:
#   -write/-read/-append/-truncate/-clean  Betriebsmodus (Pflicht, genau einer)
#   -nrFiles N        Anzahl paralleler Dateien (= Parallelität)
#   -size Size[Einheit]  Größe je Datei, z. B. 128MB
#   -resFile <pfad>   Lokale Ergebnisdatei
#   -bufferSize       Puffergröße für I/O
#   -compression      Codec-Klasse für komprimierte Dateien
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: schreibt 4 Dateien à 128 MB. Danach manuell mit "-read" bzw. "-clean" aufrufen.
[ "$#" -eq 0 ] && set -- -write -nrFiles 4 -size 128MB

run "TestDFSIO → $*" \
  hadoop jar "$TESTS_JAR" TestDFSIO "$@"
