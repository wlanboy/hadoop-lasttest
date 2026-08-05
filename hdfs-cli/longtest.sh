#!/usr/bin/env bash
set -euo pipefail

DURATION=1800  # 30 Minuten in Sekunden
DIRS=10
FILES=10
PARALLEL=10

cleanup() {
  echo "Räume /longtest auf..."
  hdfs dfs -rm -r -f /longtest 2>/dev/null || true
  echo "Aufgeräumt."
}

# Vor dem Start und bei Abbruch aufräumen
cleanup
trap 'echo "Abgebrochen."; cleanup; exit 0' INT TERM

END=$(( $(date +%s) + DURATION ))
ROUND=0

echo "Longtest gestartet – läuft bis $(date -d "@$END" '+%H:%M:%S')"

while [ "$(date +%s)" -lt "$END" ]; do
  ROUND=$(( ROUND + 1 ))
  TOTAL=$(( DIRS * FILES ))
  echo "=== Runde $ROUND (verbleibend: $(( END - $(date +%s) ))s) ==="

  # Verzeichnisse anlegen
  for d in $(seq 1 $DIRS); do
    hdfs dfs -mkdir -p /longtest/dir${d} 2>/dev/null || true
  done

  # Dateien parallel schreiben
  for d in $(seq 1 $DIRS); do
    for f in $(seq 1 $FILES); do
      echo "$d $f"
    done
  done | xargs -n 2 -P "$PARALLEL" bash -c '
    d=$1; f=$2
    echo "Longtest round '"$ROUND"' dir=$d file=$f" \
      | hdfs dfs -put -f - /longtest/dir${d}/file_${d}_${f}.txt 2>/dev/null
    echo "  [Runde '"$ROUND"'] Schreibe /longtest/dir${d}/file_${d}_${f}.txt"
  ' _

  echo "  $TOTAL/$TOTAL Dateien geschrieben."

  # Dateien parallel löschen
  for d in $(seq 1 $DIRS); do
    for f in $(seq 1 $FILES); do
      echo "$d $f"
    done
  done | xargs -n 2 -P "$PARALLEL" bash -c '
    d=$1; f=$2
    hdfs dfs -rm -f /longtest/dir${d}/file_${d}_${f}.txt 2>/dev/null
    echo "  [Runde '"$ROUND"'] Lösche  /longtest/dir${d}/file_${d}_${f}.txt"
  ' _

  echo "  $TOTAL/$TOTAL Dateien gelöscht."
done

cleanup
echo "Longtest beendet nach $ROUND Runden."
