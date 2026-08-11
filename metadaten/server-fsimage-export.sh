#!/usr/bin/env bash
# =============================================================================
# server-fsimage-export.sh – fsimage laden & als XML exportieren
# =============================================================================
# WO AUSFUEHREN: bevorzugt auf einem Edge-/Gateway-Node mit funktionierender
# hdfs-CLI und gueltigem HADOOP_CONF_DIR – NICHT auf der Workstation.
# Die eigentliche Auswertung laeuft danach lokal auf der Workstation
# (workstation-xattr-report.sh), siehe analyse.md.
#
# Risiko fuer den NameNode:
#   - fetchImage ist ein reiner Read ueber den HTTP(S)-Port (derselbe Weg,
#     den Standby-/Secondary-NameNode fuers Checkpointing laufend nutzen).
#     Kein FSNamesystem-Lock, kein RPC-Handler-Pool, kein saveNamespace,
#     kein NN-Stall. Kosten: Netzwerk-/Platten-I/O fuer die Uebertragung
#     (Bild kann bei vielen Millionen Dateien mehrere GB gross sein).
#   - oiv laeuft komplett offline gegen die lokale Datei und spricht den
#     NameNode ueberhaupt nicht an – aber es ist ein JVM-Prozess mit
#     spuerbarem CPU-/Heap-Bedarf. Deshalb NICHT auf dem aktiven
#     NameNode-Host selbst ausfuehren (Ressourcenkonkurrenz mit dem
#     NN-Prozess), sondern auf einem separaten Edge-/Gateway-Node.
#   - output_dir NIEMALS auf dfs.namenode.name.dir (oder ein anderes vom
#     NameNode selbst genutztes Verzeichnis) legen.
#
# Beschreibung:
#   Ermittelt effizient die xattr-Rohdaten fuer den gesamten Cluster, ohne
#   jede Datei einzeln per RPC abzufragen (das waere langsam und erzeugt
#   NN-Last proportional zur Dateianzahl). Stattdessen:
#
#     1. hdfs dfsadmin -fetchImage <dir>
#        Laedt den letzten Checkpoint des NameNode-fsimage herunter.
#        Das Bild kann bis zu einem Checkpoint-Intervall alt sein
#        (i.d.R. unkritisch fuer diese Auswertung).
#     2. hdfs oiv -p XML -i <fsimage> -o <xml>
#        Wandelt das Binaerformat lokal (auf dem Edge-Node) in XML um.
#
# Aufruf:
#   ./server-fsimage-export.sh [output_dir]
#
# Parameter (optional):
#   output_dir   Zielverzeichnis fuer fsimage + XML (Default: ./out).
#                Muss ausserhalb von dfs.namenode.name.dir liegen und
#                genug freien Platz fuer die fsimage-Groesse bieten.
#
# Voraussetzung:
#   hdfs-CLI im PATH, HADOOP_CONF_DIR zeigt auf eine gueltige
#   Cluster-Konfiguration.
#
# Ergebnis:
#   <output_dir>/fsimage.xml – wird im naechsten Schritt per scp auf die
#   Workstation kopiert (siehe analyse.md).
# =============================================================================
set -euo pipefail

OUT_DIR="${1:-./out}"
mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/fsimage_* "$OUT_DIR/fsimage.xml"

echo "== fsimage vom NameNode laden (fetchImage) =="
hdfs dfsadmin -fetchImage "$OUT_DIR"

FSIMAGE="$(ls -t "$OUT_DIR"/fsimage_* 2>/dev/null | head -1)"
if [ -z "$FSIMAGE" ]; then
  echo "FEHLER: fsimage konnte nicht unter $OUT_DIR gefunden werden." >&2
  exit 1
fi
echo "fsimage: $FSIMAGE"

echo "== fsimage -> XML konvertieren (oiv) =="
hdfs oiv -p XML -i "$FSIMAGE" -o "$OUT_DIR/fsimage.xml"

echo ""
echo "Fertig. XML liegt unter: $OUT_DIR/fsimage.xml"
echo "Naechster Schritt: XML per scp auf die Workstation kopieren (siehe analyse.md)."
