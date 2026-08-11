#!/usr/bin/env bash
# =============================================================================
# testdaten.sh – Testdateien mit zufaelliger Anzahl xattrs anlegen
# =============================================================================
# WOZU: Erzeugt Testdaten auf dem HDFS-Cluster, um xattr_report.py /
# workstation-xattr-report.sh gegen echte Daten zu pruefen (Top-N, Durchschnitt,
# Maximum etc.), ohne auf einen produktiven Datenbestand mit xattrs warten zu
# muessen.
#
# WO AUSFUEHREN: Host mit `hdfs`-CLI im PATH + gueltigem HADOOP_CONF_DIR
# (z.B. dieses Repo lokal gegen den Docker-Compose-Cluster, siehe
# analyse.md, Abschnitt "Alternative: lokal gegen den Docker-Compose-Cluster").
#
# Beschreibung:
#   Legt FILE_COUNT (Default 10) leere Dateien unter TEST_DIR an und setzt
#   an jeder Datei eine zufaellige Anzahl xattrs zwischen MIN_XATTRS und
#   MAX_XATTRS (Default 1..100).
#
#   ACHTUNG: HDFS begrenzt xattrs pro Inode standardmaessig auf 32
#   (dfs.namenode.fs-limits.max-xattrs-per-inode, siehe hdfs-default.xml).
#   setfattr-Aufrufe jenseits dieser Grenze schlagen serverseitig fehl und
#   werden hier je Datei abgebrochen (mit Warnung) statt das ganze Skript
#   abzubrechen -- Report-Tests bleiben so trotzdem moeglich, auch wenn
#   MAX_XATTRS > 32 gesetzt ist. Fuer echte Werte > 32 muesste
#   dfs.namenode.fs-limits.max-xattrs-per-inode serverseitig erhoeht werden
#   (hdfs-site.xml im hadoop-Repo, nicht Teil dieses Skripts).
#
# Aufruf:
#   ./testdaten.sh [test_dir] [anzahl_dateien] [min_xattrs] [max_xattrs]
#
# Beispiel:
#   ./metadaten/testdaten.sh /xattr-testdaten 10 1 32
# =============================================================================
set -euo pipefail

TEST_DIR="${1:-/xattr-testdaten}"
FILE_COUNT="${2:-10}"
MIN_XATTRS="${3:-1}"
MAX_XATTRS="${4:-100}"

command -v hdfs >/dev/null 2>&1 || { echo "FEHLER: hdfs-CLI nicht im PATH. HADOOP_HOME/bin exportieren (siehe analyse.md)." >&2; exit 1; }

echo "== Aufraeumen: $TEST_DIR =="
hdfs dfs -rm -r -f "$TEST_DIR" >/dev/null 2>&1 || true
hdfs dfs -mkdir -p "$TEST_DIR"

echo "== Lege $FILE_COUNT Dateien mit $MIN_XATTRS..$MAX_XATTRS xattrs an =="
for i in $(seq 1 "$FILE_COUNT"); do
  FILE="$TEST_DIR/datei_${i}.dat"
  COUNT=$(( RANDOM % (MAX_XATTRS - MIN_XATTRS + 1) + MIN_XATTRS ))

  echo "testdaten $i" | hdfs dfs -put -f - "$FILE"

  gesetzt=0
  for a in $(seq 1 "$COUNT"); do
    if hdfs dfs -setfattr -n "user.attr${a}" -v "wert${a}" "$FILE" 2>/dev/null; then
      gesetzt=$((gesetzt + 1))
    else
      echo "  WARNUNG: setfattr user.attr${a} auf $FILE fehlgeschlagen (Cluster-Limit erreicht?) - Rest uebersprungen" >&2
      break
    fi
  done

  echo "  $FILE: $gesetzt/$COUNT xattrs gesetzt"
done

echo ""
echo "Fertig. $FILE_COUNT Dateien unter $TEST_DIR angelegt."
echo "Naechster Schritt: fsimage exportieren (server-fsimage-export.sh) und mit"
echo "workstation-xattr-report.sh bzw. workstation-filesize-report.sh auswerten."
