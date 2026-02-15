% --- Lógica de watermark eliminada: ahora se define solo en main.tex ---
% ------------------------------------------------------
% tesis.cls - Clase personalizada para tesis UNSAM
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tesis}[2026/02/14 Tesis Doctoral UNSAM]
\LoadClass[12pt,a4paper]{report}

% Paquetes recomendados
\RequirePackage{geometry}
\geometry{a4paper, left=3cm, right=2cm, top=3cm, bottom=2.5cm}
\RequirePackage[spanish, es-tabla]{babel}
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
\RequirePackage{lipsum}
\setlength{\marginparwidth}{2cm} % Ajuste para todonotes
\RequirePackage[backend=biber]{biblatex}
\addbibresource{bibliography.bib}

\RequirePackage{fancyhdr}
\RequirePackage{xcolor}

% Definición de color para links (CMYK 50, 30, 10, 0)
\definecolor{colorUNSAM}{cmyk}{0.50, 0.30, 0.10, 0}

% Configuración de encabezados y pies de página
\pagestyle{fancy}
\fancyhf{} % Limpiar encabezados y pies
\renewcommand{\chaptermark}[1]{\markboth{#1}{}} % Quitar el número del capítulo en el encabezado
\fancyhead[L]{\nouppercase{\leftmark}} % Nombre del capítulo a la izquierda
\fancyhead[R]{\thepage} % Número de página a la derecha
\setlength{\headheight}{15pt} % Ajuste para evitar warnings de fancyhdr

% Estilo de página para inicios de capítulo (plain)
\fancypagestyle{plain}{
  \fancyhf{}
  \fancyfoot[C]{\thepage} % Número de página al centro en el pie
  \renewcommand{\headrulewidth}{0pt}
}

% Hyperref config (colores en vez de recuadros)
\hypersetup{
	colorlinks=true,
	linkcolor=colorUNSAM,
	citecolor=colorUNSAM,
	urlcolor=colorUNSAM
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

% Lógica de control centralizado para subfiles
% (Eliminada por complejidad innecesaria. Se controla manualmente en cada archivo)

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

% --- Comandos para definir los datos de la tesis ---
\newcommand{\titulo}[1]{\def\thetitulo{#1}}
\newcommand{\autor}[1]{\def\theautor{#1}}
\newcommand{\director}[1]{\def\thedirector{#1}}
\newcommand{\carrera}[1]{\def\thecarrera{#1}}
\newcommand{\universidad}[1]{\def\theuniversidad{#1}}
\newcommand{\fecha}[1]{\def\thefecha{#1}}

% --- Valores por defecto (se pisan en main.tex) ---
\titulo{Es más facil que el tomate sea perita, que la pera tomatito}
\autor{Peperino Pómoro}
\director{Dr. Fabio Alberti}
\carrera{Doctor en Ciencias Aplicadas y de la Ingenieria}
\universidad{Universidad Nacional de San Martín}
\fecha{\today}
