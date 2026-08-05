#!/usr/bin/env bash
set -euo pipefail

HADOOP_VERSION="${HADOOP_VERSION:-3.4.2}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${SCRIPT_DIR}/downloads"
mkdir -p "${DEST_DIR}"

echo "Downloading Hadoop ${HADOOP_VERSION} ..."
curl -fSL "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    -o "${DEST_DIR}/hadoop-${HADOOP_VERSION}.tar.gz"

echo "Extracting Hadoop ${HADOOP_VERSION} ..."
tar -xzf "${DEST_DIR}/hadoop-${HADOOP_VERSION}.tar.gz" -C "${DEST_DIR}"

echo "Done. Files in ${DEST_DIR}:"
ls -lh "${DEST_DIR}"
