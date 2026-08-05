#!/usr/bin/env bash
# =============================================================================
# dbcount (org.apache.hadoop.examples.DBCountPageView)
# =============================================================================
# Beschreibung:
#   Selbstständiges Demo für DBInputFormat/DBOutputFormat: startet intern
#   eine eingebettete HSQLDB, erzeugt Testdaten (Access-Logs), zählt Page-
#   views pro URL per MapReduce und schreibt das Ergebnis zurück in die
#   Datenbank. Kein HDFS-Ein-/Ausgabepfad nötig.
#
# Aufruf:
#   hadoop jar hadoop-mapreduce-examples-3.4.2.jar dbcount [driverClass dburl]
#
# Parameter (beide optional):
#   driverClass  JDBC-Treiberklasse (Default: eingebettete HSQLDB)
#   dburl        JDBC-URL (Default: eingebettete HSQLDB)
#
# Hinweis: Kein offizieller Usage-Text; bei <2 Argumenten werden die
# HSQLDB-Defaults verwendet. Erfordert, dass die HSQLDB-Jar im Classpath des
# Jobs verfügbar ist (im Hadoop-Release i. d. R. nicht mitgeliefert – ggf.
# mit -libjars ergänzen).
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

run "dbcount${*:+ → $*}" \
  hadoop jar "$EXAMPLES_JAR" dbcount "$@"
