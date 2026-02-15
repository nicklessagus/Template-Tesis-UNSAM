% --- Lógica de watermark eliminada: ahora se define solo en main.tex ---
% ------------------------------------------------------
% tesis.cls - Clase personalizada para tesis UNSAM
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tesis}[2026/02/14 Tesis Doctoral UNSAM]
\LoadClass[12pt,a4paper]{report}

% Paquetes recomendados
\RequirePackage{geometry}
\geometry{a4paper, left=3cm, right=2cm, top=3cm, bottom=2.5cm}
\RequirePackage{babel}
\RequirePackage{fontspec}
\RequirePackage{setspace}
\RequirePackage{hyperref}
\RequirePackage{csquotes}
\RequirePackage{graphicx}
\RequirePackage{booktabs}
\RequirePackage{caption}
\RequirePackage{subcaption}
\RequirePackage{amsmath,amssymb}
\RequirePackage{todonotes}
\setlength{\marginparwidth}{2cm} % Ajuste para todonotes
\RequirePackage[backend=biber]{biblatex}

% Bibliografía
\addbibresource{bibliography.bib}

% Hyperref config (colores en vez de recuadros)
\hypersetup{
	colorlinks=true,
	linkcolor=blue,
	citecolor=blue,
	urlcolor=blue
}

% Marca de agua (Watermark)
\RequirePackage{draftwatermark}
\SetWatermarkText{} % Default: vacío
\SetWatermarkScale{1}

\newcommand{\draftwatermarkon}{%
	\SetWatermarkText{DRAFT}%
	\SetWatermarkScale{1}%
}
\newcommand{\draftwatermarkoff}{%
	\SetWatermarkText{}%
}

% Estilo de capítulos
\renewcommand{\chaptername}{Capítulo}
\renewcommand{\contentsname}{Índice general}
\renewcommand{\listfigurename}{Índice de figuras}
\renewcommand{\listtablename}{Índice de tablas}

% Espaciado
\onehalfspacing

% Otros ajustes
\setlength{\parindent}{1.5em}
\setlength{\parskip}{0.5em}

% Título y autor (se redefine en caratula.tex)
\newcommand{\titulo}{Es más fácil, pero mucho más fácil, que el tomate sea perita que la pera tomatito}
\newcommand{\autor}{Peperino Pómoro}
\newcommand{\director}{Dr. Fabio Alberti}
\newcommand{\carrera}{Doctor en Ciencias Aplicadas y de la Ingenieria}
\newcommand{\universidad}{Universidad Nacional de San Martín}
\newcommand{\fecha}{Julio 2026}
