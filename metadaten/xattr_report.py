#!/usr/bin/env python3
"""
Wertet ein fsimage-XML (hdfs oiv -p XML) aus und berechnet, wie viele
Extended Attributes (xattrs) je Datei im Cluster gesetzt sind: Maximum,
Durchschnitt (ueber alle Dateien und ueber nur die Dateien MIT xattrs)
sowie die Top-N Dateien mit den meisten xattrs inkl. rekonstruiertem Pfad.

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


def analyze(xml_path, top_n):
    total_files = 0
    files_with_xattrs = 0
    total_xattr_count = 0
    max_count = 0
    top_heap = []  # min-heap von (count, id, name), Groesse <= top_n

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
                    xattrs_elem = elem.find("xattrs")
                    cnt = len(xattrs_elem.findall("xattr")) if xattrs_elem is not None else 0
                    total_xattr_count += cnt
                    if cnt > max_count:
                        max_count = cnt
                    if cnt > 0:
                        files_with_xattrs += 1
                        if len(top_heap) < top_n:
                            heapq.heappush(top_heap, (cnt, inode_id, name))
                        elif cnt > top_heap[0][0]:
                            heapq.heapreplace(top_heap, (cnt, inode_id, name))
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
        "files_with_xattrs": files_with_xattrs,
        "total_xattr_count": total_xattr_count,
        "max_count": max_count,
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
    files_with_xattrs = result["files_with_xattrs"]
    total_xattr_count = result["total_xattr_count"]
    max_count = result["max_count"]
    top = result["top"]
    dir_names = result["dir_names"]
    parent_map = result["parent_map"]

    print("=" * 70)
    print("  xattr-Report (aus fsimage)")
    print("=" * 70)
    print(f"Dateien insgesamt:               {total_files}")
    if total_files:
        pct = 100.0 * files_with_xattrs / total_files
    else:
        pct = 0.0
    print(f"Dateien mit >=1 xattr:            {files_with_xattrs} ({pct:.2f}%)")
    print(f"xattrs insgesamt:                 {total_xattr_count}")
    if total_files:
        print(f"Durchschnitt xattrs/Datei (alle):        {total_xattr_count / total_files:.4f}")
    if files_with_xattrs:
        print(f"Durchschnitt xattrs/Datei (nur mit xattr): {total_xattr_count / files_with_xattrs:.4f}")
    print(f"Maximum xattrs auf einer einzelnen Datei: {max_count}")
    print()

    if top:
        root_id = find_root_id(dir_names, parent_map)
        print(f"Top {len(top)} Dateien nach xattr-Anzahl:")
        for cnt, inode_id, name in top:
            path = resolve_path(inode_id, name, parent_map, dir_names, root_id)
            print(f"  {cnt:6d}  {path}")
    else:
        print("Keine Dateien mit xattrs gefunden.")

    print("=" * 70)


if __name__ == "__main__":
    try:
        main()
    except FileNotFoundError as e:
        print(f"FEHLER: {e}", file=sys.stderr)
        sys.exit(1)
