# CLAUDE.md — Guía de Colaboración para la Tesis

> **ESQUELETO A RELLENAR.** Este archivo es la fuente de verdad que consumen los
> skills de Claude Code (`/audit-chapter`, etc.): notación, perfil de estilo y
> convenciones del proyecto. Completá las secciones marcadas con `<...>` y
> `TODO`. Mientras el esqueleto esté incompleto, `/audit-chapter` corre en modo
> degradado (solo chequeos mecánicos: refs, citas, estructura) y saltea los de
> notación y estilo. No es un error, es lo esperado hasta que lo llenes.
>
> Complementa la documentación técnica de `AGENTS.md`.

---

## Contexto del Proyecto

**Título:** `<título de la tesis>`
**Autor:** `<nombre del autor>`
**Director:** `<director/a>`
**Institución:** UNSAM (Universidad Nacional de San Martín)
**Defensa estimada:** `<mes/año>`

**Tema / problema central:** `<una o dos frases sobre el problema que aborda la tesis>`

---

## Rol Principal

Las tareas más frecuentes al asistir en esta tesis:

1. **Revisar y corregir texto** — coherencia, fluidez, tono, ortografía y sintaxis.
2. **Reescribir pasajes** — mantener el mensaje del autor, mejorar la expresión sin cambiar el contenido.
3. **Evaluar coherencia estructural** — que el argumento fluya entre secciones y capítulos.
4. **Detectar problemas** — lagunas lógicas, contradicciones, afirmaciones sin soporte.

**Lo que NO se debe hacer:**
- Agregar contenido o información que el autor no haya indicado.
- Cambiar la estructura argumentativa sin indicación explícita.
- Sonar como texto generado por IA.
- Sugerir cambios que no se solicitaron.

---

## Estilo de Escritura

### Convenciones formales (genéricas, ya cargadas)

Reglas de castellano académico formal, válidas para cualquier tesis. Son las que
chequea `/audit-chapter` en su categoría **[C]**:

- **Sin em-dash** (`---` LaTeX, `—` U+2014) para incisos: usar comas o paréntesis. Los en-dash (`--` LaTeX, `–` U+2013) y guiones simples para rangos numéricos y apellidos compuestos (Cramér--Rao, Levenberg--Marquardt) sí están permitidos.
- **Decimales con coma**, no con punto (convención castellana): en math mode usar `0{,}5` (las llaves preservan el espaciado); en prosa, `0,5`.
- **Frases vetadas** (relleno/cliché de IA): "es crucial", "es fundamental", "cabe destacar", "cabe mencionar", "es importante notar", "en este sentido".
- **Evitar** "el mismo / la misma / los mismos / las mismas" como pronombre anafórico.
- **Referencias cruzadas (RAE)**: "capítulo", "sección", "figura", "tabla", "ecuación" van en minúscula y con palabra completa en el cuerpo del texto, con `~` (espacio irrompible) antes del `\ref{}`. La abreviatura (`cap.`, `fig.`, `sec.`, `tab.`, `ec.`, `pág.`, en minúscula) se reserva para paréntesis, pies de figura, tablas y notas al pie. No arrancar oración con abreviatura.
- **Comillas**: tipográficas, no ASCII `"..."`.

### Voz del autor (RELLENAR)

> **TODO:** completar con el estilo propio del autor. Sugerencia: analizar la
> tesis de grado o papers previos y extraer, con ejemplos concretos:
>
> - **Registro y tono**: `<formal / pedagógico / sobrio / …>`
> - **Voz gramatical**: `<pasiva refleja / primera persona plural / impersonal / …>`
> - **Estructura argumental**: `<de lo general a lo particular / problema-solución / …>`
> - **Frases características**: `<giros que el autor usa>`
> - **Lo que NO suena como el autor**: `<giros a evitar, además de los genéricos de arriba>`

---

## Convenciones de notación matemática (RELLENAR)

`/audit-chapter` usa esta tabla para detectar **colisiones de notación** (un
símbolo con dos significados físicos, o un índice reservado reutilizado). Regla
madre: **un símbolo = una acepción** en toda la tesis. Completá la tabla con los
símbolos e índices de tu tesis:

| Símbolo | Significado | Ámbito (prosa / ecuaciones / todo) |
|---|---|---|
| `<x>` | `<qué representa>` | `<...>` |
| `<i>`, `<j>`, `<k>` | `<índices reservados; declarar cuáles y para qué>` | `<...>` |
| … | … | … |

Si la tesis distingue **verdad vs estimación** (p.ej. simulaciones con ground
truth frente a cantidades recuperadas), documentar acá el alcance de decoradores
como el hat `\hat{}`: en qué pasajes se usan y en cuáles no. `/audit-chapter`
contrasta cada sección contra este listado y, si encuentra uso sistemático fuera
de él, lo reporta como pregunta [B], no como error.

---

## Convenciones LaTeX

- **Compilación**: usar `make` / `make chapter-N` (nunca xelatex/biber directo).
- **Chequeo mecánico**: `make check` después de editar `.tex` (refs↔labels, citas↔bib, estilo greppable). Con `make check-chapter-N` el reporte se limita a `chapter-N.tex`, útil al iterar sobre un solo capítulo (el escaneo sigue siendo global, sólo se filtra la salida). Extensible por proyecto vía `scripts/check_config.json` (agregar ahí los patrones de terminología/grafía propios de la tesis).
- **Citas**: `\citep{}` para parentéticas, `\citet{}` para citas en el texto.
- **Referencias cruzadas**: ver la regla RAE de la sección de estilo.
- **Decimales con coma** (ver arriba).
- **TODOs**: `\todo{...}` / `\todo[inline]{...}`; se listan con `make todos`.
- **Figuras**: ruta relativa a `img/` (sin el prefijo `img/`).
- **Pedidos dirigidos al asistente**: dejar `\todo{CLAUDE: <pedido>}` en el `.tex`. `/audit-chapter` los detecta, ejecuta los de verificación (read-only) y encola los de edición para el follow-up.

---

## Notas de Colaboración

- El objetivo es que el texto suene como escrito por el autor, no por una IA.
- Si un pasaje es ambiguo o la intención no está clara, preguntar antes de reescribir.
- Al sugerir cambios, explicar brevemente por qué (una línea), para que el autor decida.
- Las correcciones de estilo no deben cambiar el significado técnico.
- Al revisar un capítulo, reportar: (1) problemas de coherencia o lagunas, (2) sugerencias de estilo concretas, (3) errores ortográficos/gramaticales.
