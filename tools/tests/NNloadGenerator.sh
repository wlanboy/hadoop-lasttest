#!/usr/bin/env bash
# =============================================================================
# NNloadGenerator (org.apache.hadoop.fs.loadGenerator.LoadGenerator)
# =============================================================================
# Beschreibung:
#   Erzeugt synthetische Lese-/Schreiblast direkt gegen den NameNode (RPC-
#   lokal auf diesem Client-Host, kein MapReduce). Dritte Stufe der
#   NN-Last-Kette – setzt Daten aus NNdataGenerator.sh voraus.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar NNloadGenerator \
#     -readProbability <p> -writeProbability <p> -root <root> \
#     -maxDelayBetweenOps <ms> -numOfThreads <n> -elapsedTime <sek> \
#     -startTime <ms> -scriptFile <datei> -flagFile <datei>
#
# Parameter:
#   -readProbability/-writeProbability  Wahrscheinlichkeit je Operation (0.0-1.0)
#   -root <pfad>            HDFS-Wurzelverzeichnis (aus NNdataGenerator.sh)
#   -maxDelayBetweenOps     Max. Pause zwischen Operationen in ms
#   -numOfThreads           Anzahl paralleler Client-Threads
#   -elapsedTime            Laufzeit in Sekunden
#   -startTime              Startzeitpunkt in ms seit Epoch (Synchronisation mehrerer Clients)
#   -scriptFile/-flagFile   Optional: Steuerdateien für Lastprofil bzw. vorzeitigen Abbruch
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

# Ohne Argumente: 2 Minuten Last, 4 Threads, 50/50 Lese-/Schreibwahrscheinlichkeit
[ "$#" -eq 0 ] && set -- \
  -readProbability 0.5 -writeProbability 0.5 -root /lasttest/nnload \
  -maxDelayBetweenOps 100 -numOfThreads 4 -elapsedTime 120

run "NNloadGenerator → $*" \
  hadoop jar "$TESTS_JAR" NNloadGenerator "$@"
