#!/usr/bin/env bash
# =============================================================================
# NNstructureGenerator (org.apache.hadoop.fs.loadGenerator.StructureGenerator)
# =============================================================================
# Beschreibung:
#   Generiert eine zufällige Verzeichnis-/Dateistruktur (nur Metadaten, keine
#   Dateiinhalte) als Vorlage für NNdataGenerator.sh. Erste Stufe der
#   NN-Last-Kette: NNstructureGenerator → NNdataGenerator → NNloadGenerator(MR).
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar NNstructureGenerator \
#     -maxDepth <maxDepth> -minWidth <minWidth> -maxWidth <maxWidth> \
#     -numOfFiles <#OfFiles> -avgFileSize <avgFileSizeInBlocks> -outDir <outDir> -seed <seed>
#
# Parameter:
#   -maxDepth      Maximale Verzeichnistiefe
#   -minWidth/-maxWidth  Min./Max. Anzahl Unterverzeichnisse je Ebene
#   -numOfFiles    Gesamtzahl zu planender Dateien
#   -avgFileSize   Mittlere Dateigröße in Blöcken
#   -outDir        Lokales Ausgabeverzeichnis für die Struktur-Beschreibung
#   -seed          Zufallsseed (optional, für Reproduzierbarkeit)
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

OUT_DIR=/tmp/lasttest-nnload/structure
[ "$#" -eq 0 ] && set -- \
  -maxDepth 3 -minWidth 2 -maxWidth 5 \
  -numOfFiles 1000 -avgFileSize 1 -outDir "$OUT_DIR" -seed 1

mkdir -p "$OUT_DIR"

run "NNstructureGenerator → $*" \
  hadoop jar "$TESTS_JAR" NNstructureGenerator "$@"
