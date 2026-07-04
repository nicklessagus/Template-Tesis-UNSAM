#!/usr/bin/env python3
r"""Chequeos mecánicos de la tesis (make check).

Valida lo que un grep determinístico puede validar, sin compilar:

ERRORES (exit 1):
  - \ref/\eqref/\autoref a labels inexistentes (menos whitelist)
  - labels duplicados
  - citas sin entrada en bibliography.bib
  - \label{eq:...} dentro de display sin numerar \[...\] (imprime nro de
    sección al referenciarse, sin warning de LaTeX)
  - \setcounter{chapter}{N} inconsistente con el número de capítulo
  - \includegraphics sin archivo en img/

AVISOS (no fallan):
  - em-dash (--- o U+2014) fuera de comentarios y \todo
  - decimales con punto en math mode (convención castellana: coma, 0{,}5)
  - \citep como sujeto de la oración (-> \citet)
  - prefijo img/ en \includegraphics (redundante con \graphicspath)
  - patrones del proyecto definidos en scripts/check_config.json

El contenido de comentarios (%) se ignora siempre; el de \todo{} se ignora
para los AVISOS de estilo (los todos son notas del autor) pero se incluye en
los chequeos mecánicos (un \ref roto dentro de un \todo genera warning real).

Para EXTENDER los chequeos al vocabulario de cada tesis, editar
scripts/check_config.json (no hace falta tocar este script):
  {
    "whitelist_refs":  ["fig:pendiente", ...],   // refs rotas aceptadas
    "check_decimal_comma": true,                  // false si se usa punto decimal
    "warn_patterns": [                            // regex propios del proyecto
      {"pattern": "...", "message": "..."},
      ...
    ]
  }
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT / "scripts" / "check_config.json"
BIB_PATH = ROOT / "bibliography.bib"

TEX_FILES = sorted(ROOT.glob("chapters/chapter-*.tex")) + [ROOT / "main.tex"]
TEX_FILES = [p for p in TEX_FILES if p.exists()]

errors = []    # (file, line, msg)
warnings = []  # (file, line, msg)


def load_config():
    if CONFIG_PATH.exists():
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    return {}


def strip_comments(text):
    """Borra comentarios % (no escapados) preservando longitud de líneas."""
    out_lines = []
    for line in text.split("\n"):
        m = re.search(r"(?<!\\)%", line)
        out_lines.append(line[: m.start()] if m else line)
    return "\n".join(out_lines)


def blank_todos(text):
    """Reemplaza el contenido de \\todo[...]{...} por espacios (mismo layout)."""
    result = list(text)
    for m in re.finditer(r"\\todo(\[[^\]]*\])?\{", text):
        depth = 1
        i = m.end()
        while i < len(text) and depth > 0:
            if text[i] == "{" and text[i - 1] != "\\":
                depth += 1
            elif text[i] == "}" and text[i - 1] != "\\":
                depth -= 1
            i += 1
        for j in range(m.start(), i):
            if result[j] != "\n":
                result[j] = " "
    return "".join(result)


def line_of(text, pos):
    return text.count("\n", 0, pos) + 1


def scan_pattern(files_text, pattern, message, bucket, flags=0):
    for path, text in files_text.items():
        for m in re.finditer(pattern, text, flags):
            bucket.append((path.name, line_of(text, m.start()), message))


def main():
    config = load_config()
    whitelist = set(config.get("whitelist_refs", []))

    raw = {p: p.read_text(encoding="utf-8") for p in TEX_FILES}
    nocomment = {p: strip_comments(t) for p, t in raw.items()}          # mecánica
    clean = {p: blank_todos(t) for p, t in nocomment.items()}           # estilo

    # ---------- ERRORES ----------
    # refs vs labels
    labels, refs = {}, []
    for p, t in nocomment.items():
        for m in re.finditer(r"\\label\{([^}]+)\}", t):
            labels.setdefault(m.group(1), []).append((p.name, line_of(t, m.start())))
        for m in re.finditer(r"\\(?:ref|eqref|autoref|vref)\{([^}]+)\}", t):
            refs.append((m.group(1), p.name, line_of(t, m.start())))
    for name, locs in labels.items():
        if len(locs) > 1:
            where = ", ".join(f"{f}:{l}" for f, l in locs)
            errors.append((locs[0][0], locs[0][1], f"label duplicado '{name}' ({where})"))
    for name, fname, lineno in refs:
        if name not in labels and name not in whitelist:
            errors.append((fname, lineno, f"ref rota: '{name}' no tiene \\label"))

    # citas vs bib
    bib_keys = set()
    if BIB_PATH.exists():
        for m in re.finditer(r"^\s*@\w+\{([^,\s]+)\s*,", BIB_PATH.read_text(encoding="utf-8"), re.M):
            bib_keys.add(m.group(1))
    for p, t in nocomment.items():
        for m in re.finditer(r"\\[Cc]ite[a-zA-Z]*\*?(?:\[[^\]]*\])*\{([^}]+)\}", t):
            for key in (k.strip() for k in m.group(1).split(",")):
                if key and key not in bib_keys:
                    errors.append((p.name, line_of(t, m.start()), f"cita sin entrada en bib: '{key}'"))

    # \label{eq:...} dentro de \[...\]  (el lookbehind excluye saltos \\[4pt])
    for p, t in nocomment.items():
        for m in re.finditer(r"(?<!\\)\\\[(.*?)(?<!\\)\\\]", t, re.S):
            lm = re.search(r"\\label\{([^}]+)\}", m.group(1))
            if lm:
                errors.append((p.name, line_of(t, m.start() + lm.start() + 2),
                               f"\\label{{{lm.group(1)}}} en display sin numerar \\[...\\]: "
                               "no genera número; usar equation"))

    # setcounter consistente con el nombre del archivo
    for p, t in nocomment.items():
        cm = re.match(r"chapter-(\d+)\.tex$", p.name)
        if not cm:
            continue
        n = int(cm.group(1))
        sm = re.search(r"\\setcounter\{chapter\}\{(\d+)\}", t)
        if n > 1 and (not sm or int(sm.group(1)) != n - 1):
            got = sm.group(1) if sm else "ausente"
            errors.append((p.name, line_of(t, sm.start()) if sm else 1,
                           f"\\setcounter{{chapter}} = {got}, se esperaba {n - 1}"))

    # assets
    for p, t in clean.items():
        for m in re.finditer(r"\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}", t):
            rel = m.group(1)
            base = rel[4:] if rel.startswith("img/") else rel
            cands = [ROOT / "img" / base] + [ROOT / "img" / f"{base}{e}" for e in (".pdf", ".png", ".jpg", ".jpeg")]
            if not any(c.exists() for c in cands):
                errors.append((p.name, line_of(t, m.start()), f"\\includegraphics: no existe img/{base}"))

    # ---------- AVISOS ----------
    scan_pattern(clean, r"---|—", "em-dash: usar comas o paréntesis", warnings)
    scan_pattern(clean, r"(?:\b[Ee]n|\bpor|documentad[oa]s? en|se detalla en|según) \\citep\{",
                 r"\citep como sujeto: usar \citet", warnings)
    scan_pattern(clean, r"\\includegraphics(?:\[[^\]]*\])?\{img/",
                 r"prefijo img/ redundante (\graphicspath)", warnings)

    if config.get("check_decimal_comma", True):
        for p, t in clean.items():
            spans = [m for m in re.finditer(r"\$[^$\n]+\$", t)]
            for env in re.finditer(r"\\begin\{(equation|align|gather)\*?\}(.*?)\\end\{\1\*?\}", t, re.S):
                spans.append(env)
            spans += list(re.finditer(r"(?<!\\)\\\[(.*?)(?<!\\)\\\]", t, re.S))
            for m in spans:
                for d in re.finditer(r"\d\.\d", m.group(0)):
                    warnings.append((p.name, line_of(t, m.start() + d.start()),
                                     "decimal con punto en math: usar 0{,}5"))

    for item in config.get("warn_patterns", []):
        scan_pattern(clean, item["pattern"], item["message"], warnings)

    # ---------- REPORTE ----------
    def show(bucket, tag):
        for fname, lineno, msg in sorted(bucket):
            print(f"  {tag} {fname}:{lineno}  {msg}")

    todo_count = sum(len(re.findall(r"\\todo(?:\[[^\]]*\])?\{", t)) for t in nocomment.values())

    if errors:
        print(f"ERRORES ({len(errors)}):")
        show(errors, "[E]")
    if warnings:
        print(f"AVISOS ({len(warnings)}):")
        show(warnings, "[W]")
    print(f"INFO: {todo_count} \\todo, {len(labels)} labels, {len(bib_keys)} entradas bib.")
    if not errors:
        print("OK: sin errores mecánicos.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
