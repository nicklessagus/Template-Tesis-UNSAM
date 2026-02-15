# Makefile para tesis UNSAM
# Configuración principal
MAIN_TEX ?= main.tex
OUTPUT_PDF ?= tesis.pdf
CHAPTERS_DIR := chapters
IMG_DIR := img

# Archivos temporales a limpiar
AUX_EXTS = aux bbl blg log out toc lof lot fls fdb_latexmk synctex.gz nav snm vrb xdv run.xml tdo bcf
AUX_FILES = $(foreach ext,$(AUX_EXTS),$(basename $(MAIN_TEX)).$(ext))

# Compilador principal
LATEX = xelatex
BIB = biber

.ONESHELL:

# Reglas principales
all: pdf

pdf:
	$(LATEX) -interaction=nonstopmode $(MAIN_TEX)
	@if [ -f "$(basename $(MAIN_TEX)).bcf" ]; then \
		$(BIB) $(basename $(MAIN_TEX)); \
	fi
	$(LATEX) -interaction=nonstopmode $(MAIN_TEX)
	$(LATEX) -interaction=nonstopmode $(MAIN_TEX)
	@if [ -f $(basename $(MAIN_TEX)).pdf ]; then \
		mv $(basename $(MAIN_TEX)).pdf $(OUTPUT_PDF); \
		$(MAKE) clean; \
	fi

# Compilar capítulo individual: make chapter-1
chapter-%:
	cd $(CHAPTERS_DIR)
	$(LATEX) -interaction=nonstopmode chapter-$*.tex
	if [ -f "chapter-$*.bcf" ]; then
		$(BIB) --input-directory=.. chapter-$*
	fi
	$(LATEX) -interaction=nonstopmode chapter-$*.tex
	$(LATEX) -interaction=nonstopmode chapter-$*.tex
	if [ -f "chapter-$*.pdf" ]; then
		# remove temporals for this chapter (keep .tex and .pdf) — operate in current dir
		find . -maxdepth 1 -type f \( -name "chapter-$*.aux" -o -name "chapter-$*.log" -o -name "chapter-$*.bbl" -o -name "chapter-$*.bcf" -o -name "chapter-$*.blg" -o -name "chapter-$*.out" -o -name "chapter-$*.run.xml" -o -name "chapter-$*.synctex.gz" -o -name "chapter-$*.synctex" -o -name "chapter-$*.synctex(busy)" -o -name "chapter-$*.xdv" -o -name "chapter-$*.fdb_latexmk" -o -name "chapter-$*.fls" -o -name "chapter-$*.nav" -o -name "chapter-$*.snm" -o -name "chapter-$*.vrb" \) -delete
	fi

# Generar lista de TODOs (requiere todonotes)
todos:
	$(LATEX) -interaction=nonstopmode "\\listoftodos\\end{document}" > /dev/null

# Limpieza de archivos temporales
distclean: clean
	@rm -f $(OUTPUT_PDF)
	@find $(CHAPTERS_DIR) -type f -name '*.pdf' -delete
	# Also remove per-chapter bibliography artifacts (.bbl, .bcf)
	@find $(CHAPTERS_DIR) -type f \( -name '*.bbl' -o -name '*.bcf' \) -delete

clean:
	@rm -f $(AUX_FILES)
	@find $(CHAPTERS_DIR) -type f \( \
		-name '*.aux' -o -name '*.log' -o -name '*.blg' -o -name '*.out' -o -name '*.toc' -o -name '*.lof' -o -name '*.lot' -o -name '*.fls' -o -name '*.fdb_latexmk' -o -name '*.synctex.gz' -o -name '*.nav' -o -name '*.snm' -o -name '*.vrb' -o -name '*.xdv' -o -name '*.run.xml' \
	\) -delete

.PHONY: all pdf clean distclean todos
