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
- Control de marca de agua centralizado desde `main.tex` (descomentar `\draftwatermarkon` para activar en toda la tesis).

## Estructura sugerida
- `main.tex`: documento principal.
- `tesis.cls`: clase personalizada.
- `chapters/`: capítulos individuales.
- `img/`: imágenes.
- `bibliography.bib`: bibliografía.

## Compilación
- `make` compila la tesis completa y limpia temporales si no hay error.
- `make chapter-1` compila solo el capítulo 1.
- `make todos` genera la lista de TODOs.
- Variables en el Makefile para personalizar nombre de salida y archivo principal.

## Requisitos
- XeLaTeX
- biber
- Paquetes: subfiles, todonotes, draftwatermark, hyperref, babel (spanish), fontspec, etc.

## Personalización
- Editar el preámbulo de `main.tex` para configurar los datos de la tesis (`\titulo`, `\autor`, etc.) y activar la marca de agua.
- Editar `tesis.cls` para cambiar formato profundo.
- Editar `bibliography.bib` para referencias.

### Nota sobre compilación por capítulo
La marca de agua está centralizada en `main.tex`. Si deseas que se active también al compilar un capítulo individual por separado, puedes mover el comando `\draftwatermarkon` al archivo del capítulo.
