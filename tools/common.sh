#!/usr/bin/env bash
# =============================================================================
# Gemeinsame Konfiguration für lasttest/**/*.sh
#
# Nutzt die lokal unter downloads/hadoop-3.4.2 liegende Hadoop-Distribution
# (siehe download.sh) direkt – KEIN docker exec. Die Skripte sprechen den
# Cluster über die in HADOOP_CONF_DIR hinterlegte Konfiguration an
# (fs.defaultFS=hdfs://ns1, siehe config/core-site.xml), müssen also von
# einem Host aus laufen, der die Namenode-Hostnamen (nn1/nn2) auflösen kann.
# =============================================================================

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$COMMON_DIR/.." && pwd)"

export HADOOP_HOME="${HADOOP_HOME:-$REPO_ROOT/downloads/hadoop-3.4.2}"
# config/ = Full-Cluster-Setup (nn1/nn2 HA, siehe docker-compose.yml).
# Für configsingle/ oder configzwei/ HADOOP_CONF_DIR vor dem Aufruf exportieren.
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$REPO_ROOT/config}"
export PATH="$HADOOP_HOME/bin:$PATH"

if [ ! -x "$HADOOP_HOME/bin/hadoop" ]; then
  echo "FEHLER: $HADOOP_HOME/bin/hadoop nicht gefunden. Erst 'bash download.sh' im Repo-Root ausführen." >&2
  exit 1
fi

if [ -z "${JAVA_HOME:-}" ] && command -v java >/dev/null 2>&1; then
  export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
fi

EXAMPLES_JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.2.jar"
TESTS_JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.2-tests.jar"

# -----------------------------------------------------------------------------
# Hilfsfunktion: Ausgabe mit Zeitstempel/Überschrift, dann Befehl ausführen
# -----------------------------------------------------------------------------
run() {
  echo ""
  echo "════════════════════════════════════════════════════════════════"
  echo "  $1"
  echo "════════════════════════════════════════════════════════════════"
  shift
  "$@"
}
