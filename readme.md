# hadoop-lasttest

Sammlung von Skripten, um einen bestehenden Hadoop-Cluster (HDFS + YARN/MapReduce)
mit Lasttests, Benchmarks und Funktionstests zu prüfen. Die Skripte rufen dazu
die mitgelieferten Beispiel- und Test-Jars der Hadoop-Distribution auf
(`hadoop-mapreduce-examples` und `hadoop-mapreduce-client-jobclient-*-tests`).

Alle Skripte laufen **lokal auf einem Client-Host**, der den Cluster über die
Konfiguration in `HADOOP_CONF_DIR` erreicht (`fs.defaultFS`, NameNode-HA
zwischen `nn1`/`nn2` usw.) – es wird **kein** `docker exec` o.ä. mehr verwendet.

## Aufbau

- **`download.sh`** – Lädt eine Hadoop-Distribution herunter und entpackt sie
  nach `downloads/`.
  Aufruf: `bash download.sh` (optional `HADOOP_VERSION=3.4.2 bash download.sh`).
  Ergebnis: `downloads/hadoop-<version>/` mit den Binaries/Jars, die alle
  anderen Skripte nutzen.

- **`tools/common.sh`** – Wird von allen Skripten unter `tools/examples/` und
  `tools/tests/` eingebunden. Setzt `HADOOP_HOME` (Default:
  `downloads/hadoop-3.4.2`), `HADOOP_CONF_DIR` (Default: `config/` im
  Repo-Root – für Single-/Zwei-Knoten-Setups vorher exportieren, z. B.
  `HADOOP_CONF_DIR=$PWD/configsingle bash tools/examples/pi.sh`), erweitert
  `PATH` um `$HADOOP_HOME/bin` und definiert die Pfade zu den Examples- und
  Tests-Jars sowie die Hilfsfunktion `run()` für einheitliche Log-Ausgaben.
  Bricht ab, wenn `download.sh` noch nicht gelaufen ist.

- **`tools/examples/*.sh`** – Wrapper um die Jobs aus der
  `hadoop-mapreduce-examples`-Jar (Benchmarks/Demos wie WordCount, TeraSort, Pi …).

- **`tools/tests/*.sh`** – Wrapper um die Jobs/Tools aus der
  `hadoop-mapreduce-client-jobclient-*-tests`-Jar (NameNode-/HDFS-Benchmarks,
  Framework-Funktionstests, Stresstests).

- **`hdfs-cli/longtest.sh`** – Eigenständiger Dauertest direkt über die
  `hdfs`-CLI (kein Jar-Aufruf).

Jedes Skript unter `tools/` kann ohne Argumente mit sinnvollen Defaults
gestartet werden (siehe „Ohne Argumente“-Hinweis im jeweiligen Skriptkopf)
oder mit eigenen Argumenten, die 1:1 an den zugrunde liegenden `hadoop jar …`-Aufruf
durchgereicht werden.

## Setup

```bash
bash download.sh                 # Hadoop-Distribution herunterladen
# HADOOP_CONF_DIR muss auf eine gültige Cluster-Konfiguration zeigen,
# z. B. config/, configsingle/ oder configzwei/ (core-site.xml, hdfs-site.xml, …)
./tools/examples/pi.sh            # Beispielaufruf ohne Argumente
```

---

## tools/examples

| Skript | Aufruf (ohne Argumente = Default) | Was wird getestet |
|---|---|---|
| `aggregatewordcount.sh` | `/lasttest/randomtextwriter/out → /lasttest/aggregatewordcount/out`, 1 Reducer | Wortzählung über das generische Aggregate-Framework (ValueAggregatorJob) |
| `aggregatewordhist.sh` | `/lasttest/randomtextwriter/out → /lasttest/aggregatewordhist/out`, 1 Reducer | Histogramm der Worthäufigkeiten über das Aggregate-Framework |
| `bbp.sh` | 100 Hex-Ziffern ab Position 1, 4 Maps → `/lasttest/bbp/work` | Pi-Berechnung (Bailey-Borwein-Plouffe), unabhängige Maps ohne Shuffle |
| `dbcount.sh` | `[driverClass dburl]`, ohne Argumente eingebettete HSQLDB | DBInputFormat/DBOutputFormat-Demo mit eingebetteter Datenbank, kein HDFS-I/O |
| `distbbp.sh` | 1 Bit ab Start, 2 Threads, 2 Jobs, Map-seitig, 2 Teile | Verteilte Pi-Berechnung über mehrere MapReduce-Jobs/Threads |
| `grep.sh` | sucht `"the"` in `/lasttest/randomtextwriter/out` → `/lasttest/grep/out` | Regex-Treffer zählen (zweistufiger Map/Reduce-Job) |
| `join.sh` | kein Default, z. B. `./join.sh -joinOp inner /lasttest/sort/a /lasttest/sort/b /lasttest/join/out` | Map-seitiger Join über gleich partitionierte, sortierte Eingaben |
| `multifilewc.sh` | `/lasttest/randomtextwriter/out → /lasttest/multifilewc/out` | Wortzählung mit CombineFileInputFormat (ein Split pro Datei statt pro Block) |
| `pentomino.sh` | 9×6-Feld, Suchtiefe 2 → `/lasttest/pentomino/out` | Pentomino-Solver (Dancing Links), reine CPU-Last |
| `pi.sh` | 4 Maps × 1.000.000 Samples | Pi-Schätzung via Quasi-Monte-Carlo, CPU-/Shuffle-Benchmark |
| `randomtextwriter.sh` | 4 Maps à 64 MB → `/lasttest/randomtextwriter/out` | Zufälligen Text als SequenceFile schreiben (Namespace-Last, Eingabe für wordcount/grep) |
| `randomwriter.sh` | 4 Maps × 128 MB = 512 MB → `/lasttest/randomwriter/out` | Zufällige Binärdaten parallel schreiben (HDFS-Schreibdurchsatz, Ersatz für TestDFSIO -write) |
| `secondarysort.sh` | legt Beispieldaten an → `/lasttest/secondarysort/out` | Sekundäre Sortierung der Werte je Reducer-Gruppe |
| `sort.sh` | sortiert `randomwriter`-Ausgabe, nur Map-Phase → `/lasttest/sort/out` | SequenceFile-Sortierung; mit `-r 0` reiner HDFS-Lesetest (≙ TestDFSIO -read) |
| `sudoku.sh` | legt Beispielrätsel lokal an und löst es | Sudoku-Solver (Dancing Links), rein lokal, kein MapReduce/HDFS |
| `teragen.sh` | 1.000.000 Records (≈100 MB), 2 Maps → `/lasttest/teragen/out` | Erzeugt Terasort-Eingabedaten (Schreibtest, Stufe 1 von teragen→terasort→teravalidate) |
| `terasort.sh` | sortiert `/lasttest/teragen/out`, 2 Reduces → `/lasttest/terasort/out` | Gesamtcluster-Benchmark: Lese-, Netzwerk- und Schreibdurchsatz (Stufe 2) |
| `teravalidate.sh` | prüft `/lasttest/terasort/out` → `/lasttest/teravalidate/report` | Prüft Sortierkorrektheit der terasort-Ausgabe (Stufe 3) |
| `wordcount.sh` | `/lasttest/randomtextwriter/out → /lasttest/wordcount/out` | Klassische Wortzählung, kombinierter Lese-/Shuffle-/Schreibtest |
| `wordmean.sh` | `/lasttest/randomtextwriter/out → /lasttest/wordmean/out` | Mittlere Wortlänge über alle Eingabewörter |
| `wordmedian.sh` | `/lasttest/randomtextwriter/out → /lasttest/wordmedian/out` | Median der Wortlängen |
| `wordstandarddeviation.sh` | `/lasttest/randomtextwriter/out → /lasttest/wordstandarddeviation/out` | Standardabweichung der Wortlängen |

## tools/tests

| Skript | Aufruf (ohne Argumente = Default) | Was wird getestet |
|---|---|---|
| `DFSCIOTest.sh` | schreibt 4 Dateien à 64 MB | Verteilter I/O-Benchmark über libhdfs/JNI (älterer Vorläufer von TestDFSIO) |
| `DistributedFSCheck.sh` | prüft `/lasttest` | Liest verteilt alle Dateien unter einem Pfad, prüft Dateisystem-Konsistenz |
| `fail.sh` | `-failMappers` oder `-failReducers` (Pflicht) | Absichtlich fehlschlagende Tasks – testet Fehlerbehandlung/Retry-Logik des Frameworks |
| `filebench.sh` | Lesen+Schreiben, SequenceFile, unkomprimiert → `/lasttest/filebench` | Lese-/Schreibdurchsatz von SequenceFile/TextInputFormat mit verschiedenen Kompressionscodecs |
| `gsleep.sh` | kein Default, z. B. `-m 10 -r 5 -mt 3000` | Wie sleep.sh, zusätzlich wachsender Heap-Verbrauch je Datensatz (Speicherdruck-Test) |
| `JHLogAnalyzer.sh` | kein Default, `-historyDir <dir>` nötig | Wertet Job-History-Logs aus (Laufzeiten, Nutzer, Task-Zahlen) – Auswertungs-, kein Lasttool |
| `largesorter.sh` | 4 Maps à 128 MB, 2 Reduces → `/lasttest/largesorter/out` | Große Sortiervorgänge (Spill-/Merge-Verhalten bei großen Datenmengen je Map) |
| `loadgen.sh` | 4 Maps, 2 Reduces auf `/lasttest/randomwriter/out` → `/lasttest/loadgen/out` | Generischer, konfigurierbarer synthetischer Lastgenerator |
| `mapredtest.sh` | kein Default, `<range> <counts>` nötig | Einfacher End-to-End-Funktionstest/Smoke-Test des MapReduce-Frameworks |
| `mrbench.sh` | 10 Läufe kleiner Jobs → `/lasttest/mrbench` | Job-Startup-Overhead/Scheduling-Latenz (viele kleine statt weniger großer Jobs) |
| `MRReliabilityTest.sh` | kein Default | Ausfallsicherheit des Frameworks durch gezielte Prozess-Neustarts – nur verteilt, benötigt SSH zu allen Knoten |
| `nnbench.sh` | kein Default, `-operation` Pflicht | NameNode-Metadatenlast (create/open/rename/delete) über MapReduce |
| `nnbenchWithoutMR.sh` | erzeugt 1000 kleine Dateien, Start in 30s → `/lasttest/nnbenchwithoutmr` | Wie nnbench, aber direkt über einen Client-Prozess ohne MapReduce (reiner RPC-Test) |
| `NNstructureGenerator.sh` | kein Default | Erzeugt zufällige Verzeichnis-/Dateistruktur (nur Metadaten) – Stufe 1 der NN-Last-Kette |
| `NNdataGenerator.sh` | nutzt Struktur aus NNstructureGenerator.sh → `/lasttest/nnload` | Erzeugt die tatsächlichen Testdateien anhand der Struktur – Stufe 2 |
| `NNloadGenerator.sh` | 2 Minuten Last, 4 Threads, 50/50 Lese-/Schreibwahrscheinlichkeit | Synthetische Lese-/Schreiblast direkt gegen den NameNode (RPC, lokal) – Stufe 3 |
| `NNloadGeneratorMR.sh` | 4 Map-Jobs → `/lasttest/nnloadmr/out` | Wie NNloadGenerator, aber verteilt als MapReduce-Job über mehrere Knoten |
| `sleep.sh` | kein Default | Mapper/Reducer schlafen konfigurierbar lange – testet Scheduling/Slot-Durchsatz ohne CPU/I/O-Last |
| `SliveTest.sh` | kein Default, `-help` für alle Optionen | HDFS-Stresstest mit zufälligen Dateioperationen (create/read/append/rename/delete) inkl. Live-Verifikation |
| `testbigmapoutput.sh` | erzeugt 512-MB-Testdatei → `/lasttest/testbigmapoutput` | Verarbeitung einer sehr großen, nicht splitbaren Datei (Gegenstück zu nnbench) |
| `TestDFSIO.sh` | schreibt 4 Dateien à 128 MB (danach manuell `-read`/`-clean`) | Klassischer verteilter I/O-Benchmark (Lese-/Schreibdurchsatz) |
| `testfilesystem.sh` | kein Default, `-files N -megaBytes M` nötig | Paralleles Lesen/Schreiben/Seeken über die FileSystem-API |
| `testmapredsort.sh` | validiert `examples/sort.sh`-Ergebnis gegen `randomwriter.sh`-Eingabe | Korrektheitscheck, dass sort-Ausgabe tatsächlich sortiert ist |
| `testsequencefile.sh` | 100.000 Records, unkomprimiert, lokale Datei | Lesen/Schreiben/Sortieren/Mergen von SequenceFiles inkl. Kompression |
| `testsequencefileinputformat.sh` | keine Argumente nötig | Selbsttest, dass SequenceFileInputFormat korrekt in Splits partitioniert |
| `testtextinputformat.sh` | `<datei> [<datei>...]` nötig | Korrektes zeilenweises Einlesen durch TextInputFormat, auch komprimiert |
| `threadedmapbench.sh` | kein Default | Vergleicht Map-Tasks mit mehreren Spills vs. einem Spill (Spill-/Merge-Konfiguration) |
| `timelineperformance.sh` | 4 Mapper, Timeline Service v1, einfacher Entity-Writer | Durchsatz/Performance des YARN Timeline Service |

---

## hdfs-cli/longtest.sh

Aufruf: `./hdfs-cli/longtest.sh` (nutzt die `hdfs`-CLI direkt, muss also im
`PATH` verfügbar und konfiguriert sein, z. B. via `tools/common.sh` oder
manuell exportiertem `HADOOP_CONF_DIR`).

Was wird getestet: Dauertest über eine konfigurierbare Laufzeit (Default
1800 s). Legt pro Runde 10 Verzeichnisse mit je 10 Dateien parallel an
(`xargs -P 10`), schreibt und löscht sie wieder unter `/longtest` – simuliert
kontinuierliche NameNode-Metadaten- und HDFS-I/O-Last über einen längeren
Zeitraum. Räumt `/longtest` vor dem Start, bei Abbruch (`INT`/`TERM`) und am
Ende auf.
