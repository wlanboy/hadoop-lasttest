#!/usr/bin/env bash
# =============================================================================
# MRReliabilityTest (org.apache.hadoop.mapred.ReliabilityTest)
# =============================================================================
# Beschreibung:
#   Testet die Ausfallsicherheit des MapReduce-Frameworks, indem gezielt
#   Prozesse (TaskTracker/NodeManager) auf den Cluster-Hosts neugestartet
#   und Tasks abgebrochen werden. Läuft NUR im verteilten Modus (nicht mit
#   LocalJobRunner) und benötigt passwortloses SSH von diesem Host zu allen
#   Cluster-Knoten. In diesem Docker-Compose-Setup i. d. R. nicht ohne
#   weitere SSH-Einrichtung lauffähig.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-client-jobclient-3.4.2-tests.jar MRReliabilityTest \
#     -libjars <pfad zu hadoop-mapreduce-examples-3.4.2.jar> [-scratchdir <dir>]
#
# Parameter:
#   -libjars <pfad>   Pfad zur examples-Jar (wird für die Testjobs benötigt)
#   -scratchdir <dir> Scratch-Verzeichnis auf diesem Host für Steuerdateien
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

[ "$#" -eq 0 ] && set -- -libjars "$EXAMPLES_JAR" -scratchdir /tmp/lasttest-mrreliability

run "MRReliabilityTest → $*" \
  hadoop jar "$TESTS_JAR" MRReliabilityTest "$@"
