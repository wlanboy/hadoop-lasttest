#!/usr/bin/env bash
# =============================================================================
# workstation-filesize-report.sh – Dateigroessen-Report aus fsimage-XML
# =============================================================================
# WO AUSFUEHREN: auf der Workstation, NACHDEM fsimage.xml per scp vom Server
# kopiert wurde (siehe server-fsimage-export.sh und analyse.md). Braucht
# keine hdfs-CLI und keine Cluster-Verbindung, nur python3 und die lokale
# XML-Datei.
#
# Beschreibung:
#   Streaming-Auswertung (iterparse, kein voller Baum im Speicher) der
#   Dateigroessen pro Datei-Inode: Anzahl Dateien, Gesamtgroesse, Maximum,
#   Durchschnitt (alle Dateien / nur Dateien mit Groesse > 0) sowie die
#   Top-N groessten Dateien inkl. rekonstruiertem Pfad.
#
# Aufruf:
#   ./workstation-filesize-report.sh <pfad-zu-fsimage.xml> [top_n]
#
# Parameter:
#   pfad-zu-fsimage.xml   Lokale Kopie der vom Server exportierten XML-Datei
#   top_n                 Anzahl der im Report aufgelisteten Top-Dateien
#                          (Default: 20)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML_PATH="${1:?Nutzung: $0 <pfad-zu-fsimage.xml> [top_n]}"
TOP_N="${2:-20}"

command -v python3 >/dev/null 2>&1 || { echo "FEHLER: python3 wird benoetigt." >&2; exit 1; }
[ -f "$XML_PATH" ] || { echo "FEHLER: $XML_PATH nicht gefunden." >&2; exit 1; }

python3 "$SCRIPT_DIR/filesize_report.py" "$XML_PATH" --top "$TOP_N"
