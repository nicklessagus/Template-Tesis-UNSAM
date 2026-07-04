---
name: biblio-check
description: Validate bibliography.bib entries against external sources (ADS/CrossRef/arXiv) via web search. Detects mixed/wrong metadata (title-author-year-journal-DOI incoherence), duplicates, malformed fields, and unused entries. Trigger on /biblio-check, "validar bibliografía", "chequear las referencias", "revisar el bib". Read-only over bibliography.bib: proposes corrected BibTeX blocks, never applies them. Complements make check (which only verifies that cited keys EXIST in the bib, not that their content is right).
---

# biblio-check

Validación de contenido de `bibliography.bib`: que cada entrada citada
corresponda a una publicación real y que sus metadatos (autores, año,
journal, DOI) sean internamente coherentes y correctos contra la fuente.
Es el chequeo que `make check` no puede hacer, porque requiere criterio y
consulta externa.

## When to use

Trigger on:
- `/biblio-check` (todas las entradas citadas), `/biblio-check <key>` (una).
- "validá la bibliografía", "chequeá las referencias", "revisá el bib".

Do NOT trigger on:
- "¿existe la cita X en el bib?" → eso es `make check` (mecánico).
- Agregar una referencia nueva → tarea normal de edición.

## Flags

- `<key>` — valida solo esa entrada (a fondo).
- `--all` — incluye también las entradas NO citadas en ningún `.tex`
  (por defecto solo se validan las citadas; las no citadas solo se listan).
- `--offline` — solo chequeos mecánicos de formato, sin verificación web.
- `--save` — escribe el reporte completo a `BIBLIO-report.md` (raíz del
  repo). Por defecto solo resumen en chat.

## Process

### Step 1 — Inventario

Extraer keys citadas de `chapters/*.tex` + `main.tex` (todas las variantes
`\cite*`, split por coma) y parsear `bibliography.bib` (key, tipo, campos).
Reportar: N entradas, N citadas, N no citadas, N citadas sin entrada (esto
último ya lo cubre `make check`; solo confirmar).

### Step 2 — Chequeos mecánicos (sin web)

Por entrada citada:
- **Campos requeridos por tipo**: `@article` → author, title, journal, year;
  `@book` → author/editor, title, publisher, year; `@inproceedings` →
  booktitle; `@misc/@online` → title + url o note.
- **Formato de autores**: separador `and` (nunca comas entre autores),
  "Apellido, Nombre" consistente, sin caracteres que rompan biber.
- **Año plausible** y coherente con la key si la key lo incluye
  (`Perez2023` con `year = 2019` es sospechoso).
- **Duplicados**: DOIs repetidos, títulos casi idénticos (normalizar
  mayúsculas/puntuación), keys que difieren solo en sufijo.
- **Campos cruzados sospechosos**: journal en documentos que no son papers
  (manuales, reportes), páginas/volumen en entradas `@misc`.

### Step 3 — Verificación externa (el corazón del skill)

Para cada entrada citada (en el orden del Step 4): buscar con WebSearch el
título + primer autor (ADS para astronomía/física, CrossRef, arXiv, Google
Scholar según la disciplina). Comparar lo devuelto contra la entrada:

| Coincide | Veredicto |
|---|---|
| título + autores + año + journal (+ DOI si hay) | **OK** |
| el título es de un paper y los autores/año/journal de OTRO | **MEZCLADO** |
| difiere un campo secundario (páginas, volumen, año ±1 por preprint) | **DUDOSO** (listar la corrección) |
| no verificable online (manuales técnicos, documentación instrumental, informes internos) | **GRIS** (verificar que la URL responda y el título coincida; si no hay URL, marcar para el archivo personal del autor) |

Si dos publicaciones candidatas matchean parcialmente, listar ambas con sus
DOIs y preguntar al autor cuál era la que quiso citar, mirando el contexto
de la cita en el `.tex`: qué afirma la oración que la cita.

### Step 4 — Prioridad

1. Entradas que el proyecto ya tenga marcadas como sospechosas (CLAUDE.md,
   memorias o TODOs del repo).
2. Entradas flageadas por el Step 2.
3. El resto de las citadas, en orden de aparición.

Con más de ~30 entradas, avisar el costo en tiempo (una búsqueda por
entrada) y ofrecer correr por lotes o solo prioridad 1+2.

### Step 5 — Reporte

Resumen en chat: tabla key → veredicto → problema en una línea. Para cada
entrada NO-OK: el bloque BibTeX **corregido completo** listo para pegar, con
la fuente de la corrección (link ADS/DOI). Con `--save`, todo a
`BIBLIO-report.md`.

## Important notes

- **Read-only**: NUNCA editar `bibliography.bib` desde este skill. Se
  proponen bloques corregidos y el autor decide, item por item.
- **No inventar DOIs ni bibcodes**: solo reportar identificadores que
  aparezcan en la fuente consultada. Si no se encuentra, decir "no
  encontrado", no adivinar.
- **No proponer renombrar keys** citadas en los `.tex` (rompería las citas);
  la excepción son duplicados verdaderos, donde se propone cuál conservar y
  qué reemplazos hacer en los `.tex`.
- **Contexto de la cita manda**: ante ambigüedad, leer la oración del `.tex`
  donde se usa la key; la publicación correcta es la que respalda ESA
  afirmación.
- **Entradas grises**: manuales y documentación técnica no están en las
  bases bibliográficas; el criterio es URL viva + título coincidente, no
  metadatos bibliográficos.
