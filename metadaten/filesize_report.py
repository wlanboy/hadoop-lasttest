#!/usr/bin/env python3
"""
Wertet ein fsimage-XML (hdfs oiv -p XML) aus und berechnet die
Dateigroessen je Datei im Cluster: Maximum, Durchschnitt sowie die
Top-N groessten Dateien inkl. rekonstruiertem Pfad.

Die Dateigroesse wird als Summe der numBytes aller Bloecke einer Datei
ermittelt (logische Groesse, ohne Replikationsfaktor).

Arbeitet als Streaming-Parser (iterparse + elem.clear()), damit auch
fsimages mit vielen Millionen Inodes ohne den gesamten Baum im Speicher
verarbeitet werden koennen. Fuer die Pfadrekonstruktion der Top-N Dateien
wird eine vollstaendige id->parent-Zuordnung aus der
INodeDirectorySection aufgebaut (Speicherbedarf ~ Anzahl Inodes).
"""
import argparse
import heapq
import sys
import xml.etree.ElementTree as ET


def human_size(num_bytes):
    size = float(num_bytes)
    for unit in ("B", "KB", "MB", "GB", "TB", "PB"):
        if size < 1024.0:
            return f"{size:.2f} {unit}"
        size /= 1024.0
    return f"{size:.2f} EB"


def analyze(xml_path, top_n):
    total_files = 0
    files_with_size = 0
    total_size = 0
    max_size = 0
    top_heap = []  # min-heap von (size, id, name), Groesse <= top_n

    dir_names = {}      # inode_id -> lokaler Name (nur Verzeichnisse)
    parent_map = {}      # child_id -> parent_id (alle Inodes)

    section = None
    context = ET.iterparse(xml_path, events=("start", "end"))
    for event, elem in context:
        tag = elem.tag
        if event == "start":
            if tag in ("INodeSection", "INodeDirectorySection"):
                section = tag
            continue

        # event == "end"
        if tag == "inode" and section == "INodeSection":
            inode_id_text = elem.findtext("id")
            itype = elem.findtext("type")
            name = elem.findtext("name") or ""
            if inode_id_text is not None:
                inode_id = int(inode_id_text)
                if itype == "DIRECTORY":
                    dir_names[inode_id] = name
                elif itype == "FILE":
                    total_files += 1
                    blocks_elem = elem.find("blocks")
                    size = 0
                    if blocks_elem is not None:
                        for block_elem in blocks_elem.findall("block"):
                            num_bytes_text = block_elem.findtext("numBytes")
                            if num_bytes_text is not None:
                                size += int(num_bytes_text)
                    total_size += size
                    if size > max_size:
                        max_size = size
                    if size > 0:
                        files_with_size += 1
                        if len(top_heap) < top_n:
                            heapq.heappush(top_heap, (size, inode_id, name))
                        elif size > top_heap[0][0]:
                            heapq.heapreplace(top_heap, (size, inode_id, name))
            elem.clear()
        elif tag == "directory" and section == "INodeDirectorySection":
            parent_text = elem.findtext("parent")
            if parent_text is not None:
                parent_id = int(parent_text)
                for child_elem in elem.findall("child"):
                    if child_elem.text:
                        parent_map[int(child_elem.text)] = parent_id
            elem.clear()
        elif tag in ("INodeSection", "INodeDirectorySection"):
            section = None
            elem.clear()

    return {
        "total_files": total_files,
        "files_with_size": files_with_size,
        "total_size": total_size,
        "max_size": max_size,
        "top": sorted(top_heap, reverse=True),
        "dir_names": dir_names,
        "parent_map": parent_map,
    }


def resolve_path(file_id, file_name, parent_map, dir_names, root_id):
    parts = [file_name]
    cur = parent_map.get(file_id)
    seen = set()
    while cur is not None and cur != root_id:
        if cur in seen:
            parts.append("<zyklus>")
            break
        seen.add(cur)
        parts.append(dir_names.get(cur, f"<dir-id:{cur}>"))
        cur = parent_map.get(cur)
    parts.reverse()
    return "/" + "/".join(p for p in parts if p != "")


def find_root_id(dir_names, parent_map):
    child_ids = set(parent_map.keys())
    candidates = [d for d in dir_names if d not in child_ids]
    return candidates[0] if candidates else None


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("xml_path", help="Pfad zum fsimage-XML (hdfs oiv -p XML Ausgabe)")
    ap.add_argument("--top", type=int, default=20, help="Anzahl der Top-Dateien im Report (default: 20)")
    args = ap.parse_args()

    result = analyze(args.xml_path, args.top)

    total_files = result["total_files"]
    files_with_size = result["files_with_size"]
    total_size = result["total_size"]
    max_size = result["max_size"]
    top = result["top"]
    dir_names = result["dir_names"]
    parent_map = result["parent_map"]

    print("=" * 70)
    print("  Dateigroessen-Report (aus fsimage)")
    print("=" * 70)
    print(f"Dateien insgesamt:                {total_files}")
    print(f"Dateien mit Groesse > 0:          {files_with_size}")
    print(f"Gesamtgroesse (logisch):          {human_size(total_size)} ({total_size} Bytes)")
    if total_files:
        avg_all = total_size / total_files
        print(f"Durchschnitt Groesse/Datei (alle):        {human_size(avg_all)}")
    if files_with_size:
        avg_nonzero = total_size / files_with_size
        print(f"Durchschnitt Groesse/Datei (nur > 0):      {human_size(avg_nonzero)}")
    print(f"Maximum Groesse einer einzelnen Datei:    {human_size(max_size)}")
    print()

    if top:
        root_id = find_root_id(dir_names, parent_map)
        print(f"Top {len(top)} Dateien nach Groesse:")
        for size, inode_id, name in top:
            path = resolve_path(inode_id, name, parent_map, dir_names, root_id)
            print(f"  {human_size(size):>12}  {path}")
    else:
        print("Keine Dateien mit Groesse > 0 gefunden.")

    print("=" * 70)


if __name__ == "__main__":
    try:
        main()
    except FileNotFoundError as e:
        print(f"FEHLER: {e}", file=sys.stderr)
        sys.exit(1)
