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
	@if grep -q '\\bibliography' $(MAIN_TEX); then \
		$(BIB) $(basename $(MAIN_TEX)); \
		$(LATEX) -interaction=nonstopmode $(MAIN_TEX); \
	fi
	$(LATEX) -interaction=nonstopmode $(MAIN_TEX)
	@if [ -f $(basename $(MAIN_TEX)).pdf ]; then \
		mv $(basename $(MAIN_TEX)).pdf $(OUTPUT_PDF); \
		$(MAKE) clean; \
	fi

# Compilar capítulo individual: make chapter-1
chapter-%:
	$(LATEX) -output-directory=$(CHAPTERS_DIR) -interaction=nonstopmode $(CHAPTERS_DIR)/chapter-$*.tex
	@if grep -q '\\bibliography' $(CHAPTERS_DIR)/chapter-$*.tex; then \
		$(BIB) $(CHAPTERS_DIR)/chapter-$*; \
		$(LATEX) -output-directory=$(CHAPTERS_DIR) -interaction=nonstopmode $(CHAPTERS_DIR)/chapter-$*.tex; \
	fi
	$(LATEX) -output-directory=$(CHAPTERS_DIR) -interaction=nonstopmode $(CHAPTERS_DIR)/chapter-$*.tex

# Generar lista de TODOs (requiere todonotes)
todos:
	$(LATEX) -interaction=nonstopmode "\\listoftodos\\end{document}" > /dev/null

# Limpieza de archivos temporales
distclean: clean
	@rm -f $(OUTPUT_PDF)

clean:
	@rm -f $(AUX_FILES)
	@rm -f $(CHAPTERS_DIR)/*.aux $(CHAPTERS_DIR)/*.log $(CHAPTERS_DIR)/*.bbl $(CHAPTERS_DIR)/*.blg $(CHAPTERS_DIR)/*.out $(CHAPTERS_DIR)/*.toc $(CHAPTERS_DIR)/*.lof $(CHAPTERS_DIR)/*.lot $(CHAPTERS_DIR)/*.fls $(CHAPTERS_DIR)/*.fdb_latexmk $(CHAPTERS_DIR)/*.synctex.gz $(CHAPTERS_DIR)/*.nav $(CHAPTERS_DIR)/*.snm $(CHAPTERS_DIR)/*.vrb $(CHAPTERS_DIR)/*.xdv $(CHAPTERS_DIR)/*.run.xml

.PHONY: all pdf clean distclean todos