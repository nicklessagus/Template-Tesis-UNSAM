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
	@cd $(CHAPTERS_DIR) && $(LATEX) -interaction=nonstopmode chapter-$*.tex
	@if [ -f "$(CHAPTERS_DIR)/chapter-$*.bcf" ]; then \
		(cd $(CHAPTERS_DIR) && $(BIB) --input-directory=.. chapter-$*); \
	fi
	@cd $(CHAPTERS_DIR) && $(LATEX) -interaction=nonstopmode chapter-$*.tex
	@cd $(CHAPTERS_DIR) && $(LATEX) -interaction=nonstopmode chapter-$*.tex
	

# Generar lista de TODOs (requiere todonotes)
todos:
	$(LATEX) -interaction=nonstopmode "\\listoftodos\\end{document}" > /dev/null

# Limpieza de archivos temporales
distclean: clean
	@rm -f $(OUTPUT_PDF)
	@find $(CHAPTERS_DIR) -type f -name '*.pdf' -delete

clean:
	@rm -f $(AUX_FILES)
	@find $(CHAPTERS_DIR) -type f \( \
		-name '*.aux' -o -name '*.log' -o -name '*.bbl' -o -name '*.blg' -o -name '*.out' -o -name '*.toc' -o -name '*.lof' -o -name '*.lot' -o -name '*.fls' -o -name '*.fdb_latexmk' -o -name '*.synctex.gz' -o -name '*.nav' -o -name '*.snm' -o -name '*.vrb' -o -name '*.xdv' -o -name '*.run.xml' -o -name '*.bcf' \
	\) -delete

.PHONY: all pdf clean distclean todos
