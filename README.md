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
