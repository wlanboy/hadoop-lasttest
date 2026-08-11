# xattr-Analyse: Anleitung

Ermittelt, wie viele Extended Attributes (xattrs, gesetzt via
`hdfs dfs -setfattr`) maximal bzw. durchschnittlich an einer Datei im
Cluster haengen – ohne jede Datei einzeln per RPC abzufragen.

Analog dazu gibt es einen Dateigroessen-Report (Maximum, Durchschnitt,
Top-N groesste Dateien), siehe Schritt 3b.

Der Ablauf ist zweigeteilt:

| Schritt | Wo | Skript |
|---|---|---|
| 1. fsimage laden + nach XML konvertieren | **Edge-/Gateway-Node** (nicht der NameNode-Host) | `server-fsimage-export.sh` |
| 2. XML kopieren | Edge-Node → Workstation | `scp` |
| 3. xattrs auswerten | **Workstation** | `workstation-xattr-report.sh` |
| 3b. Dateigroessen auswerten | **Workstation** | `workstation-filesize-report.sh` |

Der Edge-Node braucht dafuer nur die `hdfs`-CLI (ohnehin vorhanden). Die
Workstation braucht nur `python3` – keine Hadoop-Installation, keine
Cluster-Verbindung, keine NN-Last durch die Auswertung selbst.

---

- `hdfs dfsadmin -fetchImage` ist ein reiner Read über den HTTP(S)-Port
  des NameNode – derselbe Weg, den Standby-/Secondary-NameNode ohnehin
  laufend fürs Checkpointing nutzen. Kein `saveNamespace`, kein
  FSNamesystem-Lock, kein NN-Stall, blockiert keine Client-Requests.
  Reale Kosten: Netzwerk-/Platten-I/O für die Übertragung (das Bild kann
  bei vielen Millionen Dateien mehrere GB groß sein).
- `hdfs oiv -p XML` läuft komplett offline gegen die lokale Datei und
  spricht den NameNode gar nicht an. Es ist aber ein JVM-Prozess mit
  spürbarem CPU-/Heap-Bedarf – deshalb **nicht auf dem aktiven
  NameNode-Host selbst ausführen**, sondern auf einem separaten
  Edge-/Gateway-Node (Ressourcenkonkurrenz mit dem NN-Prozess ist der
  einzige indirekte Risikopunkt in diesem gesamten Ablauf).
- Zielverzeichnis niemals auf `dfs.namenode.name.dir` legen (Platzbedarf,
  keine Vermischung mit den eigenen NN-Metadaten).

## Voraussetzungen

- **Edge-/Gateway-Node** (nicht der aktive NameNode-Host): `hdfs`-CLI im
  `PATH`, `HADOOP_CONF_DIR` zeigt auf eine gueltige
  Cluster-Konfiguration. SSH-Zugriff fuer den nachfolgenden `scp`.
- **Workstation**: `python3` (Standardbibliothek genuegt, keine externen
  Pakete), dieses Repo ausgecheckt (fuer `xattr_report.py`).

---

## Schritt 1: Auf dem Edge-Node – fsimage exportieren

Auf einem Edge-/Gateway-Node (**nicht** dem aktiven NameNode-Host, siehe
oben) einloggen und dieses Repo-Verzeichnis (oder zumindest
`metadaten/server-fsimage-export.sh`) dorthin kopiert haben, dann:

```bash
ssh user@edge-host
cd /pfad/zu/hadoop-lasttest/metadaten
./server-fsimage-export.sh /tmp/xattr-export
```

Alternative: lokal gegen den Docker-Compose-Cluster (kein separater
Edge-Node, `hdfs`-CLI aus `downloads/hadoop-3.4.2` + `config/` aus diesem
Repo, siehe [Setup](../readme.md#setup)). Java 25 (Systemstandard) scheitert
bei Hadoop 3.4.2 mit `getSubject is not supported` (JDK 25 hat
`Subject.getSubject` entfernt) – daher `JAVA_HOME` auf Java ≤21 setzen:

```bash
cd /pfad/zu/hadoop-lasttest
export JAVA_HOME="$HOME/.sdkman/candidates/java/21.0.11-tem"
export HADOOP_HOME="$PWD/downloads/hadoop-3.4.2"
export HADOOP_CONF_DIR="$PWD/config"
export PATH="$JAVA_HOME/bin:$HADOOP_HOME/bin:$PATH"
./metadaten/server-fsimage-export.sh
```

Ausgabe (gekuerzt):

```
== fsimage vom NameNode laden (fetchImage) ==
...
== fsimage -> XML konvertieren (oiv) ==
...
Fertig. XML liegt unter: /tmp/xattr-export/fsimage.xml
```

`hdfs dfsadmin -fetchImage` laedt nur den letzten Checkpoint (kein
`saveNamespace`, kein NN-Stall) – das Bild kann daher bis zu einem
Checkpoint-Intervall alt sein. Fuer diese Auswertung ist das unkritisch.

---

## Schritt 2: XML auf die Workstation kopieren (scp)

Von der Workstation aus:

```bash
scp user@edge-host:/tmp/xattr-export/fsimage.xml ./fsimage.xml
```

Bei einer Bastion/einem Jump-Host dazwischen:

```bash
scp -o ProxyJump=user@bastion-host user@edge-host:/tmp/xattr-export/fsimage.xml ./fsimage.xml
```

Danach auf dem Edge-Node aufraeumen (fsimage.xml kann je nach
Clustergroesse gross sein):

```bash
ssh user@edge-host rm -rf /tmp/xattr-export
```

---

## Schritt 3: Auf der Workstation – Report erzeugen

```bash
cd /pfad/zu/hadoop-lasttest/metadaten
./metadaten/workstation-xattr-report.sh ./out/fsimage.xml        # Top 20 (Default)
./metadaten/workstation-xattr-report.sh ./fsimage.xml 50     # Top 50
```

Beispielausgabe:

```
======================================================================
  xattr-Report (aus fsimage)
======================================================================
Dateien insgesamt:               1234567
Dateien mit >=1 xattr:            4211 (0.34%)
xattrs insgesamt:                 9876
Durchschnitt xattrs/Datei (alle):        0.0080
Durchschnitt xattrs/Datei (nur mit xattr): 2.3450
Maximum xattrs auf einer einzelnen Datei: 17

Top 20 Dateien nach xattr-Anzahl:
      17  /projekt/foo/bar.avro
      12  /projekt/foo/baz.avro
       ...
======================================================================
```

## Schritt 3b: Auf der Workstation – Dateigroessen-Report erzeugen

Nutzt dieselbe `fsimage.xml` wie Schritt 3, keine erneute Uebertragung
noetig:

```bash
cd /pfad/zu/hadoop-lasttest/metadaten
./workstation-filesize-report.sh ./fsimage.xml        # Top 20 (Default)
./workstation-filesize-report.sh ./fsimage.xml 50     # Top 50
```

Beispielausgabe:

```
======================================================================
  Dateigroessen-Report (aus fsimage)
======================================================================
Dateien insgesamt:                1234567
Dateien mit Groesse > 0:          1230000
Gesamtgroesse (logisch):          12.34 TB (13564000000000 Bytes)
Durchschnitt Groesse/Datei (alle):        10.00 MB
Durchschnitt Groesse/Datei (nur > 0):      10.03 MB
Maximum Groesse einer einzelnen Datei:    4.20 GB

Top 20 Dateien nach Groesse:
       4.20 GB  /projekt/foo/big.avro
       3.10 GB  /projekt/foo/other.avro
       ...
======================================================================
```

Die Groesse ist die logische Dateigroesse (Summe der Block-`numBytes`),
**ohne** Replikationsfaktor – der tatsaechliche HDFS-Speicherverbrauch
liegt bei Standard-Replikation entsprechend hoeher.

## Hinweise

- Fuer die Top-N-Pfadrekonstruktion baut `xattr_report.py` eine
  vollstaendige id→parent-Zuordnung aus der `INodeDirectorySection` im
  Speicher auf (Groessenordnung ~ Anzahl Inodes). Bei sehr grossen
  Clustern (>> 10 Mio. Dateien) entsprechend RAM auf der Workstation
  einplanen.
- `fsimage.xml` kann sensible Pfad-/Metadaten-Informationen enthalten –
  nicht unnoetig auf gemeinsam genutzten Systemen liegen lassen (siehe
  Aufraeum-Hinweis in Schritt 2).
