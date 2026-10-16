#!/usr/bin/env python3
"""Generate the Zigmacs port-progress report straight from the source tree.

What it computes EXACTLY (no hand-tallying):
  * DEFUN surface — every `DEFUN (...)` in the C sources, split into:
      - all .c          (every DEFUN in src/*.c)
      - relevant (nox)  (only files actually compiled: a sibling .o exists)
      - excluded        (all - relevant; GUI backends etc.)
  * Ported set — a DEFUN is "ported" iff its body contains the dispatcher
    marker `egetenv ("ZIGMACS_AB")` (one per Channel-A dispatcher). Mapped to
    the enclosing DEFUN name. Cross-checked against src/zig/*.zig.
  * Per-source-file ported breakdown.
  * Per-category DONE — ported names looked up in scripts/port-categories.tsv.

What stays DECLARED (soft, editable): per-category TOTAL for the leaf cats A/B/C/H
and the subsystem rows D-G. These are estimates until the full surface is
classified in port-categories.tsv; the script reports classification coverage so
the softness is visible, never hidden behind a bare "~".

Usage:
    python3 scripts/port-progress.py            # print report to stdout
    python3 scripts/port-progress.py --write     # also splice the table into
                                                 # PORT_CATEGORIES.md between
                                                 # <!-- PORT-PROGRESS:{START,END} -->
    python3 scripts/port-progress.py --check      # exit 1 if trackers drift
"""
from __future__ import annotations
import argparse
import datetime
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "src")
ZIG_DIR = os.path.join(SRC, "zig")
TSV = os.path.join(ROOT, "scripts", "port-categories.tsv")
DOC = os.path.join(ROOT, "PORT_CATEGORIES.md")

DEFUN_RE = re.compile(r'^DEFUN\s*\(\s*"([^"]+)"', re.M)
AB_MARKER = 'egetenv ("ZIGMACS_AB")'

# Declared per-category metadata (soft TOTALs + labels). Edit as classification
# of the surface improves; DONE is always computed, never taken from here.
CATEGORIES = [
    ("A", "Pure type predicates / const", 40, "leaf"),
    ("B", "Pure computational (arith, list/seq/string)", 230, "leaf"),
    ("C", "Stateful (mutate point/buffer/globals)", 260, "leaf"),
    ("D", "Interpreter & reader core", None, "subsystem"),
    ("E", "Buffer/text engine & search", None, "subsystem"),
    ("F", "Garbage collector (alloc.c)", None, "subsystem"),
    ("G", "Redisplay/terminal/windows", None, "subsystem"),
    ("H", "I/O / process / coding / compat", 280, "leaf"),
    ("X", "GUI window-system backends", None, "excluded"),
]
EST_CATS = {"A", "B", "C", "H"}  # TOTAL is an estimate (mark with ~)


def git_sha() -> str:
    try:
        return subprocess.check_output(
            ["git", "-C", ROOT, "rev-parse", "--short", "HEAD"],
            text=True).strip()
    except Exception:
        return "unknown"


def iter_c_files():
    for f in sorted(glob.glob(os.path.join(SRC, "*.c"))):
        yield f, os.path.exists(f[:-2] + ".o")


def scan_source():
    """Return (surface, ported, per_file_ported, excluded_files).

    surface: dict name -> {file, relevant}
    ported:  dict name -> file   (relevant files only)
    """
    surface, ported, per_file = {}, {}, {}
    n_all = n_rel = 0
    excluded = []
    for path, compiled in iter_c_files():
        base = os.path.basename(path)
        text = open(path, encoding="utf-8", errors="replace").read()
        matches = list(DEFUN_RE.finditer(text))
        n_all += len(matches)
        if not compiled:
            if matches:
                excluded.append(base)
            continue
        n_rel += len(matches)
        starts = [m.start() for m in matches]
        names = [m.group(1) for m in matches]
        bounds = starts + [len(text)]
        for i, name in enumerate(names):
            surface[name] = {"file": base, "relevant": True}
            body = text[bounds[i]:bounds[i + 1]]
            if AB_MARKER in body:
                ported[name] = base
                per_file[base] = per_file.get(base, 0) + 1
    return surface, ported, per_file, n_all, n_rel, excluded


def load_classification():
    cat = {}
    if not os.path.exists(TSV):
        return cat
    for line in open(TSV, encoding="utf-8"):
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue
        parts = line.split("\t")
        if len(parts) >= 2:
            cat[parts[0].strip()] = parts[1].strip()
    return cat


def zig_ports():
    names = set()
    for f in glob.glob(os.path.join(ZIG_DIR, "*.zig")):
        b = os.path.basename(f)[:-4]
        if b == "emacs":
            continue
        names.add(b)
        names.add(b.replace("_", "-"))
    return names


def build_report():
    surface, ported, per_file, n_all, n_rel, excluded = scan_source()
    cls = load_classification()
    zigs = zig_ports()

    # per-category DONE (ported ∩ classification)
    done = {c: 0 for c, *_ in CATEGORIES}
    classified_total = {c: 0 for c, *_ in CATEGORIES}
    for name, c in cls.items():
        if c in classified_total:
            classified_total[c] += 1
    unclassified_ports = []
    for name in ported:
        c = cls.get(name)
        if c is None:
            unclassified_ports.append(name)
        elif c in done:
            done[c] += 1

    # drift checks
    warnings = []
    ported_norm = set(ported) | {n.replace("-", "_") for n in ported}
    only_in_zig = {z for z in zigs if z not in ported_norm and z.replace("-", "_") not in {p.replace("-", "_") for p in ported}}
    if len(ported) != sum(1 for z in glob.glob(os.path.join(ZIG_DIR, "*.zig")) if os.path.basename(z) != "emacs.zig"):
        warnings.append(
            f"port count mismatch: {len(ported)} dispatchers (ZIGMACS_AB) vs "
            f"{len([z for z in glob.glob(os.path.join(ZIG_DIR,'*.zig')) if os.path.basename(z)!='emacs.zig'])} .zig files")
    for z in sorted(only_in_zig):
        warnings.append(f".zig without detected dispatcher: {z}.zig")
    for name in sorted(unclassified_ports):
        warnings.append(f"unclassified port (add to port-categories.tsv): {name}")

    return dict(surface=surface, ported=ported, per_file=per_file, n_all=n_all,
                n_rel=n_rel, excluded=excluded, done=done,
                classified_total=classified_total, cls=cls, warnings=warnings)


def render_table(r) -> str:
    total_done = len(r["ported"])
    pct = 100.0 * total_done / r["n_rel"] if r["n_rel"] else 0.0
    out = []
    out.append(f"<!-- generated by scripts/port-progress.py from source @ {git_sha()} "
               f"on {datetime.date.today().isoformat()} — do not edit by hand -->")
    out.append("")
    out.append(f"**Overall: {total_done} / {r['n_rel']} relevant DEFUNs ported "
               f"({pct:.1f}%).**  Surface: {r['n_all']} DEFUNs in all `src/*.c`; "
               f"{r['n_rel']} in the compiled nox build; "
               f"{r['n_all'] - r['n_rel']} excluded (GUI backends etc.). "
               f"Classified in map: {len(r['cls'])} / {r['n_rel']}.")
    out.append("")
    out.append("| Cat | What | Done | Total | Notes |")
    out.append("|---|---|---|---|---|")
    for c, label, total, kind in CATEGORIES:
        d = r["done"].get(c, 0)
        if kind == "subsystem":
            tot_s, note = "subsystem", "Phase 2; LOC-driven, not per-DEFUN"
        elif kind == "excluded":
            tot_s, note = "—", "out of scope (nox)"
        else:
            tot_s = (f"~{total}" if c in EST_CATS else f"{total}")
            clt = r["classified_total"].get(c, 0)
            note = ("TOTAL is an estimate — classify surface in "
                    "port-categories.tsv to make exact" if c in EST_CATS
                    else f"{clt} classified")
        out.append(f"| **{c}** | {label} | **{d}** | {tot_s} | {note} |")
    out.append("")
    out.append("_Done = ported DEFUNs detected in source (dispatcher marker) ∩ "
               "`scripts/port-categories.tsv`. Total for A/B/C/H is a declared "
               "estimate; D–G are whole-engine subsystems (LOC, not DEFUN count)._")
    return "\n".join(out)


def render_detail(r) -> str:
    out = ["", "Ported by source file:"]
    for f, n in sorted(r["per_file"].items(), key=lambda x: -x[1]):
        out.append(f"  {n:3d}  {f}")
    if r["warnings"]:
        out.append("")
        out.append("DRIFT / TODO:")
        for w in r["warnings"]:
            out.append(f"  ! {w}")
    else:
        out.append("")
        out.append("No drift: dispatchers, .zig files, and classification map agree.")
    return "\n".join(out)


def splice_doc(table: str):
    start = "<!-- PORT-PROGRESS:START -->"
    end = "<!-- PORT-PROGRESS:END -->"
    doc = open(DOC, encoding="utf-8").read()
    block = f"{start}\n{table}\n{end}"
    if start in doc and end in doc:
        doc = re.sub(re.escape(start) + r".*?" + re.escape(end), block,
                     doc, flags=re.S)
    else:
        # insert right after the "## Progress by category" heading
        marker = "## Progress by category"
        idx = doc.index(marker) + len(marker)
        doc = doc[:idx] + "\n\n" + block + "\n" + doc[idx:]
    open(DOC, "w", encoding="utf-8").write(doc)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", action="store_true",
                    help="splice the table into PORT_CATEGORIES.md")
    ap.add_argument("--check", action="store_true",
                    help="exit non-zero if trackers drift")
    args = ap.parse_args()

    r = build_report()
    table = render_table(r)
    print(table)
    print(render_detail(r))

    if args.write:
        splice_doc(table)
        print(f"\n[wrote table into {os.path.relpath(DOC, ROOT)}]")
    if args.check and r["warnings"]:
        print("\nFAIL: tracker drift detected (see above).", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
