# Template Tesis Doctoral UNSAM

Este template está diseñado para tesis de Doctorado en Ciencias Aplicadas y de la Ingeniería de la Universidad Nacional de San Martín (UNSAM), o cualquier otro programa similar que comparta la identidad y formato institucional.

## Características principales
- Compilación modular por capítulos (cada capítulo es un archivo independiente en `chapters/`).
- Compilación global (`main.tex`) y por capítulo para agilizar el flujo de trabajo.
- Marca de agua de "BORRADOR" configurable y centralizada.
- Sistema de TODOs y lista de tareas pendientes al inicio del PDF.
- Makefile moderno, configurable, automático y silenciado (`nonstopmode`).
- Bibliografía centralizada (`bibliography.bib`) mediante `biblatex` (con soporte para comandos natbib).
- Clase personalizada (`tesis.cls`) estandarizando el formato UNSAM.
- Soporte completo para español y fuentes modernas a través del motor `XeLaTeX`.
- Chequeos mecánicos instantáneos sin compilar (`make check`): referencias rotas, labels duplicados, citas sin entrada en el `.bib` y estilo, extensibles por proyecto vía `scripts/check_config.json`.
- Skill `/biblio-check` para Claude Code (`.claude/skills/`): validación de los metadatos de `bibliography.bib` contra fuentes externas (ADS/CrossRef).
- Skill `/audit-chapter` para Claude Code (`.claude/skills/`): auditoría mecánica y estructural de un capítulo (refs, citas, notación, estilo) clasificada por severidad, read-only.
- Instrucciones pre diseñadas para agentes de inteligencia artificial (Copilot, Windsurf, Cursor) enfocadas en redacción académica puramente formal integradas en `AGENTS.md`.

## Estructura sugerida
- `main.tex`: Documento principal (incluye preámbulo, resúmenes, caratula y agrupa los capítulos).
- `tesis.cls`: Clase personalizada con los márgenes, espaciados y paquetes estándar.
- `chapters/`: Directorio preparado para los capítulos individuales (ej. `chapter-1.tex`).
- `img/`: Directorio donde almacenar las imágenes y gráficos.
- `bibliography.bib`: Base de datos de referencias.
- `AGENTS.md`: Prompt y reglas conductuales base para uso de agentes AI durante la escritura.

## Compilación con Makefile
Por comodidad, el proyecto incluye un `Makefile` listo para ejecutarse tanto de forma manual como a través de agentes IA.

- `make` o `make pdf`: Compila el proyecto entero (`main.tex`), resuelve bibliografía iterando las veces necesarias, traslada el output a `tesis.pdf` y limpia el directorio de remanentes (`.log`, `.aux`, etc.).
- `make chapter-1` (o 2, 3, etc.): Compila localmente dentro de `chapters/` el capítulo en particular, manteniendo los estilos y resolviendo su propia bibliografía. Ideal para tiempos de iteración rápidos en LaTeX.
- `make todos`: Genera un PDF rápido unicamente priorizando el renderizado de la lista de tareas `\listoftodos` (si están habilitadas y comentadas con la macro de `todonotes`).
- `make clean`: Limpia todos los archivos intermedios ensuciando la raíz y capítúlos.
- `make distclean`: Realiza idéntico a clean, pero además borra los PDFs finales (`tesis.pdf` y los de la carpeta de capítulos).
- `make check`: Chequeos mecánicos instantáneos sin compilar (requiere Python 3). Ver sección siguiente.

## Chequeos mecánicos (`make check`)

`scripts/check_tesis.py` valida en un segundo lo que un grep determinístico puede validar, sin gastar una compilación:

- **Errores** (exit 1): `\ref` a labels inexistentes, labels duplicados, citas sin entrada en `bibliography.bib`, `\label` dentro de un display sin numerar `\[...\]` (bug silencioso: la referencia imprime el número de sección), `\setcounter{chapter}` inconsistente con el número de archivo, `\includegraphics` sin archivo en `img/`.
- **Avisos** (no fallan): em-dashes, decimales con punto en math mode, `\citep` usado como sujeto de la oración, prefijo `img/` redundante.

Los comentarios `%` se ignoran siempre y el contenido de `\todo{}` se excluye de los avisos de estilo. **Para extender los chequeos al vocabulario de cada tesis** (terminología, grafías, frases vetadas) alcanza con agregar pares regex/mensaje en `scripts/check_config.json`, sin tocar el script; el mismo archivo permite whitelistear referencias rotas conscientes (placeholders) y desactivar la convención de coma decimal.

## Skill `/biblio-check` (Claude Code)

En `.claude/skills/biblio-check/` se incluye un skill para quienes usen Claude Code: valida el **contenido** de cada entrada citada de `bibliography.bib` contra fuentes externas (ADS, CrossRef, arXiv), es decir, que título, autores, año, journal y DOI correspondan realmente al mismo paper. Detecta entradas con metadatos mezclados, duplicados y campos malformados, y propone el bloque BibTeX corregido sin modificar nada por sí mismo (`make check` solo verifica que las keys citadas *existan*; este skill verifica que digan la verdad).

## Skill `/audit-chapter` (Claude Code)

En `.claude/skills/audit-chapter/` se incluye un skill que audita un capítulo (`chapters/chapter-N.tex`) contra el perfil de estilo y las convenciones de notación del proyecto, la bibliografía y las referencias cruzadas. Clasifica los hallazgos por severidad (A técnicos, B sustantivos, C estilo, E estructura; con `--deep` agrega D citación y E-semántico) para discutirlos ítem por ítem **antes** de editar: es read-only, no aplica fixes por sí mismo. Con `--save` persiste el reporte completo en `AUDITORIA-cap-N.md`.

El skill lee la tabla de notación y el perfil de estilo desde **`CLAUDE.md`, que el template incluye como esqueleto a rellenar** (ver sección siguiente): la tabla de símbolos reservados viene vacía y el perfil de estilo trae las convenciones formales genéricas (sin em-dash, decimales con coma, frases vetadas, referencias cruzadas RAE) más una sección "voz del autor" para completar. Sin un `CLAUDE.md` completo, `audit-chapter` corre igual los chequeos mecánicos (refs, citas, estructura) y saltea los de notación y estilo.

## `CLAUDE.md` (esqueleto a rellenar)

El archivo `CLAUDE.md` es la fuente de verdad que consumen los skills de Claude Code (notación, perfil de estilo, convenciones del proyecto). **Se entrega como esqueleto**: hay que completarlo con los datos y las convenciones de cada tesis antes de que rinda al máximo. Qué rellenar:

- **Contexto del proyecto**: título, autor, director, institución, tema (placeholders al inicio).
- **Tabla de notación matemática**: qué letra/símbolo se reserva para qué cantidad (una sola acepción por símbolo). La tabla viene vacía; `audit-chapter` la usa para detectar colisiones de notación.
- **Voz del autor**: las frases características, giros y "lo que NO suena como el autor", que dependen de cada persona. Las convenciones formales genéricas (RAE, coma decimal, em-dash, clichés) ya vienen cargadas.

Mientras el esqueleto esté sin rellenar, los skills funcionan en modo degradado (solo lo mecánico); no es un error, es lo esperado hasta que lo completes.

## Requisitos
- Motores y Paquetes de TeX Live o MiKTeX:
  - `XeLaTeX`
  - `biber`
- Paquetes esenciales incluidos en el `.cls`: `subfiles`, `todonotes`, `draftwatermark`, `hyperref`, `babel` (spanish), `fontspec`, entre otros habituales.

## TODOs y notas (`todonotes`)

El paquete `todonotes` está cargado por defecto en `tesis.cls`. Variantes habituales:

- `\todo{texto}` — nota al margen (útil para recordatorios cortos sobre una palabra o una frase puntual).
- `\todo[inline]{texto}` — bloque destacado dentro del cuerpo del texto, ideal para placeholders de párrafos o secciones enteras todavía no escritas.
- `\missingfigure{descripción}` — caja gris con un ícono de imagen pendiente; útil mientras no se tenga la figura final.
- `\listoftodos` — listado de todos los TODOs del documento (lo usa `make todos` para generar un PDF rápido con la lista de pendientes).

## Personalización Rápida
- **Carátula e Información**: Editar el comando de variables propias de la tesis (`\titulo`, `\autor`, `\director`, `\institucion`) al comienzo de `main.tex`.
- **Marca de agua**: En `main.tex`, descomentar la línea de `\draftwatermarkon` para activar en toda la tesis el texto cruzado "DRAFT". Si se compila un capítulo modular y se desea marca de agua, conviene pasar temporalmente este comando al interior de ese capítulo.
- **Formato avanzado**: Editar `tesis.cls` si se necesita alterar jerarquías de TOC, modificar la inter-línea o reajustar los escudos de la universidad.
- **Flujo con LLMs**: Conviene modificar en `AGENTS.md` el título central y la jerga esperada, para adecuar el asistente IA al campo científico correspondiente.
