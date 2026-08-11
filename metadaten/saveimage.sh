export JAVA_HOME="$HOME/.sdkman/candidates/java/21.0.11-tem"
export HADOOP_HOME="$PWD/downloads/hadoop-3.4.2"
export HADOOP_CONF_DIR="$PWD/config"
export PATH="$JAVA_HOME/bin:$HADOOP_HOME/bin:$PATH"
hdfs dfsadmin -safemode enter
hdfs dfsadmin -saveNamespace
hdfs dfsadmin -safemode leave
