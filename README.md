# Template Tesis Doctoral UNSAM

Este template está diseñado para tesis de Doctorado en Ciencias Aplicadas y de la Ingeniería de la Universidad Nacional de San Martín (UNSAM).

## Características principales
- Compilación modular por capítulos (cada capítulo es un archivo independiente en `chapters/`).
- Compilación global (`main.tex`) y por capítulo.
- Marca de agua de "BORRADOR" configurable.
- Sistema de TODOs y lista de tareas pendientes en el PDF.
- Makefile moderno, configurable y automático.
- Bibliografía centralizada (`bibliography.bib`).
- Clase personalizada (`tesis.cls`) para formato UNSAM.
- Soporte completo para español y fuentes modernas (XeLaTeX).
- Control de marca de agua centralizado desde `main.tex` (usar `\draftwatermarkon`/`\draftwatermarkoff` antes de cada `\subfile{}`).

## Estructura sugerida
- `main.tex`: documento principal.
- `tesis.cls`: clase personalizada.
- `chapters/`: capítulos individuales.
- `img/`: imágenes.
- `bibliography.bib`: bibliografía.

## Compilación
- `make` compila la tesis completa y limpia temporales si no hay error.
- `make chapter-1` compila solo el capítulo 1.
 - `make chapter-1` compila solo el capítulo 1. Si centralizas la marca de agua en `main.tex`, la compilación por capítulo no activará la marca de agua: para pruebas hay un ejemplo de referencia en `chapters/chapter-1.tex` que permite verificar compilación individual.
- `make todos` genera la lista de TODOs.
- Variables en el Makefile para personalizar nombre de salida y archivo principal.

## Requisitos
- XeLaTeX
- biber
- Paquetes: subfiles, todonotes, draftwatermark, hyperref, babel (spanish), fontspec, etc.

## Personalización
- Editar `main.tex` para agregar capítulos, resumen, agradecimientos, etc.
- Editar `tesis.cls` para cambiar formato.
- Editar `bibliography.bib` para referencias.
\
### Nota sobre compilación por capítulo
Si deseas que la marca de agua se active también al compilar un capítulo individual, mueve el `\draftwatermarkon`/`\draftwatermarkoff` al fichero del capítulo o usa un pequeño wrapper en el preámbulo del capítulo. En este template la decisión por defecto es centralizar en `main.tex`.
