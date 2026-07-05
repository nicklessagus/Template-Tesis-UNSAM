---
name: audit-chapter
description: Audit a single thesis chapter (chapters/chapter-N.tex) against the project's writing-style profile, notation conventions (CLAUDE.md), bibliography, and cross-references. Trigger on /audit-chapter <N>, "audit chapter N", "auditar cap N", "revisar cap N completo". Reports findings classified by severity (A/B/C/E by default; D+E-semantic with --deep) for the user to discuss before editing. Use --save to persist a full report to AUDITORIA-cap-N.md. Honors \todo{CLAUDE: ...} directed requests: verification requests are executed read-only and reported, edit requests are queued for the follow-up. Read-only: NEVER apply fixes from inside this skill.
---

# audit-chapter

Mechanical and structural audit of one thesis chapter. The skill produces a
classified report of findings for the user to discuss item by item; it does
**not** apply fixes. The conversational follow-up (which findings to apply,
which to discard, in what order) happens outside the skill.

## When to use

Trigger on:
- `/audit-chapter <N>` slash command (canonical form).
- Direct request that names the action and the chapter: "audit chapter 4",
  "auditar cap 4", "revisar cap 4 completo", "auditoría del cap. 4".

Do **NOT** trigger on:
- Specific line-level corrections ("fix the typo on line 42").
- Stylistic rewriting of a specific paragraph.
- Pure bibliography questions (use `/biblio-check` if/when it exists).
- Cross-chapter or thesis-wide consistency questions (out of scope for
  this skill).

## Flags

- `--deep` — adds severity categories **D** (empirical claims that should
  have a citation but don't) and **E-semantic** (logical jumps where the
  conclusion does not follow from the stated premises). Slower (~3-5 min)
  because it spawns an `Explore` sub-agent to read the chapter in isolation
  and produce focused findings.
- `--save` — writes the full report to `AUDITORIA-cap-<N>.md` in the repo
  root in addition to the in-chat summary. By default, no file is written.

Flags may be combined (`--deep --save`).

## Inputs to load before starting

1. The target chapter: `chapters/chapter-<N>.tex`.
2. `CLAUDE.md` — read it **fresh** every run. The notation table and the
   writing-style profile evolve; never hardcode them inside this skill.
3. `bibliography.bib` — for citation validation.
4. The other `chapters/*.tex` and `main.tex` — only for cross-reference
   resolution (resolving `\ref{}` and `\label{}`). Do NOT audit them.

## Severity rubric

- **[A]** — Errors to fix before any external read. Notation conflicts,
  broken `\ref{}`, citations to keys not in bib, `\setcounter{chapter}{N}`
  inconsistent with chapter position, malformed LaTeX.
- **[B]** — Substantive improvements. Bib entries cited in the chapter but
  not in `bibliography.bib`; bib entries that look topically relevant but
  are not cited; incomplete subsections (only a `\todo[inline]`); pending
  architectural decisions (`\todo` containing "decisión", "pendiente",
  "definir"); forward references that disrupt linear reading.
- **[C]** — Style and micro-fixes derived from `CLAUDE.md` "Lo que NO suena
  como el autor": em-dashes (`---`), "el mismo / la misma" used as
  anaphoric pronouns, "es crucial / fundamental / cabe destacar / es
  importante notar / en este sentido", decimals with point in math mode
  (Spanish uses comma), ASCII quotes `"..."`.
- **[D]** — (with `--deep` only) Empirical claims that need a citation but
  don't have one nearby. Numerical facts, historical claims, methods
  attributed to others, derivations reproduced from external sources.
- **[E]** — Structural and logical. Section imbalance, broken transitions,
  long sections without subsection breakdown, self-references that read as
  redundant. (With `--deep`: logical jumps where "por lo tanto" / "esto
  implica" / "en consecuencia" introduces a conclusion the premises don't
  strictly support.)

## Process

Execute these steps in order. Do not skip steps; do not parallelize them
unless explicitly noted. Use Bash/grep for mechanical checks and Read for
file inspection. Use the Edit tool **never** during an audit.

### Step 1 — Inventory

Compute and remember (for the report header):

- Total lines (`wc -l`).
- Count of `\section`, `\subsection`, `\subsubsection`, `\paragraph`.
- Count of `\todo` and `\todo[inline]`.
- Count of unique citation keys (`\cite`, `\citep`, `\citet`).
- Count of `\label` and `\ref`.
- Count of `\begin{equation}`, `\begin{align}`, `\begin{figure}`,
  `\begin{table}`.

### Step 1b — [CLAUDE] Directed requests

The author leaves direct requests for the assistant inside todos, marked
with the prefix `CLAUDE` (canonical form `\todo{CLAUDE: ...}`; tolerate
variants without colon and `\todo[inline]{CLAUDE ...}`). Collect them with:

```
grep -nE '\\todo(\[[^]]*\])?\{\s*CLAUDE\b' chapters/chapter-<N>.tex
```

These are NOT ordinary findings — they are instructions. Handle each one
according to its nature:

- **Check/verify requests** ("chequear X contra la bibliografía",
  "verificar esta ecuación", "confirmar que Y") — **execute them during
  the audit** using read-only tools (Read, grep, bibliography lookup) and
  report the outcome in the `[CLAUDE]` block: what was asked, what was
  checked, verdict (OK / discrepancia encontrada / no verificable sin
  fuente externa, y por qué).
- **Edit/rewrite requests** ("reescribir esto", "agregar figura",
  "redactar la prosa") — do NOT execute (the skill is read-only). List
  them in the `[CLAUDE]` block as queued, so they get picked up in the
  conversational follow-up after the report.
- **Ambiguous requests** — list them with a one-line interpretation and a
  question mark, to be clarified in the follow-up.

Also use these requests to **steer the rest of the audit**: if a CLAUDE
todo points at a paragraph or equation, give that region extra scrutiny in
Steps 2-5 (notation, citations, logic) even if no generic pattern flags it.

Do not double-report: a `\todo{CLAUDE: ...}` goes in the `[CLAUDE]` block
only, not also under [B] "Architectural TODOs".

### Step 2 — [A] Technical errors

**Broken references.** For each `\ref{X}` in the chapter, verify that `\label{X}`
exists in some file under `chapters/` or in `main.tex`. Report unresolved
labels as [A].

**Missing citations.** For each citation key used (any of `\cite`, `\citep`,
`\citet`, `\citeyear`, `\citealt`), verify that the key exists in
`bibliography.bib`. Report missing keys as [A].

**Chapter counter.** Verify `\setcounter{chapter}{N}` is consistent with the
chapter's position in `main.tex` (`\subfile{chapters/chapter-K}` order).

**Notation conflicts inside the chapter (high priority).**
Read the reserved-symbol table from `CLAUDE.md` (cada tesis define la suya:
qué letras se reservan para qué cantidades o índices) y verificar que el
capítulo use cada símbolo reservado de forma consistente: ningún símbolo con
dos significados físicos, ningún índice reservado reutilizado para otra
cantidad. Si `CLAUDE.md` no existe o no tiene tabla de notación, saltear este
check y anotarlo en el reporte.

Si `CLAUDE.md` define una regla de alcance para un decorador (p.ej.\ un hat
`\hat{}` restringido a los pasajes donde verdad y estimación coexisten),
contrastar cada sección contra el listado canónico de pasajes de `CLAUDE.md`;
releerlo cada corrida. Uso sistemático fuera de ese listado **NO** es [A]:
formularlo como [B] pregunta — "¿corresponde extender la regla de CLAUDE.md a
esta sección (p.ej.\ tras una reorg), o reformular el texto?".

Heuristic for same-letter-two-meanings: search the chapter for "donde $X$
es" / "con $X$ la" patterns and identify whether the same symbol gets
multiple physical definitions. Example to atrapar: `$K$` definido como una
cantidad en un pasaje y como otra distinta en otro pasaje del mismo capítulo.
Report each conflict as [A] with both locations.

### Step 3 — [B] Substantive issues

**Orphan bib entries.** List entries in `bibliography.bib` that are NOT
cited anywhere in the chapter but look topically relevant. Be conservative:
do not flag every uncited entry, only those whose title/abstract suggests
they would naturally belong in this chapter.

**Empty subsections.** Find `\subsection{...}` blocks whose only content is
`\todo[inline]` (no prose). Report as [B].

**Forward references.** For each `\ref{X}` inside the chapter that resolves
to a `\label{X}` defined LATER in the same chapter, report as [B] (lector
llega al concepto antes de su definición).

**Architectural TODOs.** Search for `\todo[inline]` containing keywords
"sección pendiente", "decisión", "definir", "arquitectónica", "pendiente
de reubicación". Report each as [B] — these are decisions the user owes
themselves. Skip todos with the `CLAUDE` prefix: those belong to the
`[CLAUDE]` block (Step 1b), not here.

**Concepts without citation (heuristic).** Find prose like "el algoritmo
de X", "el método de X", "el formalismo de X", "el modelo de X" that has
NO `\citep` within ~3 lines. Report as [B] candidates (false positives
likely — flag for review).

### Step 4 — [C] Style and micro-fixes

Run grep against the chapter content (skip lines starting with `%`):

| Pattern | Severity |
|---|---|
| `---` LaTeX (em-dash) usado como aside en medio de oración | [C] |
| Unicode em-dash `—` (U+2014) en prosa | [C] |
| `\bel mismo\b`, `\bla misma\b`, `\blos mismos\b`, `\blas mismas\b` | [C] — context-sensitive, heuristic: preceded by comma + verb |
| `\bes crucial\b`, `\bes fundamental\b`, `\bcabe destacar\b`, `\bes importante notar\b`, `\ben este sentido\b` | [C] |
| Decimal with `.` in math mode (e.g., `$0.95$`) | [C] |
| ASCII quotes `"..."` (excluding code blocks like `\texttt{}`) | [C] |
| Repeated word within ~50 words (e.g., "importante" twice nearby) | [C], very conservative |
| `snake_case` o `camelCase` dentro de `\mathrm{}` o como sub/superíndice matemático (p.ej.\ `$\mathrm{some\_var}$`, `$X_\mathrm{my\_var}$`) | [C] — código entrando al espacio matemático; sugerir símbolo físico o mover a `\texttt{}`. **No flagear** identificadores all-caps que son siglas legítimas del proyecto (p.ej.\ `\mathrm{SNR}`) ni los que ya viven dentro de `\texttt{}` |

**Sólo se flagea em-dash.** Los en-dash LaTeX `--`, el carácter Unicode
en-dash `–` (U+2013), y los guiones simples para rangos numéricos
(`10-20`, `10--20`) o apellidos compuestos (Cramér--Rao,
Levenberg--Marquardt) son aceptables y **no** deben
reportarse. La regla del autor en CLAUDE.md es contra el em-dash como
inciso (rompe el flujo), no contra los guiones cortos.

For each hit: report line + context snippet. Be explicit that some are
likely false positives and ask the user to confirm.

### Step 5 — [E] Structural

**No doblar con [B].** Las subsecciones cuyo único contenido es
`\todo[inline]` ya están reportadas en [B] bajo "Empty subsections"
(paso 3). En [E] **no** volver a listarlas, ni siquiera con nota del
tipo "duplica B1". Si una observación estructural sólo se aplica a
una subsección vacía y ya está en [B], directamente omitirla aquí.

- **Section imbalance.** If one `\section` spans more than 2× the median
  section length, flag it as [E] candidate for splitting.
- **Long sections without subdivision.** Sections >200 lines without any
  `\subsection` inside.
- **Missing transitions.** Each `\section{...}` should have at least one
  paragraph of prose between its title and the first `\subsection`. Flag
  sections that jump straight into a subsection as [E] — **excepto** si
  la sección está vacía y ya está en [B] (regla de no doblar arriba).
- **Redundant self-references.** Within the chapter, `Capítulo~\ref{chap:THIS}`
  reads awkwardly; suggest "este capítulo" instead. Flag as [E].

### Step 6 — [D] + [E-semantic] (only with `--deep`)

Spawn an `Explore` sub-agent. Brief the agent with:

- The target chapter file path.
- The relevant excerpts of `CLAUDE.md` (notation + style profile).
- A focused prompt: "Identify (1) empirical claims (numerical facts,
  historical claims, attributions of method to specific authors,
  derivations) that should have a `\citep{}` nearby but don't; (2)
  places where the text uses a causal connector ('por lo tanto', 'esto
  implica', 'en consecuencia', 'de modo que') and the conclusion does
  not strictly follow from the prior stated premises; (3) **definiciones
  duplicadas o conflictivas dentro del mismo capítulo** — un concepto o
  símbolo que se introduce o se redefine con dos formulaciones distintas
  (p.ej.\ una estadística y otra geométrica) sin identificarlas
  explícitamente entre sí, o usándolas como si fueran intercambiables;
  (4) **framing/autoría borrosa** — pasajes donde el autor hace una
  contribución metodológica propia (verificación empírica, identificación
  de relaciones no documentadas, inspección directa de datos, derivación
  original) en estilo impersonal y rodeada de citas a fuentes externas,
  de modo que se lee como afirmación citada en vez de trabajo propio.
  Para (4), señalar la línea, el fragmento, y sugerir un marcador
  explícito de autoría ('en este trabajo verificamos', 'identificamos
  aquí', 'por inspección directa de los datos confirmamos', etc.).
  Para cada finding, provide line number, the exact text, and a one-line
  reason. Be conservative: when in doubt, formulate as a question
  ('¿necesita cita?', '¿es la misma cantidad?', '¿es trabajo propio?')
  rather than an assertion. Cap output at 15 findings total. Return as
  a structured list with each finding tagged by category (1)/(2)/(3)/(4)."

Wait for the agent to return. Merge its findings into the report:
- (1) → [D] citation gaps
- (2) → [E-semantic] logical jumps
- (3) → [E-semantic] conflicting/duplicate definitions
- (4) → [B] authorship/framing

### Step 7 — Compose the report

**Always**: produce an in-chat summary with this exact structure:

```
# Auditoría cap. <N>

**Inventario**: <lines> líneas, <secs> secciones, <subs> subsecciones,
<todos> todos pendientes (<n_claude> dirigidos a CLAUDE), <cites> citas
únicas, <eqs> ecuaciones.

[only if there are \todo{CLAUDE: ...} in the chapter:]
## [CLAUDE] <N pedidos>
<one line per request: línea, pedido, y estado — verificado con veredicto,
en cola para el follow-up, o pregunta de interpretación>

## [A] <N hallazgos>
<one-line summary per finding, max 3-5 inline>

## [B] <N hallazgos>
<one-line summary per finding, max 3-5 inline>

## [C] <N hallazgos>
<one-line summary per finding, max 3-5 inline>

## [E] <N hallazgos>
<one-line summary per finding, max 3-5 inline>

[only with --deep:]
## [D] <N hallazgos>
<one-line summary per finding, max 3-5 inline>

## [E-semantic] <N hallazgos>
<one-line summary per finding, max 3-5 inline>

¿Discutimos los [A] primero, o querés ir por otro orden?
```

If a category has more findings than the inline cap, end its block with
"(+<extra> más; pedímelos si querés ver el detalle o usá --save)".

**With `--save`**: also write the full report to `AUDITORIA-cap-<N>.md` in
the repo root. The file version contains ALL findings with full detail:

```
# Auditoría cap. <N> — <YYYY-MM-DD>

[Inventario]
...

## [A] Errores técnicos
### A1. <título corto>
- **Ubicación**: chapter-<N>.tex:<línea>
- **Texto**: <snippet>
- **Problema**: <razón>
- **Sugerencia**: <fix propuesto>

[... resto de las categorías con el mismo formato ...]
```

Numerar consecutivamente dentro de cada categoría (A1, A2, ..., B1, B2, ...).

End the chat message with the discussion prompt: "¿Por dónde arrancamos?"
or "¿Discutimos los [A] primero?".

## Important notes

- **Read-only**. Do NOT invoke Edit, Write, or sed inside this skill (the
  exception: the `--save` artifact write is allowed). The skill produces a
  report; the user decides which findings to apply, and edits happen in
  the conversational follow-up. This applies to `\todo{CLAUDE: ...}`
  requests too: verification requests are executed (they only read),
  edit requests are queued, never applied mid-audit.

- **Re-read CLAUDE.md every run.** The notation table and the style profile
  are the source of truth. Do not hardcode their contents in the body of
  this skill (the notation guidance above is illustrative; the canonical
  table lives in CLAUDE.md and may have been updated).

- **Be conservative with [C] and [D]** to keep false positives low. Many
  "el mismo" hits are valid determiners, many "el método de X" mentions
  are followed by a citation a few lines down. When uncertain, formulate
  findings as questions ("¿es necesaria una cita acá?") rather than as
  assertions of error.

- **`--deep` is slow**. Warn the user before spawning the sub-agent that it
  will take ~3-5 minutes. Do not run `--deep` if the user did not pass the
  flag.

- **Scope is one chapter**. Do not flag inconsistencies between this
  chapter and others (e.g., a symbol used differently here than in another
  chapter). Cross-chapter consistency is out of scope for this skill.

- **Workflow continuation**. After delivering the report, the conversation
  resumes the project's standard revision flow: discuss findings item by
  item, decide which to apply, commit fixes atomically. This is encoded in
  the user's memory (`feedback_revision_workflow`) and does not need to be
  repeated in chat.
